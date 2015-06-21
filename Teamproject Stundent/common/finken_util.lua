function newFinken(config)
	config = ajustConfig(config)

	local object = simGetObjectHandle(getNameWithSuffix(config.name, config.suffix))
	local script = simGetScriptAssociatedWithObject(object)

	local sensors = {
		front = simGetObjectHandle(getNameWithSuffix(config.front_sensor, config.suffix)),
		back = simGetObjectHandle(getNameWithSuffix(config.back_sensor, config.suffix)),
		left = simGetObjectHandle(getNameWithSuffix(config.left_sensor, config.suffix)),
		right = simGetObjectHandle(getNameWithSuffix(config.right_sensor, config.suffix)),
		bottom = simGetObjectHandle(getNameWithSuffix(config.bottom_sensor, config.suffix))
	}

	local actuate = function()
		simAddStatusbarMessage("Mode is NOT supported: " .. config.mode)
	end

	if (config.mode == "attr_rep_sens_rel" or 
		config.mode == "attr_rep_dist_abs" or 
		config.mode == "test_abs" or 
		config.mode == "test_rel")
	then
		local xPIDController = newPIDController(config.x_pid)
		local yPIDController = newPIDController(config.y_pid)
		local zPIDController = newPIDController(config.z_pid)

		local otherObjects = {}
		for _, otherObjectSuffix in ipairs(config.other_suffixes) do
			table.insert(otherObjects, simGetObjectHandle(getNameWithSuffix(config.name, otherObjectSuffix)))
		end

		local iterationCount = 0

		actuate = function()
			iterationCount = iterationCount + 1

			local nextPosition
			local currentPosition
			
			if (config.mode == "attr_rep_sens_rel") then
				nextPosition = getNextPositionAttrRepSensRel(object, sensors, config, iterationCount)
				currentPosition = {0, 0, 0}
			elseif (config.mode == "attr_rep_dist_abs") then
				nextPosition = getNextPositionAttrRepDistAbs(object, otherObjects, config)
			elseif (config.mode == "test_abs") then
				nextPosition = {3, 3, 3}
			elseif (config.mode == "test_rel") then
				nextPosition = {1, 1, 1}
				currentPosition = {0, 0, 0}
			else
				simAddStatusbarMessage("Next position is NOT calculated for mode: " .. config.mode)
			end

			currentPosition = currentPosition or simGetObjectPosition(object, -1)
			local positionError = substractVectors(nextPosition, currentPosition)

			-- Ajust X with PITCH, Y with ROLL, Z with THROTTLE.
			ajustParameter(positionError[1], xPIDController, config.pitch, script)
			ajustParameter(positionError[2], yPIDController, config.roll, script)
			ajustParameter(positionError[3], zPIDController, config.throttle, script)
		end
	end

	return {
		actuate = actuate
	}
end

function ajustConfig(config)
	config = config or {}

	config.mode = config.mode or "attr_rep_sens_rel"

	config.name = config.name or "SimFinken"
	config.suffix = config.suffix or ""

	config.front_sensor = config.front_sensor or "SimFinken_sensor_front"
	config.back_sensor = config.back_sensor or "SimFinken_sensor_back"
	config.left_sensor = config.left_sensor or "SimFinken_sensor_left"
	config.right_sensor = config.right_sensor or "SimFinken_sensor_right"
	config.bottom_sensor = config.bottom_sensor or "SimFinken_sensor_bottom"

	config.other_suffixes = config.other_suffixes or {}
	config.target = config.target or nil

	config.x_pid = config.x_pid or {}
	config.x_pid.p = config.x_pid.p or 6
	config.x_pid.i = config.x_pid.i or 0
	config.x_pid.d = config.x_pid.d or 8

	config.y_pid = config.y_pid or {}
	config.y_pid.p = config.y_pid.p or 6
	config.y_pid.i = config.y_pid.i or 0
	config.y_pid.d = config.y_pid.d or 8

	config.z_pid = config.z_pid or {}
	config.z_pid.p = config.z_pid.p or 6
	config.z_pid.i = config.z_pid.i or 0
	config.z_pid.d = config.z_pid.d or 8

	config.pitch = config.pitch or {}
	config.pitch.name = config.pitch.name or "pitch"
	config.pitch.min = config.pitch.min or -30
	config.pitch.max = config.pitch.max or 30
	config.pitch.default = config.pitch.default or 0

	config.roll = config.roll or {}
	config.roll.name = config.roll.name or "roll"
	config.roll.min = config.roll.min or -30
	config.roll.max = config.roll.max or 30
	config.roll.default = config.roll.default or 0

	config.throttle = config.throttle or {}
	config.throttle.name = config.throttle.name or "throttle"
	config.throttle.min = config.throttle.min or 0
	config.throttle.max = config.throttle.max or 100
	config.throttle.default = config.throttle.default or 50

	-- b > a, wCohesion + wTarget = 1
	config.attr_rep = config.attr_rep or {}
	config.attr_rep.a = config.attr_rep.a or 0.6
	config.attr_rep.b = config.attr_rep.b or 0.8
	config.attr_rep.c = config.attr_rep.c or 8
	config.attr_rep.wCohesion = config.attr_rep.wCohesion or 0.7
	config.attr_rep.wTarget = config.attr_rep.wTarget or 0.3

	return config
end

