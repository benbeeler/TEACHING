import os
import re

# Set the directory containing your MOOSE output CSVs
directory = "./"  # or specify another path

# Regex to match files like steady_state_centerline_0034.csv
pattern = re.compile(r'.*_(\d{4})\.csv$')

for filename in os.listdir(directory):
    match = pattern.match(filename)
    if match:
        index = int(match.group(1))
        if index % 10 != 0:
            file_path = os.path.join(directory, filename)
            print(f"Deleting {file_path}")
            os.remove(file_path)
