require('vectorMath')

local finken = {}

finkenCore = require('finkenCore')
seekSteeringBehavior = require('seekSteeringBehavior')
fleeSteeringBehavior = require('fleeSteeringBehavior')
contextSteeringBehavior = require('contextSteeringBehavior')
contextData = require('contextData')

local sensorHandles = {}
local sensorDistances = {7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5}
local detect_handles = {}

local sensorFilter = {{lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0},
					  {lastValue = 7.5, count = 0}}

-- list of all steering behaviors
local steeringBehaviors = {}

local maxVelocity = 1--0.5
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
		-- create beahviors and add them to the behaviors list
		local seekBehavior = seekSteeringBehavior.new()
		--self.addSteeringBehavior('seek', seekBehavior)
		local fleeBehavior = fleeSteeringBehavior.new()
		--self.addSteeringBehavior('flee', fleeBehavior)
		local contextBehavior = contextSteeringBehavior.new()
		self.addSteeringBehavior('context', contextBehavior)
		
		-- create context data
		context = contextData.new()
		context.objectHandle = self.getObjectHandle()
		context.sensorDistances = {7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5}
		-- set first target
		context.targets['goal1'] = {4, 4, 2.05}
		--context.targets['goal2'] = {9.5, 10, 2.5}
		--context.targets['goal3'] = {-7, 15, 2.5}
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
			-- if(k == 'flee') then 
				-- helperSay('flee ' .. 
											-- velocity[1]..' '..
											-- velocity[2]..' '..
											-- velocity[3])
			-- end
		end
		
		-- calculate the final velocity for this step
		velocity = getNormalizedVector(velocity)
		velocity = multiplyVectorByScalar(velocity, maxVelocity)
		
		-- save the chosen velocity as last direction in the context data
		contextData.lastDirection = velocity
		
		-- set the controll target to the new steering position
		local newPosition = addVectors(context.currentPosition, velocity)
		
		-- keep hight 2.5 !!!!!!!!!!!!!!!!!!!! Its a cheat and should be handle properly in final version
		newPosition[3] = 2.5
		
		simSetObjectPosition(targetObj, -1, newPosition)
		self.setTarget(targetObj)
	end

	--[[
	--sense() reads all sensors of the finken, and updates the signals
	--@return {float dist_front, float dist_left, float dist_back, float dist_right}
	--]]
	function self.customSense()
		status= simHandleProximitySensor(sim_handle_all)
		status, sensorDistances[1], detect_vector, detect_handles[1], detect_surface= simReadProximitySensor(sensorHandles.distFront)
		status, sensorDistances[2], detect_vector, detect_handles[2], detect_surface= simReadProximitySensor(sensorHandles.distLeft)
		status, sensorDistances[3], detect_vector, detect_handles[3], detect_surface= simReadProximitySensor(sensorHandles.distBack)
		status, sensorDistances[4], detect_vector, detect_handles[4], detect_surface= simReadProximitySensor(sensorHandles.distRight)
		status, sensorDistances[5], detect_vector, detect_handles[5], detect_surface= simReadProximitySensor(sensorHandles.distFrontLeft)
		status, sensorDistances[6], detect_vector, detect_handles[6], detect_surface= simReadProximitySensor(sensorHandles.distFrontRight)
		status, sensorDistances[7], detect_vector, detect_handles[7], detect_surface= simReadProximitySensor(sensorHandles.distBackLeft)
		status, sensorDistances[8], detect_vector, detect_handles[8], detect_surface= simReadProximitySensor(sensorHandles.distBackRight)
		
		for i=1,8,1 do
			if sensorDistances[i] then
				context.sensorDistances[i] = sensorDistances[i]
				if(detect_handles[i] and string.find(simGetObjectName(detect_handles[i]), "SimFinken_texture")) then
					context.copters[i] = true
					simAddStatusbarMessage(simGetObjectName(detect_handles[i]))
				else
					context.copters[i] = false
				end
			else
				context.copters[i] = false
				context.sensorDistances[i] = 7.5
			end
			
			-- Filter sensor data if they are wrong
			--if not sensorDistances[i] then
			--	sensorDistances[i] = 7.5
				
			--	sensorFilter[i].count  = sensorFilter[i].count + 1
			--	if sensorFilter[i].count > 20 then 
			--		context.sensorDistances[i] = sensorDistances[i]
			--		sensorFilter[i].count = 0
			--	end
			--end
		end
		
		--context.sensorDistances = sensorDistances
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
