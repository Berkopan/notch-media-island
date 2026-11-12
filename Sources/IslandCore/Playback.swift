import Foundation

public struct Playback: Decodable, Equatable {
    public var bundleIdentifier: String?
    public var title: String?
    public var artist: String?
    public var album: String?
    public var playing: Bool?
    public var durationMicros: Double?
    public var elapsedTimeMicros: Double?
    public var timestampEpochMicros: Double?
    public var playbackRate: Double?
    public var artworkData: String?
    public var prohibitsSkip: Bool?

    public init() {}
    public var hasMedia: Bool { bundleIdentifier != nil }
    public var duration: Double {
        guard let value = durationMicros, value.isFinite, value > 0 else { return 0 }
        return value / 1_000_000
    }
    public var canSeek: Bool { hasMedia && duration > 0 && elapsedTimeMicros != nil }
    public var identity: String { [bundleIdentifier, title, artist, album].compactMap { $0 }.joined(separator: "\u{1f}") }

    public func elapsed(at date: Date = Date()) -> Double {
        let base = (elapsedTimeMicros ?? 0) / 1_000_000
        guard base.isFinite else { return 0 }
        var result = base
        if playing == true, let timestamp = timestampEpochMicros, timestamp.isFinite {
            let rate = playbackRate ?? 1
            if rate.isFinite {
                result += max(0, date.timeIntervalSince1970 - timestamp / 1_000_000) * max(0, rate)
            }
        }
        return max(0, duration > 0 ? min(duration, result) : result)
    }

    public static func timeLabel(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let value = Int(min(seconds, 359_999))
        if value >= 3600 { return String(format: "%d:%02d:%02d", value / 3600, value / 60 % 60, value % 60) }
        return String(format: "%d:%02d", value / 60, value % 60)
    }
}

public struct PlaybackEvent: Decodable {
    public let type: String
    public let diff: Bool
    public let payload: Playback
}

/// A stream read may contain half a JSON line or several lines at once.
public struct LineBuffer {
    private var pending = Data()
    public init() {}
    public mutating func append(_ data: Data) -> [Data] {
        pending.append(data)
        var lines: [Data] = []
        while let end = pending.firstIndex(of: 10) {
            lines.append(Data(pending[..<end]))
            pending.removeSubrange(...end)
        }
        // Bound memory if a damaged helper never emits a newline.
        if pending.count > 16 * 1024 * 1024 { pending.removeAll() }
        return lines
    }
}
