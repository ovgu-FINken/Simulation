local finken = {}

--local finken system variable definitions
local this_ID_Suffix = nil

local sensor_dist_front = nil
local sensor_dist_left = nil
local sensor_dist_back = nil
local sensor_dist_right = nil
local sensor_distances = {7.5,7.5,7.5,7.5}	
local sensor_dist_packed = simPackFloats(sensor_distances)
local pitch_target = 0
local roll_target = 0
local yaw_target = 0
local throttle_target = 0

local finken_base_handle = nil
local finken_handle = nil

local execution_last_time = 0
local execution_step_size = 0.050  
local pPthrottle=2
local iPthrottle=0
local dPthrottle=0
local vPthrottle=-2

local cumul=0
local lastE=0
local pAlphaE=0
local pBetaE=0
local psp2=0
local psp1=0

local prevEYaw=0
local prevEPitch=0
local prevERoll=0

													
local pPpitch = 0.2
local iPpitch = 0.01
local dPpitch = 1.5

local pProll=0.2
local iProll =0.01
local dProll=1.5

local pPyaw = 0.4 --0.1
local iPyaw = 0.001
local dPyaw = 1.91

local cumulYaw = 0
local cumulPitch = 0
local cumulRoll = 0

local particlesTargetVelocities = {-1,-1,-1,-1}

function finken.init()
	this_ID_Suffix = simGetNameSuffix(nil)
	finken_base_handle = simGetObjectHandle('SimFinken_base')
	finken_handle = simGetObjectAssociatedWithScript(sim_handle_self)
	simExtRemoteApiStart(19999)
	simAddStatusbarMessage('finken#'..this_ID_Suffix..' initializing')
	if (this_ID_Suffix ~= -1) then
		simSetFloatSignal('throttle'..this_ID_Suffix,50)
		simSetFloatSignal('pitch'..this_ID_Suffix,0)
		simSetFloatSignal('roll'..this_ID_Suffix,0)
		simSetFloatSignal('yaw'..this_ID_Suffix,0)
		sensor_dist_front = simGetObjectHandle('SimFinken_sensor_front#'..this_ID_Suffix)
		sensor_dist_left = simGetObjectHandle('SimFinken_sensor_left#'..this_ID_Suffix)
		sensor_dist_back = simGetObjectHandle('SimFinken_sensor_back#'..this_ID_Suffix)
		sensor_dist_right = simGetObjectHandle('SimFinken_sensor_right#'..this_ID_Suffix)
		simSetStringSignal('sensor_dist'..this_ID_Suffix,sensor_dist_packed)
	else
		simSetFloatSignal('throttle',50)
		simSetFloatSignal('pitch',0)
		simSetFloatSignal('roll',0)
		simSetFloatSignal('yaw',0)
		sensor_dist_front = simGetObjectHandle('SimFinken_sensor_front')
		sensor_dist_left = simGetObjectHandle('SimFinken_sensor_left')
		sensor_dist_back = simGetObjectHandle('SimFinken_sensor_back')
		sensor_dist_right = simGetObjectHandle('SimFinken_sensor_right')
		simSetStringSignal('sensor_dist',sensor_dist_packed)
	end
end

function finken.printCmds()
	simAddStatusbarMessage('throttle: '..throttle_target)
	simAddStatusbarMessage('pitch: '..pitch_target)
	simAddStatusbarMessage('roll: '..roll_target)
	simAddStatusbarMessage('yaw: '..yaw_target)
end


function finken.printSensorData()
	simAddStatusbarMessage('dist_front: ' ..sensor_distances[1])
	simAddStatusbarMessage('dist_left: ' ..sensor_distances[2])
	simAddStatusbarMessage('dist_back: ' ..sensor_distances[3])
	simAddStatusbarMessage('dist_right: ' ..sensor_distances[4])
end

local function tuneThrottle(throttle, curveParamNeg, curveParamPos)
	throttle_target =  throttle - 50
	if throttle_target < 0 then
		throttle_target = -(curveParamNeg*math.abs(throttle_target))/(curveParamNeg-math.abs(throttle_target)+50) + 50
	else
		throttle_target = (curveParamPos*throttle_target)/(curveParamPos-throttle_target+50) + 50
	end
	return throttle_target
