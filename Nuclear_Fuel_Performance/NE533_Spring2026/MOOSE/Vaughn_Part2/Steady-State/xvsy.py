import pyvista as pv
import numpy as np
import matplotlib.pyplot as plt

# Load Exodus MultiBlock output
filename = "/Users/vaughnramsey/Desktop/MOOSE 2/steady_state_exodus.e"
multi = pv.read(filename)

# Choose a valid time step
time_index = 0
subblocks = multi[time_index]

# Define materials and colors
material_labels = ['Fuel', 'Gap', 'Cladding']
material_colors = ['red', 'orange', 'blue']

plt.figure(figsize=(10, 6))

# Loop over sub-blocks (materials)
for i, block in enumerate(subblocks):
    if isinstance(block, pv.UnstructuredGrid) and 'T' in block.point_data:
        coords = block.points
        T = block.point_data['T']

        x_vals = np.linspace(coords[:, 0].min(), coords[:, 0].max(), 40)
        y_max_per_x = []

        for x in x_vals:
            mask = np.isclose(coords[:, 0], x, atol=0.005)
            if np.any(mask):
                y_vals = coords[mask][:, 1]
                T_vals = T[mask]
                y_max = y_vals[np.argmax(T_vals)]
                y_max_per_x.append(y_max)
            else:
                y_max_per_x.append(np.nan)

        plt.plot(x_vals, y_max_per_x,
                 color=material_colors[i],
                 label=material_labels[i])

# Final plot formatting
plt.xlabel("Radial Position (x)")
plt.ylabel("Axial Position of Max Temperature (y)")
plt.title("y(T_max) vs. x at Time Step 0")
plt.grid(True)
plt.legend()
plt.tight_layout()
# Save the plot
plt.savefig("y_vs_x_at_time_step_0.png")
plt.show()
