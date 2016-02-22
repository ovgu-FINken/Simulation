import csv
import os
import numpy as np
import matplotlib.pyplot as plt

folder = '../../resources/logs/pyramid_noise/straight_noise/'

for d in os.listdir(folder):
    results = []
    for i, f in enumerate(os.listdir(os.path.join(folder, d))):
        results.extend([[]])
        with open(os.path.join(folder, d, f)) as csvfile:
            logreader = csv.reader(csvfile, delimiter=',')
            in_header = True
            for row in logreader:
                if in_header:
                    in_header = len(row) < 1 or row[0] != 'Time steps'
                else:
                    results[i].append(float(row[1]))

    for i, r in enumerate(results):
        results[i] = r[:3*60*20]

    results = np.array(results)

    x = np.array([i * 0.05 for i in range(3600)])

    mean_data = results.mean(0)
    std = results.std(0)
    lower = mean_data - std
    upper = mean_data + std
    linehandle = plt.plot(x.T, mean_data.T, label=d)
    plt.fill_between(x, lower.T, upper.T, alpha=0.1, color=linehandle[0].get_c())
    plt.legend(loc='best')
    plt.xlabel('time [s]')
    plt.ylabel('height')
    plt.title(folder.split('/')[-2])
plt.show()
# plt.figure()
#
# max_so_far = np.zeros(results.shape)
# col = np.array(results[:, 0])
# # print(col)
# for i in range(1, results.shape[1]):
#     col = np.maximum(col, results[:, i])
#     max_so_far[:, i] = col
#
# mean_data = max_so_far.mean(0)
# std = max_so_far.std(0)
# lower = mean_data - std
# upper = mean_data + std
# plt.plot(x.T, mean_data.T)
#
# plt.fill_between(x, lower.T, upper.T, alpha=0.3)
# plt.show()


