# sonic-iris
Turn a song into an iris using FFT.

Eye Spectrum is a Processing visualization that transforms an audio signal into a
circular, eye-like spectrum.

The visualization analyzes the audio using FFT and progressively draws radial
frequency information around a circle. The angular displacement uses the golden
ratio to produce a visually distributed and non-repetitive pattern.

![Eye Spectrum example](example.png)

## Features

- WAV and MP3 audio input
- FFT-based audio analysis
- Circular / radial visualization
- Golden-ratio angular distribution
- Automatic output filenames based on the selected song
- JPG image export
- MP4 video export
- Audio file selection through a file dialog
- Processing 4 compatible

## How it works

The audio is divided into FFT windows.

Each FFT window produces one radial line:

    Audio
       |
       v
    FFT window
       |
       v
    Frequency spectrum
       |
       v
    Radial line
       |
       v
    Next angle

The angular step is based on the golden ratio:

```java
float angleStep = TWO_PI * 0.61803398875;
