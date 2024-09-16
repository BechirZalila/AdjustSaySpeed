#!/bin/bash

# Automatically adjust the speech rate so that the generated audio
# file lasts a specified duration.

# Default values
VOICE="Thomas"
RATE=200
TARGET_DURATION=1200  # Default target duration in seconds (20 minutes)
MARGIN=5              # Default acceptable margin in seconds
MAX_ITER=20           # Maximum number of iterations to avoid infinite loops
SCALING_FACTOR=0.5    # Adjust this factor between 0 and 1 for convergence control

# Check if the script is running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script can only be run on macOS."
    exit 1
fi

# Function to display script usage
usage() {
    cat << EOF
Usage: $0   [-v voice] [-r rate] [-t duration] [-m margin] [-M max_iter] input_text_file output_audio_file
  -v voice           Voice to use (default: Thomas)
  -r rate            Initial speech rate in words per minute (default: 200)
  -t duration        Target duration in seconds (default: 1200 seconds for 20 minutes)
  -m margin          Acceptable margin of error in seconds (default: 5 seconds)
  -M max_iter        Maximum number of iterations
  -s scaling factor  Adjust this factor between 0 and 1 for convergence control
  input_text_file  Input text file (.txt)
  output_audio_file Output audio file (.aiff)
EOF
    exit 1
}

# Parse options
while getopts ":v:r:t:m:M:s:" opt; do
    case $opt in
        v)
            VOICE="$OPTARG"
            ;;
        r)
            RATE="$OPTARG"
            ;;
        t)
            TARGET_DURATION="$OPTARG"
            ;;
        m)
            MARGIN="$OPTARG"
            ;;
        M)
            MAX_ITER="$OPTARG"
            ;;
        s)
            SCALING_FACTOR="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Shift parameters to get positional arguments
shift $((OPTIND -1))

# Check if the correct number of positional arguments remains
if [ "$#" -ne 2 ]; then
    usage
fi

# Get the input and output file names
INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if the input text file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "The input file '$INPUT_FILE' does not exist."
    exit 1
fi

ITER=0

while [ $ITER -lt $MAX_ITER ]; do
    # Generate the audio file with the current speech rate
    say -v "$VOICE" -r "$RATE" -f "$INPUT_FILE" -o "$OUTPUT_FILE"
    
    # Get the duration of the audio file using afinfo
    DURATION=$(afinfo "$OUTPUT_FILE" | grep "estimated duration" | awk '{print $3}')

    # Check if the duration is valid
    if [ -z "$DURATION" ]; then
        echo "Error retrieving the duration of the audio file."
        exit 1
    fi
    
    # Calculate the difference between the current duration and the
    # target duration
    DIFF=$(echo "$DURATION - $TARGET_DURATION" | bc)
    DIFF_ABS=$(echo "${DIFF#-}")

    echo "Iteration $ITER: Rate=$RATE WPM, Duration=$DURATION seconds, Difference=$DIFF seconds"

    # Check if the duration is within the acceptable margin
    if (( $(echo "$DIFF_ABS < $MARGIN" | bc -l) )); then
        echo "Desired duration achieved."
        break
    fi

    # Calculate the new rate based on the ratio of target duration to
    # current duration Apply a scaling factor to control adjustment
    # magnitude

    NEW_RATE=$(echo "$RATE * (1 + ($DIFF / $DURATION) * $SCALING_FACTOR)" | bc -l)
    NEW_RATE=$(LC_NUMERIC=C printf "%.0f" "$NEW_RATE")  # Format to two decimal places

    # Ensure the new rate is positive and within reasonable bounds
    if (( $(echo "$NEW_RATE <= 0" | bc -l) )); then
        echo "Speech rate has become negative or zero. Exiting script."
        exit 1
    fi

    # Update the rate for the next iteration
    RATE="$NEW_RATE"

    # Increment the iteration counter
    ITER=$((ITER + 1))
done

echo "Final rate=$RATE WPM, Final duration=$DURATION seconds"
