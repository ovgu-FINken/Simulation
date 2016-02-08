local finkenCore = {}

local finkenPID = require ("finkenPID")
local pitchController = finkenPID.new()
local rollController = finkenPID.new()
local yawController = finkenPID.new()
local targetXcontroller = finkenPID.new()
local targetYcontroller = finkenPID.new()
local targetZcontroller = finkenPID.new()
--local finken system variable definitions
local thisIDsuffix = nil

local sensorHandles = {distFront = nil, distLeft = nil, distBack = nil, distRight = nil}
local sensorDistances = {7.5,7.5,7.5,7.5}	

local handle_FinkenBase = nil
local handle_finken = nil

local execution_last_time = 0
local execution_step_size = 0
local defaultStepSize = 0.050 

local pPthrottle=2
local iPthrottle=0
local dPthrottle=0
local vPthrottle=-2
local cumulThrottle=0
local prevEThrottle =0


local function tuneThrottle(throttle, curveParamNeg, curveParamPos)
	local throttleTarget =  throttle - 50
	if throttleTarget < 0 then
		throttleTarget = -(curveParamNeg*math.abs(throttleTarget))/(curveParamNeg-math.abs(throttleTarget)+50) + 50
	else
		throttleTarget = (curveParamPos*throttleTarget)/(curveParamPos-throttleTarget+50) + 50
	end
	return throttleTarget
end

--converts a signal to the signal matching the current instance by appending the corresponding index
--@return signalName
local function fixSignalName(signalName)
	if (thisIDsuffix ~= -1) then
		return (signalName..thisIDsuffix)
	else
		return signalName
	end
end


--convert a name to a name with suffix according to the vrep naming scheme
--if no suffix is provided, the suffix of the current instance is used
--@return name with suffix 
local function fixName(name,suffix)
	local mySuffix = suffix or thisIDsuffix
	if (mySuffix ~= -1) then
		return (name..'#'..mySuffix)
	else
		return name
	end
end

-- initializes the finkens flight controllers and control signals
-- initializes the object handles
-- starts the remote API (note that because everything happens withing one simulation step, with multiple FINkens 
-- you receive a warning that the remote API is already running, as the API is started before the next simulation
-- step, it's status can't be checked in the current step, so every FINken tries to start a new one)
---- @return
function finkenCore.init()
	thisIDsuffix = simGetNameSuffix(nil)
	handle_FinkenBase = simGetObjectHandle(fixName('SimFinken_base'))
	handle_finken = simGetObjectAssociatedWithScript(sim_handle_self)
	execution_step_size = simGetSimulationTimeStep()
	--local apiStatus, apiInfo, _ = simExtRemoteApiStatus(19999)
	local apiInfo = apiInfo or simExtRemoteApiStart(19999)
	--if not apiStatus then apiStatus = simExtRemoteApiStart(19999) end
	simAddStatusbarMessage("apiStatus "..apiInfo )
	pitchController.init(0.2, 0.1, 1.5)
	rollController.init(0.2, 0.1, 1.5)
	yawController.init(0.4, 0.001, 1.91) --(0.1, , )
	targetXcontroller.init(2, 0, 4)
	targetYcontroller.init(2, 0, 4)
	targetZcontroller.init(6, 0, 8)
	simSetFloatSignal(fixSignalName('throttle'),50)
	simSetFloatSignal(fixSignalName('pitch'),0)
	simSetFloatSignal(fixSignalName('roll'),0)
	simSetFloatSignal(fixSignalName('yaw'),0)
	simSetFloatSignal(fixSignalName('height'),1)
	sensorHandles.distFront = simGetObjectHandle(fixName('SimFinken_sensor_front'))
	sensorHandles.distLeft = simGetObjectHandle(fixName('SimFinken_sensor_left'))
	sensorHandles.distBack = simGetObjectHandle(fixName('SimFinken_sensor_back'))
	sensorHandles.distRight = simGetObjectHandle(fixName('SimFinken_sensor_right'))
	simSetStringSignal(fixSignalName('sensor_dist'),simPackFloats(sensorDistances))
end

function finkenCore.getHandle()
	return handle_finken
end

function finkenCore.getBaseHandle()
	return handle_FinkenBase
end


function finkenCore.printControlValues()
	simAddStatusbarMessage('throttle: '..throttleTarget)
	simAddStatusbarMessage('pitch: '..pitchTarget)
	simAddStatusbarMessage('roll: '..rollTarget)
	simAddStatusbarMessage('yaw: '..yawTarget)
	simAddStatusbarMessage('height: '..heightTarget)
end

function finkenCore.printSensorData()
	simAddStatusbarMessage('dist_front: ' ..sensorDistances[1])
	simAddStatusbarMessage('dist_left: ' ..sensorDistances[2])
	simAddStatusbarMessage('dist_back: ' ..sensorDistances[3])
	simAddStatusbarMessage('dist_right: ' ..sensorDistances[4])
end


