# Documentation preview

`preview.png` shows the actual `IslandView` in collapsed and expanded states, rendered offscreen on macOS. The surrounding background is illustrative; it is not a screenshot of anyone's desktop. Track metadata is fictional and the geometric cover is original artwork drawn by the rendering script. No live media data, personal desktop, external album artwork or system screenshot permissions are used.

Regenerate after UI changes:

```sh
bash scripts/render-preview.sh
```

The script compiles the existing UI with a `README_PREVIEW` fixture initializer, which is excluded from normal application builds. It never starts the MediaRemote service. Preview source and original artwork use the repository's MIT license. System controls/symbols are shown as part of the macOS application UI, not distributed as standalone symbol assets.
