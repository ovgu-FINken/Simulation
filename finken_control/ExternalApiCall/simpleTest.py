# Copyright 2006-2015 Coppelia Robotics GmbH. All rights reserved. 
# marc@coppeliarobotics.com
# www.coppeliarobotics.com
# 
# -------------------------------------------------------------------
# THIS FILE IS DISTRIBUTED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTY. THE USER WILL USE IT AT HIS/HER OWN RISK. THE ORIGINAL
# AUTHORS AND COPPELIA ROBOTICS GMBH WILL NOT BE LIABLE FOR DATA LOSS,
# DAMAGES, LOSS OF PROFITS OR ANY OTHER KIND OF LOSS WHILE USING OR
# MISUSING THIS SOFTWARE.
# 
# You are free to use/modify/distribute this file for whatever purpose!
# -------------------------------------------------------------------
#
# This file was automatically created for V-REP release V3.2.2 Rev1 on September 5th 2015

# Make sure to have the server side running in V-REP: 
# in a child script of a V-REP scene, add following command
# to be executed just once, at simulation start:
#
# simExtRemoteApiStart(19999)
#
# then start simulation, and run this program.
#
# IMPORTANT: for each successful call to simxStart, there
# should be a corresponding call to simxFinish at the end!

try:
    import vrep
except:
    print ('--------------------------------------------------------------')
    print ('"vrep.py" could not be imported. This means very probably that')
    print ('either "vrep.py" or the remoteApi library could not be found.')
    print ('Make sure both are in the same folder as this file,')
    print ('or appropriately adjust the file "vrep.py"')
    print ('--------------------------------------------------------------')
    print ('')

import time

# Set simulation time in seconds
MaxSimulationTime =1000;

print ('Program started')
vrep.simxFinish(-1) # just in case, close all opened connections
clientID=vrep.simxStart('127.0.0.1',19997,True,True,5000,5) # Connect to V-REP
if clientID!=-1:
    print ('Connected to remote API server')

    # Now send some data to V-REP in a non-blocking fashion:
    vrep.simxAddStatusbarMessage(clientID,'Hello V-REP!',vrep.simx_opmode_oneshot)
    vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot_wait)
    vrep.simxPauseSimulation(clientID,vrep.simx_opmode_oneshot_wait)

    print('B_FileName:',vrep.simxGetStringSignal(clientID,'_fileName',vrep.simx_opmode_streaming))
    print('XScale:',vrep.simxGetFloatSignal(clientID,'_xScale',vrep.simx_opmode_streaming))
    print('YScale:',vrep.simxGetFloatSignal(clientID,'_yScale',vrep.simx_opmode_streaming))
    print('TotalSize:',vrep.simxGetFloatSignal(clientID,'_LM_SizeOfContainer',vrep.simx_opmode_streaming))
    print('FieldSize:',vrep.simxGetFloatSignal(clientID,'_LM_SizeOfField',vrep.simx_opmode_streaming))
    print('GradientSpeed:',vrep.simxGetFloatSignal(clientID,'_gradientSpeed',vrep.simx_opmode_streaming))
    print('ExploreSpeed:',vrep.simxGetFloatSignal(clientID,'_exploreSpeed',vrep.simx_opmode_streaming))
    print('TargetEpsilon:',vrep.simxGetFloatSignal(clientID,'_targetEpsilon',vrep.simx_opmode_streaming))
    print('WidthFactor:',vrep.simxGetFloatSignal(clientID,'_widthFactor',vrep.simx_opmode_streaming))
    print('StepFactor:',vrep.simxGetFloatSignal(clientID,'_stepFactor',vrep.simx_opmode_streaming))
    print('CPEpsilonRation:',vrep.simxGetFloatSignal(clientID,'_checkpointEpsilonRatio',vrep.simx_opmode_streaming))
    print('IsDrunk:',vrep.simxGetIntegerSignal(clientID,'_drunk',vrep.simx_opmode_streaming))

    # Now try to retrieve data in a blocking fashion (i.e. a service call):
    vrep.simxSetIntegerSignal(clientID,'_isRemoteApi',0,vrep.simx_opmode_oneshot)

    vrep.simxSetStringSignal(clientID,'_fileName','large_hills_smooth.png',vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_xScale',10,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_yScale',10,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_LM_SizeOfContainer',10,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_LM_SizeOfField',1,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_gradientSpeed',15,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_exploreSpeed',5,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_targetEpsilon',1,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_widthFactor',3,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_stepFactor',1,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_checkpointEpsilonRatio',0.5,vrep.simx_opmode_oneshot)
    vrep.simxSetFloatSignal(clientID,'_drunk',0,vrep.simx_opmode_oneshot)

    time.sleep(5)
    vrep.simxStartSimulation(clientID,vrep.simx_opmode_oneshot_wait)

    print('FileName:',vrep.simxGetStringSignal(clientID,'_fileName',vrep.simx_opmode_streaming))
    print('XScale:',vrep.simxGetFloatSignal(clientID,'_xScale',vrep.simx_opmode_streaming))
    print('YScale:',vrep.simxGetFloatSignal(clientID,'_yScale',vrep.simx_opmode_streaming))
    print('TotalSize:',vrep.simxGetFloatSignal(clientID,'_LM_SizeOfContainer',vrep.simx_opmode_streaming))
    print('FieldSize:',vrep.simxGetFloatSignal(clientID,'_LM_SizeOfField',vrep.simx_opmode_streaming))
    print('GradientSpeed:',vrep.simxGetFloatSignal(clientID,'_gradientSpeed',vrep.simx_opmode_streaming))
    print('ExploreSpeed:',vrep.simxGetFloatSignal(clientID,'_exploreSpeed',vrep.simx_opmode_streaming))
    print('TargetEpsilon:',vrep.simxGetFloatSignal(clientID,'_targetEpsilon',vrep.simx_opmode_streaming))
    print('WidthFactor:',vrep.simxGetFloatSignal(clientID,'_widthFactor',vrep.simx_opmode_streaming))
    print('StepFactor:',vrep.simxGetFloatSignal(clientID,'_stepFactor',vrep.simx_opmode_streaming))
    print('CPEpsilonRation:',vrep.simxGetFloatSignal(clientID,'_checkpointEpsilonRatio',vrep.simx_opmode_streaming))
    print('IsDrunk:',vrep.simxGetIntegerSignal(clientID,'_drunk',vrep.simx_opmode_streaming))

    # Now close the connection to V-REP:
    #vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot)
    time.sleep(500)
    print('Result:',vrep.simxStopSimulation(clientID,vrep.simx_opmode_oneshot_wait))
    vrep.simxFinish(clientID)
else:
    print ('Failed connecting to remote API server')
print ('Program ended')

