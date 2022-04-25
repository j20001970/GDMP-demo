# GDMP Demo
This is the demo project for [GDMP](https://github.com/j20001970/GDMP) plugin.

Current Godot project version: 3.4.4.stable

Current supported platforms:

- Android
- GNU/Linux desktop

## Getting Started
The demo comes with precompiled libraries, simply export the project to supported platform and make sure associated plugins are enabled in export options. You can also build the libraries yourself.

1. Follow [Getting Started](https://github.com/j20001970/GDMP#getting-started) to complete the setup.
2. Add calculator dependencies in `mediapipe/GDMP/calculators.bzl`
3. Run `build.py` with the same usage as `GDMP/build.py`, the script will overlay mediapipe workspace with files in `mediapipe` during build process.
