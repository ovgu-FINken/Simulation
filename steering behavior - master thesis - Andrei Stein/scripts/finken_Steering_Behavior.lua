local finken = {}

finkenCore = require('finkenCore')

local sensorHandles = {}
local sensorDistances = {7.5,7.5,7.5,7.5,7.5,7.5,7.5,7.5}

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
		
		
	end


	function self.customRun()
		--targetObject is retrieved in the simulation script. 
		--remove if control via pitch/roll/yaw is wanted
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
		helperSay(sensorDistances[1])
		--simSetStringSignal(self.fixSignalName('sensor_dist'),simPackFloats(sensorDistances))
		return sensorDistances
	end

	function self.customClean()

	end

	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
