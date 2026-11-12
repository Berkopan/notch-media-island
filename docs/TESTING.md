# Verification

## Automated

Run `swift test --disable-sandbox` for timeline extrapolation, paused state, future timestamps, live streams, empty metadata, stream chunk boundaries and time formatting. Run `bash scripts/build.sh` for compilation, helper framework assembly and local signing.

## On-device checklist

1. Launch the app; check the menu bar waveform and the island centered over the built-in notch.
2. Hover over the notch and verify that all content is below the camera housing. Leave the island and verify delayed collapse.
3. With no active Now Playing session, verify the empty state.
4. Play media in a macOS Now Playing-compatible player. Verify title, artist, artwork and progress. Try a browser source as well.
5. Pause and resume; the timer must freeze while paused. Skip in both directions using a source with a queue.
6. Drag the seek slider forwards and backwards; confirm the source player's position changes. Move the mouse outside while dragging; the panel should remain open until release.
7. Change tracks during a drag; the old position must not be sent to the new track.
8. Try a live stream or a source without duration; verify seeking is disabled.
9. Switch the active source using macOS; the island should follow the active session.
10. Check full-screen apps, Spaces, display disconnect/reconnect, sleep/wake and Reduce Motion.
11. Verify clicks beside the island reach the underlying app. Use the menu to hide/show, reconnect and quit; quitting should stop the helper process.

Automated checks do not prove compatibility with every player or future macOS version. The helper command's success only confirms that the command was dispatched, not that the player honored it.
