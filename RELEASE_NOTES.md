# Turntable Controller 1.0.1 — prepared maintenance build

This maintenance release makes all model changes explicit user actions and gives
each action a single, descriptive Undo entry.

## Corrections

- Opening, focusing or refreshing the controller no longer writes to the model.
- Immediate rotations and complete slider drags are each combined into one Undo step.
- Slider dragging continues to rotate and redraw the model live.
- An entire timed transition is combined into one Undo step.
- Speed, easing and named-peg changes use descriptive Undo operations.
- Animation updates now run at a realistic interval of approximately 30 ms.
- Closing the controller releases its dialog reference cleanly.
- The controller uses a non-modal utility palette and releases its dialogs at shutdown so it does not block model-window closing or quitting SketchUp on macOS.
- The missing-turntable notice clears as soon as a valid `#Turntable#` group is found.
- Previously silent Ruby errors are now reported instead of being hidden.

Turntable Controller is a compact SketchUp extension for controlling a theatrical revolve directly in the model. It combines real-time rotation, named positions and production-oriented transition timing in a freely resizable palette.

## Highlights

- Real-time control of a group or component designated `#Turntable#`
- Named angle pegs stored inside each `.skp` model
- Reliable restoration when opening, restoring or switching models
- Animated or immediate movement to exact angles
- Adjustable seconds per 360° revolution
- Linear-to-accelerated/decelerated motion curve
- Short-route and long-route movement
- Option-click on Mac or Alt-click on Windows for a temporary long-route move
- Four-pixel magnetic snapping to stored pegs
- Add, delete, rename and edit peg angles
- Optional running number suggested when naming each new peg
- Compact default layout with fully resizable precision control
- Integrated light/dark-mode Quick Guide
- No sidecar files

## Installation

1. In SketchUp, open **Extension Manager**.
2. Choose **Install Extension**.
3. Select `Turntable_Controller_1.0.1.rbz`.

## Setup

Select the complete revolve group or component and enter `#Turntable#` as its Instance or Name value in Entity Info, or rename it in Outliner. Open **Extensions → Turntable**.

Use the `?` button in the controller for the complete Quick Guide.

## Requirements

Tested in SketchUp 2026 and developed from a controller previously used in SketchUp 2023. It uses long-established SketchUp APIs and is expected to work in other HtmlDialog-era desktop versions. Feedback from earlier versions is welcome.

## Author

Sam Madwar

## Validation status

The prepared archive passes integrity and Ruby syntax checks. Final interactive
checks remain: open and close an unchanged model without a save prompt; verify
one Undo for an immediate move, a full slider drag and a timed transition;
verify model-window closing and quitting with the palette open. Windows runtime
testing is unconfirmed. This GitHub build does not imply Warehouse approval.