function getNextPositionAttrRepSensRel(object, sensors, config, iterationCount)
	local _, frontDist = simReadProximitySensor(sensors.front)
	local _, backDist = simReadProximitySensor(sensors.back)
	local _, leftDist = simReadProximitySensor(sensors.left)
	local _, rightDist = simReadProximitySensor(sensors.right)
	local _, bottomDist = simReadProximitySensor(sensors.bottom)

	if (config.suffix == "") then
		print((frontDist or "f") .. " " .. (backDist or "b") .. " " .. (leftDist or "l") .. " " .. (rightDist or "r") .. " " .. (bottomDist or "bt"))
	end
	
	local objectPosition = {0, 0, 0}
	objectPosition[3] = 2 - (bottomDist or 2)
	
	local otherObjectPositions = {}
	local hasDetectedSomething = false
	
	if(frontDist) then
		table.insert(otherObjectPositions, {objectPosition[1] - frontDist, objectPosition[2], objectPosition[3]})
		hasDetectedSomething = true
	end
	
	if(backDist) then
		table.insert(otherObjectPositions, {objectPosition[1] + backDist, objectPosition[2], objectPosition[3]})
		hasDetectedSomething = true
	end
	
	if(leftDist) then
		table.insert(otherObjectPositions, {objectPosition[1], objectPosition[2] - leftDist, objectPosition[3]})
		hasDetectedSomething = true
	end
	
	if(rightDist) then
		table.insert(otherObjectPositions, {objectPosition[1], objectPosition[2] + rightDist, objectPosition[3]})
		hasDetectedSomething = true
	end
		
	if(hasDetectedSomething == false) then
		if(iterationCount % 10 == 0) then
			table.insert(otherObjectPositions, getRandomDirection(objectPosition))
		end
	end

	return getAttractionRepulsionPosition(objectPosition, otherObjectPositions, nil, config.attr_rep)
end

function getNextPositionAttrRepDistAbs(object, otherObjects, config)
	local currentPosition = simGetObjectPosition(object, -1)

	local otherObjectPositions = {}
	for _, otherObject in ipairs(otherObjects) do
		table.insert(otherObjectPositions, simGetObjectPosition(otherObject, -1))
	end

	return getAttractionRepulsionPosition(currentPosition, otherObjectPositions, config.target, config.attr_rep)
end

function getAttractionRepulsionPosition(currentPosition, otherObjectPositions, targetPosition, config)
	local positionChange = {0, 0, 0}
	
	for _, otherObjectPosition in ipairs(otherObjectPositions) do
		local distance = euclideanDistance(currentPosition, otherObjectPosition)
		local repultion = config.b * math.exp(- (distance ^ 2) / config.c)
		
		local positionDifference = substractVectors(currentPosition, otherObjectPosition)
		positionChange = addVectors(positionChange, multiplyVectorByScalar(positionDifference, repultion - config.a))
	end

	if (targetPosition) then
		positionChange = multiplyVectorByScalar(positionChange, config.wCohesion)

		local positionDifference = substractVectors(targetPosition, currentPosition)
		positionChange = addVectors(positionChange, multiplyVectorByScalar(positionDifference, config.a * config.wTarget))
	end

	return addVectors(currentPosition, positionChange)
end

function euclideanDistance(position1, position2)
	local vector = substractVectors(position1, position2)
	local scalarProduct = scalarProduct(vector, vector)

	return math.sqrt(scalarProduct)
end

function addVectors(vector1, vector2)
	return {
		vector1[1] + vector2[1], 
		vector1[2] + vector2[2], 
		vector1[3] + vector2[3]
	}
end

function substractVectors(vector1, vector2)
	return {
		vector1[1] - vector2[1], 
		vector1[2] - vector2[2], 
		vector1[3] - vector2[3]
	}
end

function multiplyVectorByScalar(vector, scalar)
	return {
		vector[1] * scalar,
		vector[2] * scalar,
		vector[3] * scalar
	}
end

function scalarProduct(vector1, vector2)
	return vector1[1] * vector2[1] 
		+ vector1[2] * vector2[2] 
		+ vector1[3] * vector2[3]
end

function getRandomDirection(position)
	local directions = {
		{position[1] - 0.5, position[2], position[3]},
		{position[1] + 0.5, position[2], position[3]},
		{position[1], position[2] - 0.5, position[3]},
		{position[1], position[2] + 0.5, position[3]}
	}
	
	return directions[math.random(4)]
end

function getNameWithSuffix(name, suffix)
	if (suffix == nil or suffix == "") then
		return name
	else
		return name .. "#" .. suffix
	end
end

function ajustParameter(error, pidController, config, script)
	local value = config.default + pidController.adjust(error)

	if (value > config.max) then
		value = config.max
	elseif (value < config.min) then
		value = config.min
	end

	simSetScriptSimulationParameter(script, config.name,  value)
end

function newPIDController(config)
	local integral = 0
	local previousError = 0

	function adjust(error)
		local timeStep = simGetSimulationTimeStep()

		integral = integral + (error * timeStep)
		local derivative = (error - previousError) / timeStep
		
		-- Prevent unexpected behaviour on the first iteration, because previousError has no valid value.
		if (previousError == 0) then
			derivative = 0
		end
		
		previousError = error

		return (config.p * error) + (config.i * integral) + (config.d * derivative)
	end

	return {
		adjust = adjust
	}
end