local finken = {}
finkenCore = require('finkenCore')

function finken.init(self)
	local distances = {front = 7.5, left = 7.5, back = 7.5, right = 7.5, bottom = 1.5} 
	local context = {
		wallDetectedFront = 0,
		wallDetectedLeft = 0,
		wallDetectedBack = 0,
		wallDetectedRight = 0,
		distanceFront = nil,
		distanceLeft = nil,
		distanceBack = nil,
		distanceRight = nil
	}
	local attrRepuls_params = {a = 1, b = 4, c = 1.5, wCohesion = 0.8, wTarget = 0.2} 



	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end
	local function updateContextRandomPosition()

	end

	local function getAttractionRepulsionPosition()

	end

	function self.customInit()
		distances.front = 7.5
		distances.left = 7.5
		distances.back = 7.5
		distances.right = 7.5
		distance.bottom = 7.5
	end


	function self.customRun()
		--targetObject is retrieved in the simulation script. 
		--remove if control via pitch/roll/yaw is wanted
		--self.setTarget(targetObj)
		
		--TODO target 
		


	end

	function self.customSense()
		_, distances.front = simReadProximitySensor(sensors.front)
		_, distances.left = simReadProximitySensor(sensors.left)
		_, distances.back = simReadProximitySensor(sensors.back)
		_, distances.right = simReadProximitySensor(sensors.right)
		_, distances.bottom = simReadProximitySensor(sensors.bottom)
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
