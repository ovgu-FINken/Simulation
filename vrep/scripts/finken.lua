local finken = {}

local finkenPID = require ("finkenPID")
local pitchController = finkenPID.new()
local rollController = finkenPID.new()
local yawController = finkenPID.new()
local targetXcontroller = finkenPID.new()
local targetYcontroller = finkenPID.new()
local targetZcontroller = finkenPID.new()
--local finken system variable definitions
local this_ID_Suffix = nil

local handle_sensor_dist_front = nil
local handle_sensor_dist_left = nil
local handle_sensor_dist_back = nil
local handle_sensor_dist_right = nil
local sensor_distances = {7.5,7.5,7.5,7.5}	
local sensor_dist_packed = simPackFloats(sensor_distances)
local pitch_target = 0
local roll_target = 0
local yaw_target = 0
local throttle_target = 0
local height_target = 0

local handle_finken_base = nil
local handle_finken = nil

local execution_last_time = 0
local execution_step_size = 0.050 

local pPthrottle=2
local iPthrottle=0
local dPthrottle=0
local vPthrottle=-2
local cumulThrottle=0
local prevEThrottle =0


local function tuneThrottle(throttle, curveParamNeg, curveParamPos)
	local throttle_target =  throttle - 50
	if throttle_target < 0 then
		throttle_target = -(curveParamNeg*math.abs(throttle_target))/(curveParamNeg-math.abs(throttle_target)+50) + 50
	else
		throttle_target = (curveParamPos*throttle_target)/(curveParamPos-throttle_target+50) + 50
	end
	return throttle_target
end

local function fixSignalName(signalName)
	if (this_ID_Suffix ~= -1) then
		return (signalName..this_ID_Suffix)
	else
		return signalName
	end
end

local function fixName(name)
	if (this_ID_Suffix ~= -1) then
		return (name..'#'..this_ID_Suffix)
	else
		return name
	end
end


function finken.init()
	this_ID_Suffix = simGetNameSuffix(nil)
	handle_finken_base = simGetObjectHandle(fixName('SimFinken_base'))
	handle_finken = simGetObjectAssociatedWithScript(sim_handle_self)
	simExtRemoteApiStart(19999)
	pitchController.init(0.2, 0.1, 1.5)
	rollController.init(0.2, 0.1, 1.5)
	yawController.init(0.4, 0.001, 1.91) --(0.1, , )
	targetXcontroller.init(2, 0, 4)
	targetYcontroller.init(2, 0, 4)
	targetZcontroller.init(6, 1, 8)
	simSetFloatSignal(fixSignalName('throttle'),50)
	simSetFloatSignal(fixSignalName('pitch'),0)
	simSetFloatSignal(fixSignalName('roll'),0)
	simSetFloatSignal(fixSignalName('yaw'),0)
	simSetFloatSignal(fixSignalName('height'),1)
	handle_sensor_dist_front = simGetObjectHandle(fixName('SimFinken_sensor_front'))
	handle_sensor_dist_left = simGetObjectHandle(fixName('SimFinken_sensor_left'))
	handle_sensor_dist_back = simGetObjectHandle(fixName('SimFinken_sensor_back'))
	handle_sensor_dist_right = simGetObjectHandle(fixName('SimFinken_sensor_right'))
	simSetStringSignal(fixSignalName('sensor_dist'),sensor_dist_packed)
end

function finken.printControlValues()
	simAddStatusbarMessage('throttle: '..throttle_target)
	simAddStatusbarMessage('pitch: '..pitch_target)
	simAddStatusbarMessage('roll: '..roll_target)
	simAddStatusbarMessage('yaw: '..yaw_target)
	simAddStatusbarMessage('height: '..height_target)
end