--[[
--step() is called for each simulation step and controls the model. First, all target values are read,
--then, the pid-controller are updated and the target speed for each rotor is computed
--@return(float velocity, float velocity, float velocity, float velocity)
--]]
function finkenCore.step()
	--[[local execution_current_time = simGetSimulationTime()
	simAddStatusbarMessage(execution_last_time + execution_step_size)
	simAddStatusbarMessage(execution_current_time)
	if (execution_last_time + execution_step_size <= execution_current_time) then
		execution_last_time = execution_current_time]]
		local throttleTarget=simGetFloatSignal(fixSignalName('throttle'))
		local pitchTarget=simGetFloatSignal(fixSignalName('pitch'))
		local rollTarget=simGetFloatSignal(fixSignalName('roll'))
		local yawTarget=simGetFloatSignal(fixSignalName('yaw'))
		local heightTarget=simGetFloatSignal(fixSignalName('height'))
		--invert roll and yaw axis to match real finken
		rollTarget = -rollTarget
		yawTarget = -yawTarget
		--logit-like function to fine tune throttle response
		throttleTarget =  tuneThrottle(throttleTarget, 1, 1)
		--hovers at approx. 50% throttle
		local basePosition = simGetObjectPosition(handle_FinkenBase,-1)
		
		local thrust = 0
		if (heightTarget >= 0) then 
			local errorHeight = heightTarget - basePosition[3]
			cumulThrottle = cumulThrottle + errorHeight
			local l = simGetVelocity(handle_finken)
			thrust = 22.175*throttleTarget/100 + pPthrottle * errorHeight + iPthrottle * cumulThrottle + dPthrottle * (errorHeight - prevEThrottle) + l[3] * (-2) 
			prevEThrottle = errorHeight
		else
			thrust = 22.175*throttleTarget/100
		end
		
		local euler=simGetObjectOrientation(handle_FinkenBase,-1)
		local ins_matrix=simGetObjectMatrix(handle_FinkenBase,-1)
		local vx={1,0,0}
		local vx=simMultiplyVector(ins_matrix,vx)
		local vy={0,1,0}
		local vy=simMultiplyVector(ins_matrix,vy)
		local rollAngleError=vy[3]-ins_matrix[12]
		local pitchAngleError=-(vx[3]-ins_matrix[12])
		-- pitch control:
		local errorPitch=pitchAngleError-(pitchTarget*(math.pi/180))
		local pitchCorr = pitchController.stepResetIonTarget(errorPitch, execution_step_size / defaultStepSize)
	
		-- roll control:
		local errorRoll=rollAngleError-(rollTarget*(math.pi/180))
		local rollCorr=rollController.stepResetIonTarget(errorRoll, execution_step_size / defaultStepSize)

		-- yaw control:
		-- ToDo: add modulo operation for robustness against huge values?
		local errorYaw=euler[3]-yawTarget*(math.pi/180)
		if errorYaw < -math.pi then
			errorYaw = 2*math.pi+errorYaw
		else if errorYaw > math.pi then
			errorYaw=yawTarget*(math.pi/180)-euler[3]
			end
		end
		local yawCorr=yawController.stepResetIonTarget(errorYaw, execution_step_size / defaultStepSize)
		-- Decide of the motor velocities:
		local particlesTargetVelocities = {-1,-1,-1,-1}
		particlesTargetVelocities[1]=thrust*(1+yawCorr-rollCorr+pitchCorr)
		particlesTargetVelocities[2]=thrust*(1-yawCorr-rollCorr-pitchCorr)
		particlesTargetVelocities[3]=thrust*(1+yawCorr+rollCorr-pitchCorr)
		particlesTargetVelocities[4]=thrust*(1-yawCorr+rollCorr+pitchCorr)
	--end
	return particlesTargetVelocities
end

function finkenCore.setTarget(targetObject)
	local targetPosition = simGetObjectPosition(targetObject,-1) 
	local basePosition = simGetObjectPosition(handle_FinkenBase,-1)
	local errorX = targetPosition[1] - basePosition[1]
	local errorY = targetPosition[2] - basePosition[2]
	local errorZ =  targetPosition[3]-basePosition[3]
	local corrX = targetXcontroller.stepResetIonTarget(errorX, execution_step_size / defaultStepSize)
	local corrY = targetYcontroller.stepResetIonTarget(errorY, execution_step_size / defaultStepSize)
	local corrZ = targetZcontroller.stepResetIonTarget(errorZ, execution_step_size / defaultStepSize)
	-- @ToDo limit the signal to maximum functioning value
	simSetFloatSignal(fixSignalName('pitch'), corrX)
	simSetFloatSignal(fixSignalName('roll'), corrY)
	simSetFloatSignal(fixSignalName('throttle'), 50+corrZ)
	simSetFloatSignal(fixSignalName('height'),targetPosition[3])
end
--[[
--sense() reads all sensors of the finken, and updates the signals
--@return {float dist_front, float dist_left, float dist_back, float dist_right}
--]]
function finkenCore.sense()
	status= simHandleProximitySensor(sim_handle_all)
	status, sensorDistances[1], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distFront)
	status, sensorDistances[2], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distLeft)
	status, sensorDistances[3], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distBack)
	status, sensorDistances[4], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distRight)
	for i=1,4,1 do
		if not sensorDistances[i] then
			sensorDistances[i] = 7.5
		end
	end
	simSetStringSignal(fixSignalName('sensor_dist'),simPackFloats(sensorDistances))
	return sensorDistances
end

return finkenCore
