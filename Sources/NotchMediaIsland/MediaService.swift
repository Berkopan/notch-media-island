import AppKit
import IslandCore

@MainActor
final class MediaService: ObservableObject {
    @Published private(set) var playback = Playback()
    @Published private(set) var artwork: NSImage?
    @Published private(set) var errorMessage: String?
    private var stream: Process?
    private var commands: [UUID: Process] = [:]
    private var buffer = LineBuffer()
    private var timeline = PlaybackTimeline()
    private var artworkEncoded: String?

    #if README_PREVIEW
    // Documentation renders use fictional metadata and never connect to MediaRemote.
    init(preview: Playback, artwork: NSImage?) {
        self.playback = preview
        self.artwork = artwork
    }
    #endif

    private func process(_ arguments: [String]) throws -> Process {
        guard let resources = Bundle.main.resourceURL,
              let frameworks = Bundle.main.privateFrameworksURL else {
            throw CocoaError(.fileNoSuchFile)
        }
        let script = resources.appendingPathComponent("mediaremote-adapter.pl")
        let framework = frameworks.appendingPathComponent("MediaRemoteAdapter.framework")
        guard FileManager.default.fileExists(atPath: script.path),
              FileManager.default.fileExists(atPath: framework.path) else {
            throw CocoaError(.fileNoSuchFile)
        }
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/perl")
        task.arguments = [script.path, framework.path] + arguments
        task.standardError = FileHandle.nullDevice
        return task
    }

    func start() {
        stop()
        errorMessage = nil
        buffer = LineBuffer()
        timeline = PlaybackTimeline()
        do {
            let task = try process(["stream", "--no-diff", "--micros", "--allow-missing-title", "--debounce=80"])
            let output = Pipe()
            task.standardOutput = output
            output.fileHandleForReading.readabilityHandler = { [weak self, weak task] handle in
                let data = handle.availableData
                if data.isEmpty { handle.readabilityHandler = nil; return }
                Task { @MainActor [weak self, weak task] in
                    guard let self, self.stream === task else { return }
                    self.receive(data)
                }
            }
            task.terminationHandler = { [weak self] terminated in
                output.fileHandleForReading.readabilityHandler = nil
                Task { @MainActor [weak self] in
                    guard let self, self.stream === terminated else { return }
                    self.stream = nil
                    self.playback = Playback()
                    self.artwork = nil
                    self.errorMessage = "Medya bağlantısı kesildi"
                }
            }
            stream = task
            try task.run()
        } catch {
            stream = nil
            errorMessage = "Medya bağlantısı kurulamadı"
        }
    }

    private func receive(_ data: Data) {
        for line in buffer.append(data) where !line.isEmpty {
            guard let event = try? JSONDecoder().decode(PlaybackEvent.self, from: line),
                  event.type == "data", !event.diff else { continue }
            playback = timeline.receive(event.payload)
            if artworkEncoded != playback.artworkData {
                artworkEncoded = playback.artworkData
                artwork = playback.artworkData.flatMap { Data(base64Encoded: $0) }.flatMap(NSImage.init(data:))
            }
            errorMessage = nil
        }
    }

    func send(_ command: Int) { runCommand(["send", String(command)]) }
    func seek(to seconds: Double) {
        guard playback.canSeek, seconds.isFinite else { return }
        let clamped = max(0, min(playback.duration, seconds))
        let id = UUID()
        timeline.seek(to: clamped, id: id)
        playback = timeline.playback
        runCommand(["seek", String(Int64(min(clamped * 1_000_000, Double(Int64.max / 2))))]) { [weak self] in
            self?.cancelSeek(id)
        }
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(3))
            self?.cancelSeek(id)
        }
    }

    private func cancelSeek(_ id: UUID) {
        guard timeline.cancelSeek(id: id) else { return }
        playback = timeline.playback
        errorMessage = "Oynatıcı yeni konumu doğrulamadı"
    }

    private func runCommand(_ arguments: [String], onFailure: @escaping @MainActor () -> Void = {}) {
        guard playback.hasMedia else { return }
        do {
            let task = try process(arguments)
            let id = UUID()
            task.standardOutput = FileHandle.nullDevice
            task.terminationHandler = { [weak self] task in
                Task { @MainActor [weak self] in
                    self?.commands[id] = nil
                    if task.terminationStatus != 0 {
                        onFailure()
                        self?.errorMessage = "Oynatıcı komutu uygulayamadı"
                    }
                }
            }
            try task.run()
            commands[id] = task
            Task { @MainActor [weak self, weak task] in
                try? await Task.sleep(for: .seconds(5))
                guard let task, task.isRunning else { return }
                task.terminate()
                onFailure()
                self?.errorMessage = "Oynatıcı yanıt vermedi"
            }
        } catch { onFailure(); errorMessage = "Oynatıcıya ulaşılamadı" }
    }

    func stop() {
        timeline = PlaybackTimeline()
        let old = stream
        stream = nil
        if let output = old?.standardOutput as? Pipe { output.fileHandleForReading.readabilityHandler = nil }
        old?.terminationHandler = nil
        if old?.isRunning == true { old?.terminate() }
        for task in commands.values where task.isRunning {
            task.terminationHandler = nil
            task.terminate()
        }
        commands.removeAll()
    }
}
