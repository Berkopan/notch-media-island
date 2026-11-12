import Foundation

/// Keeps the displayed clock separate from MediaRemote's last position report.
/// A player can update `playing` while retaining an old elapsed time, timestamp
/// and even a nonzero playback rate. That old position is not a new seek.
public struct PlaybackTimeline {
    public private(set) var playback = Playback()
    private var source: Playback?
    private var pendingSeek: UUID?

    public init() {}

    /// Publish the user's position before the asynchronous player reply arrives.
    public mutating func seek(to seconds: Double, id: UUID, at date: Date = Date()) {
        guard playback.canSeek, seconds.isFinite else { return }
        pendingSeek = id
        playback.elapsedTimeMicros = max(0, min(playback.duration, seconds)) * 1_000_000
        playback.timestampEpochMicros = date.timeIntervalSince1970 * 1_000_000
    }

    /// Roll back a failed/unconfirmed request; an older request cannot cancel a newer one.
    @discardableResult
    public mutating func cancelSeek(id: UUID) -> Bool {
        guard pendingSeek == id else { return false }
        pendingSeek = nil
        playback = source ?? Playback()
        return true
    }

    public mutating func receive(_ incoming: Playback, at date: Date = Date()) -> Playback {
        var next = incoming
        if pendingSeek != nil {
            if !incoming.hasMedia || incoming.identity != playback.identity {
                pendingSeek = nil
            } else {
                let expected = playback.elapsed(at: date)
                let hasNewPosition = incoming.elapsedTimeMicros != source?.elapsedTimeMicros
                    || incoming.timestampEpochMicros != source?.timestampEpochMicros
                if hasNewPosition && abs(incoming.elapsed(at: date) - expected) <= 1.5 {
                    pendingSeek = nil
                    source = incoming
                    playback = incoming
                    return incoming
                }
                // Ignore stale reports and acknowledgements of earlier seeks,
                // while still honoring playback-state and metadata updates.
                next.elapsedTimeMicros = expected * 1_000_000
                next.timestampEpochMicros = date.timeIntervalSince1970 * 1_000_000
                source = incoming
                playback = next
                return next
            }
        }
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
