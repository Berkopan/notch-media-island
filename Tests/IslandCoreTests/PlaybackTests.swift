import Foundation
import XCTest
@testable import IslandCore

final class PlaybackTests: XCTestCase {
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
}
