#This script generates the plots of axial height vs. time, as well as max temp. vs. time
import os
import re
import pandas as pd
import matplotlib.pyplot as plt

directory = '/Users/vaughnramsey/Desktop/MOOSE 2/Transient Data'
line_types = ['centerline', 'surface', 'IC', 'OC']
line_types = ['centerline', 'surface', 'IC', 'OC']
y_results = {name: [] for name in line_types}
T_results = {name: [] for name in line_types}
times = []

pattern = re.compile(r'transient_(\w+?)_(\d{4})\.csv')

for filename in sorted(os.listdir(directory)):
    match = pattern.match(filename)
    if match:
        line_type, index = match.groups()
        index = int(index)
        time = index * 0.1

        if line_type in line_types:
            df = pd.read_csv(os.path.join(directory, filename))
            if not df.empty:
                idx_max = df['T'].idxmax()
                y_max = df.loc[idx_max, 'y']
                T_max = df.loc[idx_max, 'T']

                y_results[line_type].append(y_max)
                T_results[line_type].append(T_max)

                if line_type == 'centerline':
                    times.append(time)

# Plot two panes side-by-side
fig, axs = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Max Temperature and its Axial Location vs Time')

# Left: y(T_max) vs time
for line_type in line_types:
    axs[0].plot(times, y_results[line_type], label=line_type)
axs[0].set_title('Axial Location (y) of Max Temperature')
axs[0].set_xlabel('Time (s)')
axs[0].set_ylabel('y (cm)')
axs[0].legend()
axs[0].grid(True)

# Right: T_max vs time
for line_type in line_types:
    axs[1].plot(times, T_results[line_type], label=line_type)
axs[1].set_title('Maximum Temperature')
axs[1].set_xlabel('Time (s)')
axs[1].set_ylabel('Max. Temperature (K)')
axs[1].legend()
axs[1].grid(True)

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig("y_and_T_max_vs_time.png")
plt.show()