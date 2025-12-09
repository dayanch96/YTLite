import re
import os

def extract_values_from_file(file_path):
    """
    Extracts keys that match the pattern @\"<some_text>_enabled\" from the given file.

    Args:
        file_path (str): The path to the file to be searched.

    Returns:
        list: A list of matching keys found in the file.
    """
    # Define the regex pattern to match the strings that resemble the given examples
    pattern = r'@\"[a-zA-Z0-9_]+_enabled\"'
    matches = []

    try:
        # Read the content of the file
        with open(file_path, 'r') as file:
            file_content = file.read()
        
        # Find all matches
        matches = re.findall(pattern, file_content)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return matches

def format_output(keys):
    """
    Formats the keys with indentation and line breaks if the segment exceeds 120 characters (116 excluding indentation).

    Args:
        keys (list): The list of keys to be formatted.

    Returns:
        str: A formatted string with the keys.
    """
    indent = " " * 4
    line_length_limit = 116  # Limit excluding indentation
    current_line = indent
    formatted_output = ""

    for key in keys:
        # Check if adding the next key would exceed the line length limit
        if len(current_line) + len(key) + 2 > line_length_limit:  # +2 accounts for the comma and space
            # Add the current line to the formatted output and start a new line
            formatted_output += current_line.rstrip(", ") + ",\n"
            current_line = indent  # Start a new indented line
        
        # Add the key to the current line
        current_line += key + ", "

    # Add the last line to the output
    formatted_output += current_line.rstrip(", ")  # Remove trailing comma and space from the final line
    return formatted_output

def find_and_extract_keys():
    """
    Recursively searches for .xm and .h files in the parent directory and extracts keys
    that match the pattern @\"<some_text>_enabled\". The matching keys are then printed
    with indentation and line breaks if the line exceeds 120 characters.
    Ignores SettingsKeys.h

    Usage:
        1. Place this script in the desired directory.
        2. Run the script with the command: python extract_keys.py
        3. The script will search for all .xm and .h files in the parent directory and
           print any matching keys it finds.

    Note:
        - The script searches the directory where it is located (the parent directory).
        - It only looks for files with extensions .xm and .h.
    """
    # Get the parent directory
    parent_directory = os.path.dirname(os.path.abspath(__file__))
    
    # Store the found keys
    found_keys = set()  # Use a set to automatically remove duplicates

    # Walk through the parent directory and find all .xm and .h files
    for root, dirs, files in os.walk(parent_directory):
        for file in files:
            if file.endswith(('.xm', '.h')):
                # Skip SettingsKeys.h
                if file == "SettingsKeys.h":
                    continue
                file_path = os.path.join(root, file)
                found_keys.update(extract_values_from_file(file_path))
    
    # Print the found keys with formatting
    if found_keys:
        sorted_keys = sorted(found_keys)
        print(format_output(sorted_keys))
    else:
        print("No keys found.")

if __name__ == "__main__":
    find_and_extract_keys()
