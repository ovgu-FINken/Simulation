local finken = {}

finkenCore = require('finkenCore')

function finken.init(self)
	local distances = {} 
	local otherObjectPositions = {}	
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
	local attrRepuls_params = 


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
		--@TODO update context?	
		table.insert(otherObjectPositions, {-distances.front, 0, 0})
		context.distanceFront = distances.front
		table.insert(otherObjectPositions, {distance.back, 0, 0})
		context.distanceBack = distances.back
		table.insert(otherObjectPositions, {0, -distances.left, 0})
		context.distanceLeft = distances.left
		table.insert(otherObjectPositions, {0, distances.right, 0})
		context.distanceRight = distances.right


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
