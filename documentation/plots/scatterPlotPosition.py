import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

def plotpath(logFileName):
    data = np.genfromtxt(logFileName, delimiter=' ', names=['time', 'x', 'y', 'z'])
    fig = plt.figure()

    ax1 = fig.add_subplot(111)
    #ax1.plot(data['x'], data['y'], color='r') 
    ax1.scatter(data['x'], data['y'], color='r')
    ax1.plot([0,-4,-4,0,0], [0,0,3,3,0], color='black')
    #ax1.set_ylim([-10,3])
    #ax1.set_xlim([-4,0])
    fig.savefig('pos.png')

plotpath('simulationPosition20151216140935.log')
#plotpath('logExampleArenaBoundaries.log')    
