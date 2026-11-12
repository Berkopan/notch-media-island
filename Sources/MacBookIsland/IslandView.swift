import SwiftUI
import IslandCore

@MainActor
final class IslandState: ObservableObject {
    @Published var expanded = false
    @Published var notchWidth: CGFloat = 200
    @Published var notchHeight: CGFloat = 32
    var scrubbing = false
    let width: CGFloat = 432
    var height: CGFloat { notchHeight + 192 }
}

struct IslandShape: Shape {
    var radius: CGFloat
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, rect.height / 2)
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: r, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - r), control: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct IslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var media: MediaService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: state.notchHeight)
            if state.expanded {
                Group {
                    if media.playback.hasMedia {
                        player
                    } else {
                        emptyState
                    }
                }
                .frame(height: 192)
                .transition(.opacity)
            }
        }
        .frame(width: state.expanded ? state.width : state.notchWidth,
               height: state.expanded ? state.height : state.notchHeight, alignment: .top)
        .background(.black)
        .clipShape(IslandShape(radius: state.expanded ? 28 : 10))
        .shadow(color: .black.opacity(state.expanded ? 0.3 : 0), radius: 18, y: 8)
        .animation(reduceMotion ? .none : .spring(response: 0.36, dampingFraction: 0.84), value: state.expanded)
        .frame(width: state.width + 40, height: state.height + 30, alignment: .top)
        .preferredColorScheme(.dark)
    }

    private var player: some View {
        VStack(spacing: 13) {
            HStack(spacing: 13) {
                Group {
                    if let artwork = media.artwork {
                        Image(nsImage: artwork).resizable().scaledToFill()
                    } else {
                        ZStack {
                            Color(white: 0.13)
                            Image(systemName: "music.note").font(.system(size: 22)).foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5) {
                    Text(media.playback.title ?? "Şu an çalıyor")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white).lineLimit(1)
                    Text(media.playback.artist ?? sourceName)
                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
                }
                Spacer(minLength: 4)
            }
            TimelineView(.periodic(from: .now, by: 0.1)) { context in
                SeekBar(playback: media.playback, date: context.date, state: state, seek: media.seek)
            }
            HStack(spacing: 27) {
                control("backward.end.fill", label: "Önceki", size: 16, disabled: media.playback.prohibitsSkip == true) { media.send(5) }
                control(media.playback.playing == true ? "pause.fill" : "play.fill",
                        label: media.playback.playing == true ? "Duraklat" : "Oynat", size: 23) { media.send(2) }
                control("forward.end.fill", label: "Sonraki", size: 16, disabled: media.playback.prohibitsSkip == true) { media.send(4) }
            }
            .frame(height: 29)
            .overlay(alignment: .trailing) {
                if media.errorMessage != nil {
                    Image(systemName: "exclamationmark.circle").foregroundStyle(.secondary)
                        .help(media.errorMessage ?? "")
                }
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    private var sourceName: String {
        guard let id = media.playback.bundleIdentifier,
              let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) else { return "Şu an çalıyor" }
        return url.deletingPathExtension().lastPathComponent
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: media.errorMessage == nil ? "waveform" : "exclamationmark.circle")
                .font(.system(size: 25, weight: .light)).foregroundStyle(.white.opacity(0.5))
            Text(media.errorMessage ?? "Biraz müzik iyi gider.")
                .font(.system(size: 14, weight: .medium))
            if media.errorMessage == nil {
                Text("Çalmaya başladığında burada görünecek.")
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.4))
            } else {
                Button("Yeniden bağlan") { media.start() }.buttonStyle(.plain).foregroundStyle(.secondary)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func control(_ symbol: String, label: String, size: CGFloat, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: size, weight: .semibold))
                .frame(width: 36, height: 32).contentShape(Rectangle())
        }
        .buttonStyle(.plain).disabled(disabled).opacity(disabled ? 0.3 : 1)
        .accessibilityLabel(label).help(label)
    }
}

private struct SeekBar: View {
    let playback: Playback
    let date: Date
    @ObservedObject var state: IslandState
    let seek: (Double) -> Void
    @State private var dragged: Double?
    @State private var dragIdentity: String?

    private var position: Double { dragged ?? playback.elapsed(at: date) }
    var body: some View {
        VStack(spacing: 3) {
            Slider(value: Binding(get: { min(position, max(1, playback.duration)) }, set: { dragged = $0 }),
                   in: 0...max(1, playback.duration), onEditingChanged: { editing in
                state.scrubbing = editing
                if editing {
                    dragIdentity = playback.identity
                } else {
                    if let dragged, dragIdentity == playback.identity { seek(dragged) }
                    dragged = nil
                    dragIdentity = nil
                }
            })
            .tint(.white.opacity(0.8))
            .controlSize(.mini)
            .disabled(!playback.canSeek)
            .accessibilityLabel("Oynatma konumu")
            .accessibilityValue(Playback.timeLabel(position))
            HStack {
                Text(Playback.timeLabel(position))
                Spacer()
                Text(playback.duration > 0 ? "−" + Playback.timeLabel(max(0, playback.duration - position)) : "CANLI")
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.4))
        }
        .onChange(of: playback.identity) { _, _ in dragged = nil }
        .onDisappear { state.scrubbing = false }
    }
}
