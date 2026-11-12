import Foundation
import XCTest
@testable import IslandCore

final class PlaybackTests: XCTestCase {
    func testSeekUpdatesImmediatelyAndIgnoresStaleReportsInBothDirections() throws {
        for target in [5.0, 50.0] {
            var timeline = PlaybackTimeline()
            var source = try decode(#"{"bundleIdentifier":"example.player","title":"Track","playing":true,"elapsedTimeMicros":30000000,"timestampEpochMicros":1000000000,"playbackRate":1,"durationMicros":60000000}"#)
            _ = timeline.receive(source, at: Date(timeIntervalSince1970: 1000))
            let id = UUID()
            timeline.seek(to: target, id: id, at: Date(timeIntervalSince1970: 1001))
            XCTAssertEqual(timeline.playback.elapsed(at: Date(timeIntervalSince1970: 1001)), target)
            let stale = timeline.receive(source, at: Date(timeIntervalSince1970: 1001.2))
            XCTAssertEqual(stale.elapsed(at: Date(timeIntervalSince1970: 1001.2)), target + 0.2, accuracy: 0.001)
            source.elapsedTimeMicros = target * 1_000_000
            source.timestampEpochMicros = 1_001_000_000
            _ = timeline.receive(source, at: Date(timeIntervalSince1970: 1001.3))
            XCTAssertFalse(timeline.cancelSeek(id: id), "Acknowledged seeks must not be rolled back by the timeout")
        }
    }

    func testRapidPausedSeeksIgnoreEarlierAcknowledgementAndTimeout() throws {
        var timeline = PlaybackTimeline()
        var source = try decode(#"{"bundleIdentifier":"example.player","title":"Track","playing":false,"elapsedTimeMicros":30000000,"timestampEpochMicros":1000000000,"durationMicros":60000000}"#)
        _ = timeline.receive(source)
        let first = UUID(), second = UUID()
        timeline.seek(to: 10, id: first)
        timeline.seek(to: 50, id: second)
        source.elapsedTimeMicros = 10_000_000
        source.timestampEpochMicros = 1_001_000_000
        XCTAssertEqual(timeline.receive(source).elapsed(), 50)
        XCTAssertFalse(timeline.cancelSeek(id: first))
        source.elapsedTimeMicros = 50_000_000
        source.timestampEpochMicros = 1_002_000_000
        XCTAssertEqual(timeline.receive(source).elapsed(), 50)
        XCTAssertFalse(timeline.cancelSeek(id: second))
    }

    func testUnconfirmedSeekRollsBackAndTrackChangeCancelsPendingSeek() throws {
        var timeline = PlaybackTimeline()
        var source = try decode(#"{"bundleIdentifier":"example.player","title":"Track","playing":false,"elapsedTimeMicros":30000000,"timestampEpochMicros":1000000000,"durationMicros":60000000}"#)
        _ = timeline.receive(source)
        let rejected = UUID()
        timeline.seek(to: 50, id: rejected)
        XCTAssertTrue(timeline.cancelSeek(id: rejected))
        XCTAssertEqual(timeline.playback.elapsed(), 30)
        let superseded = UUID()
        timeline.seek(to: 10, id: superseded)
        source.title = "New track"
        source.elapsedTimeMicros = 0
        XCTAssertEqual(timeline.receive(source).elapsed(), 0)
        XCTAssertFalse(timeline.cancelSeek(id: superseded))
    }

    private func decode(_ json: String) throws -> Playback {
        try JSONDecoder().decode(Playback.self, from: Data(json.utf8))
    }

    func testElapsedUsesTimestampAndPlaybackRate() throws {
        let media = try decode(#"{"playing":true,"elapsedTimeMicros":10000000,"timestampEpochMicros":1000000000,"playbackRate":2,"durationMicros":60000000}"#)
        XCTAssertEqual(media.elapsed(at: Date(timeIntervalSince1970: 1005)), 20)
        XCTAssertEqual(media.elapsed(at: Date(timeIntervalSince1970: 2000)), 60)
    }

    func testPausedPlaybackDoesNotAdvance() throws {
        let media = try decode(#"{"playing":false,"elapsedTimeMicros":10000000,"timestampEpochMicros":1000000000}"#)
        XCTAssertEqual(media.elapsed(at: Date(timeIntervalSince1970: 2000)), 10)
    }

    func testFutureTimestampNeverMovesPlaybackBackwards() throws {
        let media = try decode(#"{"playing":true,"elapsedTimeMicros":10000000,"timestampEpochMicros":2000000000}"#)
        XCTAssertEqual(media.elapsed(at: Date(timeIntervalSince1970: 1000)), 10)
    }

    func testLiveOrUnknownDurationCannotSeek() throws {
        let live = try decode(#"{"bundleIdentifier":"example.player","durationMicros":0,"elapsedTimeMicros":5000000}"#)
        XCTAssertTrue(live.hasMedia)
        XCTAssertFalse(live.canSeek)
        let known = try decode(#"{"bundleIdentifier":"example.player","durationMicros":60000000,"elapsedTimeMicros":5000000}"#)
        XCTAssertTrue(known.canSeek)
        let missingPosition = try decode(#"{"bundleIdentifier":"example.player","durationMicros":60000000}"#)
        XCTAssertFalse(missingPosition.canSeek)
    }

    func testFullEmptyPayloadClearsMedia() throws {
        let event = try JSONDecoder().decode(PlaybackEvent.self, from: Data(#"{"type":"data","diff":false,"payload":{}}"#.utf8))
        XCTAssertFalse(event.payload.hasMedia)
        XCTAssertFalse(event.payload.canSeek)
        XCTAssertEqual(event.payload.elapsed(), 0)
    }

    func testLineBufferHandlesChunkedUTF8AndMultipleEvents() {
        var buffer = LineBuffer()
        let bytes = Data("şarkı\nikinci\nson".utf8)
        XCTAssertTrue(buffer.append(bytes.prefix(1)).isEmpty)
        let lines = buffer.append(bytes.dropFirst())
        XCTAssertEqual(lines.map { String(decoding: $0, as: UTF8.self) }, ["şarkı", "ikinci"])
        XCTAssertEqual(buffer.append(Data("\n".utf8)), [Data("son".utf8)])
    }

    func testTimeLabelsHandleLongAndInvalidValues() {
        XCTAssertEqual(Playback.timeLabel(65), "1:05")
        XCTAssertEqual(Playback.timeLabel(3661), "1:01:01")
        XCTAssertEqual(Playback.timeLabel(-1), "0:00")
        XCTAssertEqual(Playback.timeLabel(.infinity), "0:00")
    }

    func testPauseWithStalePositionFreezesAndResumeExcludesPausedTime() throws {
        var timeline = PlaybackTimeline()
        var source = try decode(#"{"bundleIdentifier":"example.player","title":"Track","playing":true,"elapsedTimeMicros":10000000,"timestampEpochMicros":1000000000,"playbackRate":1,"durationMicros":60000000}"#)
        _ = timeline.receive(source, at: Date(timeIntervalSince1970: 1000))
        source.playing = false // Real players may leave every timing field unchanged.
        let paused = timeline.receive(source, at: Date(timeIntervalSince1970: 1002))
        XCTAssertEqual(paused.elapsed(at: Date(timeIntervalSince1970: 1005)), 12)
        // A later artwork/metadata event must not reintroduce the stale position.
        source.artworkData = "updated-artwork"
        let stillPaused = timeline.receive(source, at: Date(timeIntervalSince1970: 1007))
        XCTAssertEqual(stillPaused.elapsed(at: Date(timeIntervalSince1970: 1007)), 12)
        source.playing = true
        let resumed = timeline.receive(source, at: Date(timeIntervalSince1970: 1010))
        XCTAssertEqual(resumed.elapsed(at: Date(timeIntervalSince1970: 1010)), 12)
        XCTAssertEqual(resumed.elapsed(at: Date(timeIntervalSince1970: 1012)), 14)
    }

    func testFreshSeekAndTrackChangeReplaceTimeline() throws {
        var timeline = PlaybackTimeline()
        var source = try decode(#"{"bundleIdentifier":"example.player","title":"Track","playing":true,"elapsedTimeMicros":30000000,"timestampEpochMicros":1000000000,"playbackRate":1,"durationMicros":60000000}"#)
        _ = timeline.receive(source, at: Date(timeIntervalSince1970: 1000))
        source.elapsedTimeMicros = 5_000_000
        source.timestampEpochMicros = 1_002_000_000
        let sought = timeline.receive(source, at: Date(timeIntervalSince1970: 1002))
        XCTAssertEqual(sought.elapsed(at: Date(timeIntervalSince1970: 1002)), 5)
        source.title = "Next track"
        source.playing = false
        let next = timeline.receive(source, at: Date(timeIntervalSince1970: 1005))
        XCTAssertEqual(next.elapsed(at: Date(timeIntervalSince1970: 1005)), 5)
    }
}