function finken.printSensorData()
	simAddStatusbarMessage('dist_front: ' ..sensor_distances[1])
	simAddStatusbarMessage('dist_left: ' ..sensor_distances[2])
	simAddStatusbarMessage('dist_back: ' ..sensor_distances[3])
	simAddStatusbarMessage('dist_right: ' ..sensor_distances[4])
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
	if (execution_last_time + execution_step_size <= execution_current_time) then
		execution_last_time = execution_current_time]]
		throttle_target=simGetFloatSignal(fixSignalName('throttle'))
		pitch_target=simGetFloatSignal(fixSignalName('pitch'))
		roll_target=simGetFloatSignal(fixSignalName('roll'))
		yaw_target=simGetFloatSignal(fixSignalName('yaw'))
		height_target=simGetFloatSignal(fixSignalName('height'))
		--invert roll and yaw axis to match real finken
		roll_target = -roll_target
		yaw_target = -yaw_target
		--logit-like function to fine tune throttle response
		throttle_target =  tuneThrottle(throttle_target, 1, 1)
		--hovers at approx. 50% throttle
		local basePosition = simGetObjectPosition(handle_finken_base,-1)
		local errorHeight = height_target - basePosition[3]
		cumulThrottle = cumulThrottle + errorHeight
		local l = simGetVelocity(handle_finken)
		local throttle=5.843*throttle_target/100 + pPthrottle * errorHeight + iPthrottle * cumulThrottle + dPthrottle * (errorHeight - prevEThrottle) + l[3] * (-2) 
		prevEThrottle = errorHeight

		local euler=simGetObjectOrientation(handle_finken_base,-1)
		local ins_matrix=simGetObjectMatrix(handle_finken_base,-1)
		local vx={1,0,0}
		local vx=simMultiplyVector(ins_matrix,vx)
		local vy={0,1,0}
		local vy=simMultiplyVector(ins_matrix,vy)
		local rollAngleError=vy[3]-ins_matrix[12]
		local pitchAngleError=-(vx[3]-ins_matrix[12])
		-- pitch control:
		local errorPitch=pitchAngleError-(pitch_target*(math.pi/180))
		local pitchCorr = pitchController.step(errorPitch, 1)--execution_step_size)
	
		-- roll control:
		local errorRoll=rollAngleError-(roll_target*(math.pi/180))
		local rollCorr=rollController.step(errorRoll, 1)--execution_step_size)

		-- yaw control:
		local errorYaw=euler[3]-yaw_target*(math.pi/180)
		if errorYaw < -math.pi then
			errorYaw = 2*math.pi+errorYaw
		else if errorYaw > math.pi then
			errorYaw=yaw_target*(math.pi/180)-euler[3]
			end
		end
		local yawCorr=yawController.step(errorYaw, 1)--execution_step_size)
		-- Decide of the motor velocities:
		local particlesTargetVelocities = {-1,-1,-1,-1}
		particlesTargetVelocities[1]=throttle*(1+yawCorr-rollCorr+pitchCorr)
		particlesTargetVelocities[2]=throttle*(1-yawCorr-rollCorr-pitchCorr)
		particlesTargetVelocities[3]=throttle*(1+yawCorr+rollCorr-pitchCorr)
		particlesTargetVelocities[4]=throttle*(1-yawCorr+rollCorr+pitchCorr)
	--end
	return particlesTargetVelocities
end

function finken.setTarget(targetObject)
	local xyz = simGetObjectPosition(targetObject,-1) 
	local basePosition = simGetObjectPosition(handle_finken_base,-1)
	local errorX = basePosition[1] - xyz[1]
	local errorY = basePosition[2] - xyz[2]
	local errorZ =  xyz[3]-basePosition[3]
	local corrX = targetXcontroller.step(errorX, 1)
	local corrY = targetYcontroller.step(errorY, 1)
	local corrZ = targetZcontroller.step(errorZ, 1)
	simSetFloatSignal(fixSignalName('pitch'),-corrX)
	simSetFloatSignal(fixSignalName('roll'), -corrY)
	simSetFloatSignal(fixSignalName('throttle'), corrZ)
end
--[[
--sense() reads all sensors of the finken, and updates the signals
--@return {float dist_front, float dist_left, float dist_back, float dist_right}
--]]
function finken.sense()
	status= simHandleProximitySensor(sim_handle_all)
	status, sensor_distances[1], detect_vector, detect_handle, detect_surface= simReadProximitySensor(handle_sensor_dist_front)
	status, sensor_distances[2], detect_vector, detect_handle, detect_surface= simReadProximitySensor(handle_sensor_dist_left)
	status, sensor_distances[3], detect_vector, detect_handle, detect_surface= simReadProximitySensor(handle_sensor_dist_back)
	status, sensor_distances[4], detect_vector, detect_handle, detect_surface= simReadProximitySensor(handle_sensor_dist_right)
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
