# mimir

Mimir is a command-line tool designed to enhance the traditional `sleep` command, offering an improved user experience with sound effects while your computer is sleeping.

## Features

- Replaces the standard `sleep` command with an enriched audio experience.
- Allows setting a specific duration for the sleep or an indefinite sleep mode until manually interrupted.
- Easy to use, with a simple command-line interface.

## How to Use

Mimir's arguments mirror the standard `sleep` command, with an added `inf` mode:

```bash
mimir NUMBER[SUFFIX]...
mimir inf
```

- `NUMBER[SUFFIX]`: A duration, as an integer or floating-point number. `SUFFIX` may be `s`, `m`, `h`, or `d`, for seconds, minutes, hours, or days (default `s`). With multiple arguments, mimir pauses for the sum of their values, just like `sleep`.
- `inf`: Sleep indefinitely until manually interrupted (e.g. with Ctrl+C). Cannot be combined with other arguments.
- `--help`: Display usage information and exit.
- `--version`: Display the version and exit.

The speed variation of the sound playback uses a fixed standard deviation and is not configurable via arguments.

Examples:

- `mimir 60`: Puts the computer to sleep for 60 seconds.
- `mimir 1m 30s`: Puts the computer to sleep for 90 seconds.
- `mimir inf`: Puts the computer to sleep indefinitely, until interrupted.

### Environment variables

- `MIMIR_AUDIO_DIR`: Overrides the directory Mimir looks in for `esleep1.wav`/`esleep2.wav`. Useful for running Mimir straight from a checkout, or for supplying your own sounds.

## Dependencies

Before using Mimir, ensure that you have the following dependencies installed on your system:

1. **Bash**: Mimir is a Bash script and requires a Unix-like environment to run. Most Linux distributions and macOS come with Bash pre-installed. For Windows, you can use WSL (Windows Subsystem for Linux).

2. **sox**: The 'sox' command is used for audio playback manipulation. It can be installed on most Unix-like operating systems.

   - On Ubuntu/Debian: `sudo apt-get install sox`
   - On Arch: `sudo pacman -S sox`
   - On Fedora: `sudo dnf install sox`
   - On macOS (using Homebrew): `brew install sox`
   - On NixOS/Nix: `nix-shell -p sox` (or use the provided `shell.nix`, see below)

3. **awk**: Used for the random speed/delay calculations. Pre-installed on virtually every Unix-like system.

4. **Hardware Compatibility**: The script is designed to run on systems with audio playback capability. Ensure your hardware and drivers support audio playback.

### Nix development shell

If you have Nix installed, `nix-shell` in the repository root drops you into a shell with all runtime dependencies (`bash`, `sox`, `gawk`) plus `shellcheck`, and points `MIMIR_AUDIO_DIR` at the sounds in this checkout so you can run `bash mimir.sh ...` directly without installing anything system-wide.

## Installation

To install mimir, follow these steps:

1. Clone the repository or download the source code.
2. Navigate to the source directory.
3. Run the installation script:

```bash
sudo ./install.sh
```

## Uninstallation

To uninstall mimir, simply run the uninstallation script:

```bash
sudo ./uninstall.sh
```

## Contributing

Pull requests are welcome! If you have suggestions for improvements or new features, feel free to submit a pull request or open an issue.

## License

```
MIT License

Copyright (c) 2023 FraioVeio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
