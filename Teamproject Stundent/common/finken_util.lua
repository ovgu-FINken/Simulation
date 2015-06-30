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

	local context = {
		randomDirection = {0, 0, 0},
		pitch = 0,
		roll = 0,
		yaw = 0,
		yawIterations = 0,
		iterations = 0
	}

	local xPIDController = newPIDController(config.x_pid)
	local yPIDController = newPIDController(config.y_pid)
	local zPIDController = newPIDController(config.z_pid)

	function actuate()
		local nextPosition, yawChange = getNextPosition(sensors, context, config)

		-- Ajust X with PITCH, Y with ROLL, Z with THROTTLE.
		context.pitch = ajustParameter(nextPosition[1], xPIDController, config.pitch, script)
		context.roll = ajustParameter(nextPosition[2], yPIDController, config.roll, script)
		ajustParameter(nextPosition[3], zPIDController, config.throttle, script)

		-- Ajust YAW by keeping it between 0 and 90. yawChange is nil or positive value.
		if (yawChange) then
			local newYaw = context.yaw + yawChange
			if (newYaw > 90) then
				newYaw = newYaw - 90
			end

			simSetScriptSimulationParameter(script, "yaw", newYaw)
			context.yaw = newYaw
		end

		context.iterations = context.iterations + 1
	end

	return {
		actuate = actuate
	}
end

function ajustConfig(config)
	config = config or {}

	config.name = config.name or "SimFinken"
	config.suffix = config.suffix or ""
	config.height = config.height or 2.4

	config.front_sensor = config.front_sensor or "SimFinken_sensor_front"
	config.back_sensor = config.back_sensor or "SimFinken_sensor_back"
	config.left_sensor = config.left_sensor or "SimFinken_sensor_left"
	config.right_sensor = config.right_sensor or "SimFinken_sensor_right"
	config.bottom_sensor = config.bottom_sensor or "SimFinken_sensor_bottom"

	config.x_pid = config.x_pid or {}
	config.x_pid.p = config.x_pid.p or 4
	config.x_pid.i = config.x_pid.i or 0
	config.x_pid.d = config.x_pid.d or 6

	config.y_pid = config.y_pid or {}
	config.y_pid.p = config.y_pid.p or 4
	config.y_pid.i = config.y_pid.i or 0
	config.y_pid.d = config.y_pid.d or 6

	config.z_pid = config.z_pid or {}
	config.z_pid.p = config.z_pid.p or 4
	config.z_pid.i = config.z_pid.i or 0
	config.z_pid.d = config.z_pid.d or 6

	config.pitch = config.pitch or {}
	config.pitch.name = config.pitch.name or "pitch"
	config.pitch.min = config.pitch.min or -15
	config.pitch.max = config.pitch.max or 15
	config.pitch.default = config.pitch.default or 0

	config.roll = config.roll or {}
	config.roll.name = config.roll.name or "roll"
	config.roll.min = config.roll.min or -15
	config.roll.max = config.roll.max or 15
	config.roll.default = config.roll.default or 0

	config.throttle = config.throttle or {}
	config.throttle.name = config.throttle.name or "throttle"
	config.throttle.min = config.throttle.min or 0
	config.throttle.max = config.throttle.max or 100
	config.throttle.default = config.throttle.default or 50

	-- b > a, wCohesion + wTarget = 1
	config.attr_rep = config.attr_rep or {}
	config.attr_rep.a = config.attr_rep.a or 0.6
	config.attr_rep.b = config.attr_rep.b or 0.9
	config.attr_rep.c = config.attr_rep.c or 4
	config.attr_rep.wCohesion = config.attr_rep.wCohesion or 0.9
	config.attr_rep.wTarget = config.attr_rep.wTarget or 0.1

	return config
end

function getNameWithSuffix(name, suffix)
	if (suffix == nil or suffix == "") then
		return name
	else
		return name .. "#" .. suffix
	end
end

function getNextPosition(sensors, context, config)
	local _, frontDistance = simReadProximitySensor(sensors.front)
	local _, backDistance = simReadProximitySensor(sensors.back)
	local _, leftDistance = simReadProximitySensor(sensors.left)
	local _, rightDistance = simReadProximitySensor(sensors.right)
	local _, bottomDistance = simReadProximitySensor(sensors.bottom)

	local objectPosition = {0, 0, 0}

	if (bottomDistance) then
		local pitchTan = math.tan(math.rad(context.pitch))
		local rollTan = math.tan(math.rad(context.roll))

		bottomDistance = bottomDistance / math.sqrt(1 + pitchTan ^ 2 + rollTan ^ 2)
		objectPosition[3] = config.height - bottomDistance
	end

	local yawChange = nil

	local frontEnabled = true
	local backEnabled = true
	local leftEnabled = true
	local rightEnabled = true 

	if areDistancesToWall(frontDistance, leftDistance, backDistance) or areDistancesToWall(frontDistance, rightDistance, backDistance) then
		frontEnabled = false
		backEnabled = false

		yawChange = math.deg(math.atan2(backDistance, frontDistance))
	elseif areDistancesToWall(leftDistance, frontDistance, rightDistance) or areDistancesToWall(leftDistance, backDistance, rightDistance) then
		leftEnabled = false
		rightEnabled = false

		yawChange = math.deg(math.atan2(rightDistance, leftDistance))
	end

	if yawChange then
		context.yawIterations = context.yawIterations + 1
		if context.yawIterations > 15 then
			context.yawIterations = 0
		else
			yawChange = nil
		end
	else
		context.yawIterations = 0
	end

	local otherObjectPositions = {}

	if(frontDistance and frontEnabled) then
		table.insert(otherObjectPositions, {-frontDistance, 0, 0})
	end

	if(backDistance and backEnabled) then
		table.insert(otherObjectPositions, {backDistance, 0, 0})
	end

	if(leftDistance and leftEnabled) then
		table.insert(otherObjectPositions, {0, -leftDistance, 0})
	end

	if(rightDistance and rightEnabled) then
		table.insert(otherObjectPositions, {0, rightDistance, 0})
	end

	if(context.iterations % 10 == 0) then
		local change = 1
		
		if (context.iterations > 0 and not (frontDistance or backDistance or leftDistance or rightDistance)) then
			change = 4 * change
		end

		context.randomDirection = {
			change * math.random(-1, 1), 
			change * math.random(-1, 1), 
			0
		}
	end

	if yawChange then
		otherObjectPositions = {}
		context.randomDirection = {0, 0, 0}
	end

	local nextPosition = getAttractionRepulsionPosition(objectPosition, otherObjectPositions, context.randomDirection, config.attr_rep)

	return nextPosition, yawChange
end

function areDistancesToWall(left, middle, right)
	if (left and middle and right) then
		local possibleMiddle = left * right / math.sqrt(left ^ 2 + right ^ 2)
		
		return math.abs(middle - possibleMiddle) < 0.05
	else
		return false
	end
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

function ajustParameter(error, pidController, config, script)
	local value = config.default + pidController.adjust(error)

	if (value > config.max) then
		value = config.max
	elseif (value < config.min) then
		value = config.min
	end

	simSetScriptSimulationParameter(script, config.name,  value)

	return value
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