# Turntable Controller

Turntable Controller is a compact SketchUp extension for controlling and timing
a theatrical revolve directly inside the model.

Mark important revolve positions as named pegs, click a peg to return to its
exact angle, or move the main slider for real-time control. Transitions can be
immediate or timed, with adjustable revolution speed, route, repetition and
acceleration/deceleration.

Peg names, angles and controller settings are stored inside the SketchUp model.
There are no sidecar files, accounts, analytics or network requirements.

## Features

- Real-time Z-axis rotation of a group or component named `#Turntable#`
- Model-embedded named angle pegs
- Immediate or timed movement to exact angles
- Adjustable seconds per 360-degree revolution
- Linear-to-accelerated/decelerated motion control
- Short-route and long-route movement
- Option-click on macOS or Alt-click on Windows for a temporary long route
- Four-pixel magnetic snapping to stored pegs
- Compact, freely resizable controller
- Integrated light/dark-mode Quick Guide

## Installation

1. Download the [prepared 1.0.1 maintenance build](release/Turntable_Controller_1.0.1.rbz?raw=true). See its [release notes](RELEASE_NOTES.md) and [checksum](release/SHA256SUMS-1.0.1.txt).
2. In SketchUp, open **Extension Manager**.
3. Choose **Install Extension** and select the RBZ.

## Setup

1. Select the complete revolve group or component.
2. In Entity Info or Outliner, name it `#Turntable#`.
3. Open **Extensions → Turntable**.

The `?` button opens the complete Quick Guide.

## Compatibility

Confirmed in SketchUp 2026 on macOS and developed from a controller previously
used with SketchUp 2023. It uses long-established SketchUp APIs and should work
with other desktop versions supporting `HtmlDialog`. Reports from Windows and
earlier SketchUp versions are welcome.

The 1.0.1 maintenance build includes the current undo, read-only controller
refresh and macOS window-closing corrections. Package integrity and Ruby syntax
are checked; final interactive undo and close/quit checks remain to be confirmed.
Windows runtime testing and Extension Warehouse approval are not asserted.

## Support

Please use GitHub Issues. Include your SketchUp version, operating system, a
short description of what happened and, where useful, a screenshot or minimal
model that reproduces the problem.

If this free tool helps your work, you can [buy me a coffee on Ko-fi](https://ko-fi.com/samtsham). Contributions are entirely optional and help keep all three plugins free and maintained.

## Licence

Freeware released under the [Apache License 2.0](LICENSE). Copyright © 2026
Sam Madwar. Redistributed derivatives must retain the attribution in [NOTICE](NOTICE).
