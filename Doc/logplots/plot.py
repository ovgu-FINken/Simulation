import matplotlib.pyplot as plt
from os.path import expanduser

import numpy as np
import pandas as pd
home = expanduser("~")
df = pd.read_csv('circle.csv',sep='\t')
print(df)

y = df['y']
x = df['x']
time = df['Time']
time = time - 100
plt.plot(time, x, 'r-', label='x')
plt.plot(time, y, 'b-', label='y')
plt.legend(loc='upper left')
plt.xlabel('Time')
plt.ylabel('Position')
plt.savefig('circle.png')
plt.show()
