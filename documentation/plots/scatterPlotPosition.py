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

def plotLine(logFileName):
    data = np.genfromtxt(logFileName, delimiter=' ', names=['time', 'pitch', 'roll', 'yaw'])
    fig = plt.figure()

    ax1 = fig.add_subplot(111)
    ax1.plot(data['time'], data['roll'], color='r') 
    ax1.plot(data['time'], data['pitch'], color='g')
    #ax1.set_ylim([-10,3])
    #ax1.set_xlim([-4,0])
    fig.savefig('orientation.png')

def plotLogistic(a,b):
    fig = plt.figure()
    x = np.linspace(-50,50,201)
    y = np.zeros(201)
    y[0:100] = -(a*abs(x[0:100]))/(a - abs(x[0:100]) + 50) +50 
    y[100:201] = (b*x[100:201])/(b - x[100:201] + 50) +50 
    ax1 = fig.add_subplot(111)
    ax1.axis([0,100,0,100])
    x = np.linspace(0,100,201)
    print(x)
    print(y)
    ax1.plot(x,y, color = 'r')
    fig.savefig('logistic.png')

plotLogistic(1,1)
#plotLine('simulation-1Orientation20160202225728.log')
#plotpath('simulationPosition20151216140935.log')
#plotpath('logExampleArenaBoundaries.log')    
