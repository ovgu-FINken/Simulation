require('vectorMath')

local finken = {}

finkenCore = require('finkenCore')
seekSteeringBehavior = require('seekSteeringBehavior')
contextData = require('contextData')

local sensorHandles = {}
local sensorDistances = {7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5}

-- list of all steering behaviors
local steeringBehaviors = {}

local maxVelocity = 2
local velocity = 0

-- data about the current context
local context = {}

function finken.init(self)

	-- Add the additional sensor handles to get 8 in total
	sensorHandles = self.getSensorHandles()
	sensorHandles.distFrontLeft = simGetObjectHandle(self.fixName('SimFinken_sensor_front_left'))
	sensorHandles.distFrontRight = simGetObjectHandle(self.fixName('SimFinken_sensor_front_right'))
	sensorHandles.distBackLeft = simGetObjectHandle(self.fixName('SimFinken_sensor_back_left'))
	sensorHandles.distBackRight = simGetObjectHandle(self.fixName('SimFinken_sensor_back_right'))
	
	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end


	function self.customInit()
		helperSay("Hello World! Tschiep!")
		local seekBehavior = seekSteeringBehavior.new()
		self.addSteeringBehavior("seek", seekBehavior)
		context = contextData.new()
		context.targets['goal1'] = {4,4,2}
	end


	function self.customRun()
		-- targetObject is retrieved in the simulation script.
		
		-- init starting values
		velocity = {0,0,0}
		local steering ={0,0,0}
		context.currentPosition = self.getPosition()
		
		-- get steering from all bahaviors and combine them
		for k, behavior in pairs(steeringBehaviors) do
			steering = behavior.getSteering(context)
			velocity = addVectors(velocity, steering)
		end
		
		-- calculate the final velocity for this step
		velocity = getNormalizedVector(velocity)
		velocity = multiplyVectorByScalar(velocity, maxVelocity)
		
		-- set the controll target to the new steering position
		local newPosition = addVectors(context.currentPosition, velocity)
		simSetObjectPosition(targetObj, -1, newPosition)
		self.setTarget(targetObj)
	end

	--[[
	--sense() reads all sensors of the finken, and updates the signals
	--@return {float dist_front, float dist_left, float dist_back, float dist_right}
	--]]
	function self.customSense()
		status= simHandleProximitySensor(sim_handle_all)
		status, sensorDistances[1], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distFront)
		status, sensorDistances[2], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distLeft)
		status, sensorDistances[3], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distBack)
		status, sensorDistances[4], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distRight)
		status, sensorDistances[5], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distFrontLeft)
		status, sensorDistances[6], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distFrontRight)
		status, sensorDistances[7], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distBackLeft)
		status, sensorDistances[8], detect_vector, detect_handle, detect_surface= simReadProximitySensor(sensorHandles.distBackRight)
	
		for i=1,8,1 do
			if not sensorDistances[i] then
				sensorDistances[i] = 7.5
			end
		end
		
		context.sensorDistances = sensorDistances
		return sensorDistances
	end

	function self.customClean()

	end
	
	-- adds a steering behavior to the steeringBehaviors-list
	function self.addSteeringBehavior(name, behavior)
		steeringBehaviors[name] = behavior
	end

	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
