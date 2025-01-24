#!/bin/bash

# Look for .zip files in the current directory
for zip_file in $(find . -type f -name "*.zip"); do
    echo "Found zip file: $zip_file"

    # Attempt to extract the zip file with the password "infected"
    unzip -P infected "$zip_file"
    if [ $? -eq 0 ]; then
        echo "Successfully extracted: $zip_file"
        echo "Delete zip file: $zip_file"
        rm "$zip_file"
    else
        echo "Failed to extract: $zip_file (wrong password or corrupted archive)"
    fi

done

# Look for a file with a name matching a SHA256 pattern
for sha256_file in $(find . -type f -regextype posix-extended -regex './[a-f0-9]{64}$'); do
    echo "Found SHA256 file: $sha256_file"

    # Run the specified Python command
    echo "Running: python pyinstxtractor.py $sha256_file"
    python pyinstxtractor.py "$sha256_file"

    # Delete the original SHA256 file
    echo "Deleting $sha256_file"
    rm "$sha256_file"

    # Check for .pyc files in the extracted directory
    extracted_dir="${sha256_file}_extracted"
    if [ -d "$extracted_dir" ]; then
        echo "Checking .pyc files in $extracted_dir"

        # List all .pyc files
        pyc_files=$(ls "$extracted_dir" | grep ".pyc$")
        echo "All .pyc files:"
        echo "$pyc_files"

        # List all .EXE files
        exe_files=$(ls "$extracted_dir" | grep ".exe$")
        echo ""
        echo "All .exe files:"
        echo "$exe_files"
        echo ""

        for pyc_file in $pyc_files; do
            # Check if the filename starts with "pyi" or is "struct"
            if [[ "$pyc_file" != pyi* && "$pyc_file" != struct* ]]; then
                echo ""
                echo ""
                echo "Found file: $pyc_file. Copying to current directory."
                echo ""
                cp "$extracted_dir/$pyc_file" .
            fi
        done
        echo ""
        echo "Removing dir: $extracted_dir"
        rm -rf $extracted_dir
    else
        echo "Extracted directory $extracted_dir not found."
    fi

done
