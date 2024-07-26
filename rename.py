import os
import re
import argparse

# Set up argument parsing
parser = argparse.ArgumentParser(description='Rename files in a directory to remove invalid characters.')
parser.add_argument('directory', type=str, help='The directory to scan and rename files in.')

# Parse the command-line arguments
args = parser.parse_args()
directory = args.directory

# Check if the provided directory exists
if not os.path.isdir(directory):
    print(f"Error: The directory '{directory}' does not exist.")
    exit(1)

# Regex pattern to retain only alphanumeric characters, hyphens, spaces, and periods (for file extensions)
pattern = re.compile(r'[^a-zA-Z0-9\-\. ]')

# Scan the directory for .mp4 files
for filename in os.listdir(directory):
    if filename.endswith('.mp4'):
        # Create the new filename by removing invalid characters
        name, ext = os.path.splitext(filename)
        new_name = pattern.sub('', name) + ext

        # Define full paths for old and new filenames
        old_path = os.path.join(directory, filename)
        new_path = os.path.join(directory, new_name)

        # Rename the file if the new name is different
        if old_path != new_path:
            os.rename(old_path, new_path)
            print(f'Renamed "{filename}" to "{new_name}"')

print('File renaming complete.')
