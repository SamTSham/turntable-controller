# Changelog

## 1.0.1 — 2026-08-14

- Prevented controller refreshes and focus events from modifying the model.
- Combined each slider drag, immediate move or animated move into one descriptive Undo operation.
- Preserved continuous viewport rotation throughout a slider drag.
- Added named Undo operations for speed, easing and named-peg changes.
- Reduced animation timer frequency to approximately 33 frames per second.
- Cleared the main dialog reference when its window closes.
- Cleared the missing-turntable notice when a valid target becomes available.
- Replaced silent Ruby exception handling with visible diagnostics.

## 1.0.0 — 2026-08-02

- First public release.
- Real-time theatrical revolve control with exact numeric entry.
- Named, model-embedded position pegs.
- Timed transitions with speed, repetition, route and easing controls.
- Magnetic snapping and modifier-click long-route movement.
- Compact resizable controller and integrated Quick Guide.
