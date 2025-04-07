import pandas as pd
import matplotlib.pyplot as plt

# Load CSV files
centerline = pd.read_csv('/Users/vaughnramsey/Desktop/MOOSE 2/SteadyState/steady_state_T_line_x0_0002.csv')
surface = pd.read_csv('/Users/vaughnramsey/Desktop/MOOSE 2/SteadyState/steady_state_T_line_x05_0002.csv')
inner_clad = pd.read_csv('/Users/vaughnramsey/Desktop/MOOSE 2/SteadyState/steady_state_T_line_x0505_0002.csv')
outer_clad = pd.read_csv('/Users/vaughnramsey/Desktop/MOOSE 2/SteadyState/steady_state_T_line_x0605_0002.csv')

# Set up a 2x2 subplot
fig, axs = plt.subplots(2, 2, figsize=(12, 8))
fig.suptitle('Steady State Temperature Profiles')

# Plot centerline
axs[0, 0].plot(centerline['y'], centerline['T'], label='Centerline')
axs[0, 0].set_title('Centerline')
axs[0, 0].set_xlabel('Axial Position (cm)')
axs[0, 0].set_ylabel('Temperature (K)')

# Plot surface
axs[0, 1].plot(surface['y'], surface['T'], label='Surface', color='orange')
axs[0, 1].set_title('Surface')
axs[0, 1].set_xlabel('Axial Position (cm)')
axs[0, 1].set_ylabel('Temperature (K)')

# Plot inner cladding
axs[1, 0].plot(inner_clad['y'], inner_clad['T'], label='Inner Cladding', color='green')
axs[1, 0].set_title('Inner Cladding')
axs[1, 0].set_xlabel('Axial Position (cm)')
axs[1, 0].set_ylabel('Temperature (K)')

# Plot outer cladding
axs[1, 1].plot(outer_clad['y'], outer_clad['T'], label='Outer Cladding', color='red')
axs[1, 1].set_title('Outer Cladding')
axs[1, 1].set_xlabel('Axial Position (cm)')
axs[1, 1].set_ylabel('Temperature (K)')

# Improve layout
for ax in axs.flat:
    ax.grid(True)

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig("temperature_quadrant_plot.png")
plt.show()
