import pandas as pd
import numpy as np
import os

os.makedirs('ai-detector/data', exist_ok=True)

# Generate normal data
n_samples = 1000
normal_data = pd.DataFrame({
    'AIT201': np.random.normal(7.2, 0.1, n_samples),
    'FIT101': np.random.normal(1.5, 0.05, n_samples),
    'MV101': np.ones(n_samples),
    'Normal/Attack': ['Normal'] * n_samples
})
normal_data.to_csv('ai-detector/data/normal.csv', index=False)

# Generate attack data (some normal, some attacks)
a_samples = 200
attack_data = pd.DataFrame({
    'AIT201': np.random.normal(7.2, 0.1, a_samples),
    'FIT101': np.random.normal(1.5, 0.05, a_samples),
    'MV101': np.ones(a_samples),
    'Normal/Attack': ['Normal'] * a_samples
})

# Inject anomalies
attack_data.loc[150:180, 'AIT201'] = np.random.normal(9.5, 0.2, 31) # Huge pH spike
attack_data.loc[150:180, 'Normal/Attack'] = 'Attack'

attack_data.to_csv('ai-detector/data/attack.csv', index=False)
print("Synthetic data generated!")