end
--[[
--step() is called for each simulation step and controls the model. First, all target values are read,
--then, the pid-controller are updated and the target speed for each rotor is computed
--@return(float velocity, float velocity, float velocity, float velocity)
--]]
function finken.step()
	--[[local execution_current_time = simGetSimulationTime()
	simAddStatusbarMessage(execution_last_time + execution_step_size)
	simAddStatusbarMessage(execution_current_time)
	if (execution_last_time + execution_step_size <= execution_current_time) then]]
		execution_last_time = execution_current_time
		if (this_ID_Suffix ~= -1) then
			throttle_target=simGetFloatSignal('throttle'..this_ID_Suffix)
			pitch_target=simGetFloatSignal('pitch'..this_ID_Suffix)
			roll_target=simGetFloatSignal('roll'..this_ID_Suffix)
			yaw_target=simGetFloatSignal('yaw'..this_ID_Suffix)
		else
			throttle_target=simGetFloatSignal('throttle')
			pitch_target=simGetFloatSignal('pitch')
			roll_target=simGetFloatSignal('roll')
			yaw_target=simGetFloatSignal('yaw')
		end
		--invert roll and yaw axis to match real finken
		roll_target = -roll_target
		yaw_target = -yaw_target
		--logit-like function to fine tune throttle response
		throttle_target =  tuneThrottle(throttle_target, 1, 1)
		--hovers at approx. 50% throttle
		throttle=5.843*throttle_target/100

		euler=simGetObjectOrientation(finken_base_handle,-1)
		ins_matrix=simGetObjectMatrix(finken_base_handle,-1)
		vx={1,0,0}
		vx=simMultiplyVector(ins_matrix,vx)
		vy={0,1,0}
		vy=simMultiplyVector(ins_matrix,vy)
		rollAngleError=vy[3]-ins_matrix[12]
		pitchAngleError=-(vx[3]-ins_matrix[12])
		-- pitch control:
		errorPitch=pitchAngleError-(pitch_target*(math.pi/180))
		cumulPitch=cumulPitch+errorPitch
		pitchCorr=pPpitch*errorPitch+dPpitch*(errorPitch-prevEPitch)+iPpitch*cumulPitch
		prevEPitch=errorPitch
	
		-- roll control:
		errorRoll=rollAngleError-(roll_target*(math.pi/180))
		cumulRoll=cumulRoll+errorRoll
		rollCorr=pProll*errorRoll+dProll*(errorRoll-prevERoll)+iProll*cumulRoll
		prevERoll=errorRoll

		-- yaw control:
		errorYaw=euler[3]-yaw_target*(math.pi/180)
		if errorYaw < -math.pi then
			errorYaw = 2*math.pi+errorYaw
		else if errorYaw > math.pi then
			errorYaw=yaw_target*(math.pi/180)-euler[3]
			end
		end
		cumulYaw=cumulYaw+errorYaw
		yawCorr=pPyaw*errorYaw+dPyaw*(errorYaw-prevEYaw)+iPyaw*cumulYaw
		prevEYaw=errorYaw
		-- Decide of the motor velocities:
		particlesTargetVelocities[1]=throttle*(1+yawCorr-rollCorr+pitchCorr)
		particlesTargetVelocities[2]=throttle*(1-yawCorr-rollCorr-pitchCorr)
		particlesTargetVelocities[3]=throttle*(1+yawCorr+rollCorr-pitchCorr)
		particlesTargetVelocities[4]=throttle*(1-yawCorr+rollCorr+pitchCorr)
	--end
	return particlesTargetVelocities
end
--[[
--sense() reads all sensors of the finken, and updates the signals
--@return {float dist_front, float dist_left, float dist_back, float dist_right}
--]]
function finken.sense()
	status= simHandleProximitySensor(sim_handle_all)
	status, sensor_distances[1], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensor_dist_front)
	status, sensor_distances[2], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensor_dist_left)
	status, sensor_distances[3], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensor_dist_back)
	status, sensor_distances[4], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensor_dist_right)
	for i=1,4,1 do
		if not sensor_distances[i] then
			sensor_distances[i] = 7.5
		end
	end
	sensor_dist_packed = simPackFloats(sensor_distances)
	if (this_ID_Suffix ~= -1) then
		simSetStringSignal('sensor_dist'..this_ID_Suffix,sensor_dist_packed)
	else
		simSetStringSignal('sensor_dist',sensor_dist_packed)
	end
	return sensor_distances
end


return finken
