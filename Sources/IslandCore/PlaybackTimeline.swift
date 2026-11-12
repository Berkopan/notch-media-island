import Foundation

/// Keeps the displayed clock separate from MediaRemote's last position report.
/// A player can update `playing` while retaining an old elapsed time, timestamp
/// and even a nonzero playback rate. That old position is not a new seek.
public struct PlaybackTimeline {
    public private(set) var playback = Playback()
    private var source: Playback?

    public init() {}

    public mutating func receive(_ incoming: Playback, at date: Date = Date()) -> Playback {
        var next = incoming
        if let source, incoming.hasMedia,
           source.identity == incoming.identity,
           source.elapsedTimeMicros == incoming.elapsedTimeMicros,
           source.timestampEpochMicros == incoming.timestampEpochMicros {
            // Freeze at the current displayed position on pause; resume from
            // that same position, excluding all time spent paused. Metadata-only
            // updates also retain the clock instead of resetting it backwards.
            next.elapsedTimeMicros = playback.elapsed(at: date) * 1_000_000
            next.timestampEpochMicros = date.timeIntervalSince1970 * 1_000_000
        }
        source = incoming
        playback = next
        return next
    }
}
