Automatically adjust the speech rate so that the generated audio file
lasts a specified duration.

This script uses the **say** command on macOS to generate an audio file
from a text file, adjusting the speech rate to match a target
duration.

# Table of Contents:
 - Prerequisites
 - Usage
   - Options
   - Examples
 - Description
   - Algorithm
   - Parameters
 - License
 - Acknowledgments
 - Disclaimer

# Prerequisites
 - macOS: This script can only be run on macOS, as it uses the say command, which is specific to macOS.
 - say command: Ensure that the say command is available on your system (it is installed by default on macOS).
 - afinfo utility: Used to obtain the duration of the audio file. It is part of the afplay package, which is also available by default on macOS.
 - bc: Used for floating-point calculations. It should be installed by default on macOS.

# Usage

```
./adjust_say_speed.sh [-v voice] [-r rate] [-t duration] [-m margin] [-M max_iter] [-s scaling_factor] input_text_file output_audio_file
```

# Options
 - -v voice
   Voice to use (default: Thomas)

 - -r rate
   Initial speech rate in words per minute (default: 200)

 - -t duration
   Target duration in seconds (default: 1200 seconds for 20 minutes)

 - -m margin
   Acceptable margin of error in seconds (default: 5 seconds)

 - -M max_iter
   Maximum number of iterations (default: 20)

 - -s scaling_factor
   Adjust this factor between 0 and 1 for convergence control (default: 0.5)

 - input_text_file
   Input text file (.txt)

 - output_audio_file
   Output audio file (.aiff)

# Examples

 - Generate an audio file from speech.txt, aiming for a duration of 20
   minutes:

```
./adjust_say_speed.sh speech.txt speech.aiff
```

 - Specify a different voice and initial rate:

```
./adjust_say_speed.sh -v Amelie -r 180 speech.txt speech.aiff
```

 - Set a target duration of 15 minutes (900 seconds) with a margin of 3 seconds:

```
./adjust_say_speed.sh -t 900 -m 3 speech.txt speech.aiff
```

 - Adjust the scaling factor for finer convergence control:

```
./adjust_say_speed.sh -s 0.3 speech.txt speech.aiff
```

# Description

This script adjusts the speech rate of the say command to generate an
audio file that matches a specified target duration. It does so by
iteratively adjusting the rate based on the difference between the
current audio duration and the target duration.

## Algorithm

1. Initialization:
  - Start with an initial speech rate (default: 200 WPM).
  - Set the target duration and acceptable margin.

2. Iteration:

  - Generate the audio file using the say command with the current rate.
  - Measure the duration of the generated audio file using afinfo.
  - Calculate the difference between the current duration and the target duration.
  - Adjust the speech rate based on this difference, applying a scaling factor to control the convergence.
  - Ensure the new rate is positive and within reasonable bounds.
  - Repeat the process until the duration is within the acceptable margin or the maximum number of iterations is reached.

3. Completion:
  - Output the final speech rate and duration achieved.

## Parameters

- Voice (-v):
  - You can specify any voice available in the say command.
  - Use say -v '?' to list available voices.
  - Examples: Thomas, Amelie, Alex, Victoria.
- Initial Speech Rate (-r):
  - Sets the starting words per minute for the speech.
  - Adjust if you know the approximate rate needed.
- Target Duration (-t):
  - The desired duration of the output audio file in seconds.
  - Default is 1200 seconds (20 minutes).
- Margin (-m):
  - The acceptable difference in seconds between the generated audio duration and the target duration.
  - A smaller margin results in a more precise duration but may require more iterations.
- Maximum Iterations (-M):
  - Limits the number of iterations to prevent infinite loops.
  - Default is 20 iterations.
- Scaling Factor (-s):
  - Controls how aggressively the speech rate is adjusted.
  - A value between 0 and 1.
  - Lower values make smaller adjustments, reducing the risk of overshooting.
  - Default is 0.5.

# License

This project is licensed under the MIT License - see the LICENSE file
for details.

# Acknowledgments

- macOS say Command: This script utilizes the say command available on macOS for text-to-speech conversion.
- Inspiration: Developed to facilitate the creation of audio files that match specific durations, useful for practicing speeches, presentations, or any timed audio content.
- Contributions: Feel free to contribute to this project by submitting issues or pull requests on GitHub.

# Disclaimer
- Operating System: This script is intended for use on macOS systems only.
- Accuracy: The generated duration may vary slightly due to system processing times and the natural variation in speech synthesis.
