import AppKit
import SwiftUI
import IslandCore

private struct PreviewScene: View {
    let closed: IslandState
    let opened: IslandState
    let media: MediaService

    var body: some View {
        HStack(spacing: 24) {
            panel(state: closed, label: "At rest")
            panel(state: opened, label: "On hover")
        }
        .padding(24)
        .frame(width: 920, height: 306)
        .background(Color(red: 0.055, green: 0.062, blue: 0.078))
        .transaction { $0.disablesAnimations = true }
    }

    private func panel(state: IslandState, label: String) -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                LinearGradient(colors: [Color(red: 0.20, green: 0.24, blue: 0.29), Color(red: 0.11, green: 0.13, blue: 0.17)], startPoint: .topLeading, endPoint: .bottomTrailing)
                IslandView(state: state, media: media)
            }
            .frame(width: 424, height: 224)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

@main
struct ReadmePreview {
    @MainActor
    static func main() throws {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.prohibited)
        let fixture = Data(#"{"bundleIdentifier":"example.preview","title":"Evening Drift","artist":"Sample Artist","playing":true,"durationMicros":214000000,"elapsedTimeMicros":74000000,"playbackRate":1}"#.utf8)
        let media = MediaService(preview: try JSONDecoder().decode(Playback.self, from: fixture), artwork: artwork())
        let closed = IslandState()
        let opened = IslandState()
        opened.expanded = true
        let view = NSHostingView(rootView: PreviewScene(closed: closed, opened: opened, media: media))
        let bounds = NSRect(x: 0, y: 0, width: 920, height: 306)
        let window = NSWindow(contentRect: bounds, styleMask: .borderless, backing: .buffered, defer: false)
        window.contentView = view
        view.frame = bounds
        view.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1840, pixelsHigh: 612,
                                      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                      isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        bitmap.size = bounds.size
        view.cacheDisplay(in: bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try withoutMetadata(png).write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
        print("Rendered documentation preview with fictional metadata.")
    }

    private static func withoutMetadata(_ png: Data) -> Data {
        // AppKit can add EXIF data even to an offscreen render. Keep only image
        // chunks so documentation assets never acquire machine-specific metadata.
        var result = Data(png.prefix(8))
        var offset = 8
        while offset + 12 <= png.count {
            let size = png[offset..<(offset + 4)].reduce(0) { ($0 << 8) | Int($1) }
            let end = offset + size + 12
            guard end <= png.count else { break }
            let type = String(decoding: png[(offset + 4)..<(offset + 8)], as: UTF8.self)
            if !["eXIf", "tEXt", "zTXt", "iTXt", "tIME"].contains(type) {
                result.append(png[offset..<end])
            }
            offset = end
        }
        return result
    }

    @MainActor
    private static func artwork() -> NSImage {
        // Original geometric artwork; no copyrighted album cover or external asset.
        NSImage(size: NSSize(width: 88, height: 88), flipped: false) { rect in
            NSGradient(starting: NSColor(red: 0.22, green: 0.36, blue: 0.43, alpha: 1),
                       ending: NSColor(red: 0.07, green: 0.13, blue: 0.21, alpha: 1))!.draw(in: rect, angle: -90)
            NSColor(red: 0.88, green: 0.77, blue: 0.57, alpha: 1).setFill()
            NSBezierPath(ovalIn: NSRect(x: 46, y: 42, width: 21, height: 21)).fill()
            let hill = NSBezierPath()
            hill.move(to: .zero)
            hill.line(to: NSPoint(x: 0, y: 28))
            hill.curve(to: NSPoint(x: 88, y: 34), controlPoint1: NSPoint(x: 25, y: 54), controlPoint2: NSPoint(x: 57, y: 7))
            hill.line(to: NSPoint(x: 88, y: 0))
            hill.close()
            NSColor(red: 0.12, green: 0.24, blue: 0.28, alpha: 1).setFill()
            hill.fill()
            return true
        }
    }
}
