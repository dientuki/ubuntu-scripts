#!/bin/bash

set -eu

# Define variables
DEVICE="mtp://motorola_motorola_one_hyper_ZY227LXGM3"
SOURCE_DIR="$HOME/Music"
DESTINATION_DIR="$DEVICE/android/Music"

# Declare global variables
declare -i added_files=0
declare -i updated_files=0

# Function to copy a file if it's new or size is different
copy_file_if_needed() {
    source_file="$1"
    relative_path="${source_file#$SOURCE_DIR}"
    destination_file="$DESTINATION_DIR$relative_path"
        
    # Check if the destination file already exists
    if ! gio info "$destination_file" &> /dev/null; then
        # Check if the destination directory exists or create it
        destination_dir="$(dirname "$destination_file")"
        if ! gio info "$destination_dir" &> /dev/null; then
            gio mkdir -p "$destination_dir"
        fi
        
        gio copy "$source_file" "$destination_file"
        added_files+=1
    else
		# Check if sizes are different
		source_size="$(stat -c%s "$source_file")"
		destination_size="$(gio info "$destination_file" | grep "standard::size:" | awk '{ print $2 }')"

		if [ "$source_size" -ne "$destination_size" ]; then
		    gio copy "$source_file" "$destination_file"
		    updated_files+=1
		fi
    fi
}

echo "Checking..."

# Check if the MTP device is mounted and ready
if ! gio mount -li | grep -q "$DEVICE"; then
    echo "MTP device is not mounted or not ready."
    exit 1
fi

# Check if the DEVICE is accessible by listing its contents
if ! gio list "$DEVICE" &> /dev/null; then
    echo "DESTINATION_PATH is not accessible."
    exit 1
fi

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist."
    exit 1
fi

# Check if the destination directory exists
if ! gio info "$DESTINATION_DIR" &> /dev/null; then
    echo "Destination directory does not exist or is not accessible."
    exit 1
fi

echo "Let's work"

total_files=$(find "$SOURCE_DIR" -type f -not -path '*/\.*' -not -name '.*' | wc -l)
current_file=0

# Loop through files in SOURCE_DIR and its subdirectories
while IFS= read -r file; do
    copy_file_if_needed "$file"
    current_file=$((current_file + 1))
    progress=$((current_file * 100 / total_files))
    echo -ne "Updating... $progress%\r"
done < <(find "$SOURCE_DIR" -type f -not -path '*/\.*' -not -name '.*')

echo

# Display the summary
echo "Added $added_files files, updated $updated_files files."
echo "Files copied successfully."
