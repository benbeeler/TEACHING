
import pandas as pd
import os
# Loop over all refinement levels
for ny in range(10, 120, 10):
    prefix = f'ny{ny}_line'
    print(f"Processing {prefix}...")
    # Load all files
    df0 = pd.read_csv(f'csvs/{prefix}_T_line_x0_0002.csv')
    df1 = pd.read_csv(f'csvs/{prefix}_T_line_x05_0002.csv')
    df2 = pd.read_csv(f'csvs/{prefix}_T_line_x0505_0002.csv')
    df3 = pd.read_csv(f'csvs/{prefix}_T_line_x0605_0002.csv')
    print(df0.columns)
    print(df0.head())
    # Combine them into one DataFrame using arc_length as index
    df = pd.DataFrame({
        'y': df0['y'],
        'T_x0': df0['T'],
        'T_x05': df1['T'],
        'T_x0505': df2['T'],
        'T_x0605': df3['T'],
    })

    # Save to single file
    df.to_csv(f'{prefix}_combined.csv', index=False)
