try:
    import vrep
except ImportError:
    print('--------------------------------------------------------------')
    print('"vrep.py" could not be imported. This means very probably that')
    print('either "vrep.py" or the remoteApi library could not be found.')
    print('Make sure both are in the same folder as this file,')
    print('or appropriately adjust the file "vrep.py"')
    print('--------------------------------------------------------------')
    print('')

import time


def run_simulation_for_time(t, parameters, id_number, client, mode):
    vrep.simxAddStatusbarMessage(client, 'Starting simulation from remote script', mode)
    vrep.simxSynchronous(client, True)
    vrep.simxStartSimulation(client, mode)
    send_parameters(client, parameters, id_number, opmode)
    time.sleep(4)
    vrep.simxSynchronous(client, False)
    # vrep.simxPauseSimulation(client, mode)
    vrep.simxGetObjectHandle(client, '', vrep.simx_opmode_oneshot_wait)
    time.sleep(10)
    while vrep.simxGetLastCmdTime(client) < t:
        time.sleep(5)
        print('waiting for simulation to finish')
        # there is no function to get the simulation time directly, so we use this workaround
        vrep.simxGetObjectHandle(client, '', mode)

    print('time:', vrep.simxGetLastCmdTime(client))
    print('Stopping:', vrep.simxStopSimulation(client, mode))
    # the simulation doesn't stop immediately, so we wait a little bit
    time.sleep(1.5)


def send_parameters(client, parameters, idx, mode):
    vrep.simxSetIntegerSignal(clientID, '_isRemoteApi', 1, vrep.simx_opmode_oneshot)
    for k, v, in parameters.items():
        if k == '_fileName':
            vrep.simxSetStringSignal(client, k, v[idx], mode)
        elif k == '_mode':
            vrep.simxSetIntegerSignal(client, k, v[idx], mode)
        else:
            vrep.simxSetFloatSignal(client, k, v[idx], mode)


opmode = vrep.simx_opmode_oneshot

max_time = 30 * 1000  # stop simulation after this much time (in ms)

num_repetitions = 1

# TODO: describe what the parameters do
params = dict()
params['_fileName'] = ['large_hills_smooth.png', 'large_hills_smooth.png'] * num_repetitions
#params['_fileName'] = ['pyramid.png', 'pyramid.png', 'pyramid.png'] * num_repetitions

params['_xScale'] = [10, 10] * num_repetitions
params['_yScale'] = [10, 10] * num_repetitions

params['_LM_SizeOfContainer'] = [100, 100] * num_repetitions
params['_LM_SizeOfField'] = [5, 5] * num_repetitions

params['_gradientSpeed'] = [0.15, 0.15] * num_repetitions
params['_exploreSpeed'] = [2.5, 2.5] * num_repetitions
params['_targetEpsilon'] = [0.05, 0.05] * num_repetitions
params['_widthFactor'] = [2, 2] * num_repetitions
params['_stepFactor'] = [0.5, 0.5] * num_repetitions
params['_checkpointEpsilonRatio'] = [0.5, 0.5] * num_repetitions
params['_mode'] = [0, 1] * num_repetitions

params['imu:noiseMagnitude'] = [0.15, 0.15] * num_repetitions

vrep.simxFinish(-1)  # just in case, close all opened connections
clientID = vrep.simxStart('127.0.0.1', 19997, True, True, 5000, 5)  # Connect to V-REP

if clientID != -1:
    # vrep.simxStartSimulation(clientID2, opmode)
    print('Connected to remote API server')
    total_runs = len(params['_fileName'])
    for i in range(total_runs):
        run_simulation_for_time(max_time, params, i, clientID, opmode)
    # print('Stopping:', vrep.simxStopSimulation(clientID2, opmode))
    vrep.simxFinish(clientID)
    # vrep.simxFinish(clientID2)
else:
    print('Failed connecting to remote API server')
print('Program ended')
