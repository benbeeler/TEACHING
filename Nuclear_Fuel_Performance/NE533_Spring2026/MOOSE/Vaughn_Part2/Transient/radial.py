import pandas as pd
import matplotlib.pyplot as plt

# Map of time to file suffix
time_to_file = {
    0.1: '0001',
    21.9: '0219',
    50.0: '0500',
}

# File base name
file_base = 'radial_radial_slice_'  # e.g. radial_radial_slice_0001.csv

# Prepare a figure
plt.figure(figsize=(10, 6))

# Loop through each time and file
for time, suffix in time_to_file.items():
    filename = f"{file_base}{suffix}.csv"
    try:
        df = pd.read_csv(filename)
        plt.plot(df['x'], df['T'], label=f't = {time:.1f} s')

    except FileNotFoundError:
        print(f"Warning: File {filename} not found. Skipping.")

# Final plot formatting
plt.title("Radial Temperature Profiles at Key Times (y=52.1[cm])")
plt.xlabel("Radius [cm]")
plt.ylabel("Temperature (K)")
plt.grid(True)
plt.legend()
plt.tight_layout()
plt.savefig("radial_profiles_selected_times.png")
plt.show()
