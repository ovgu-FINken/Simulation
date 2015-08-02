function newFinken(config)
	config = prepareConfig(config)

	local object = getObjectHandle("SimFinken", config.suffix)
	local script = simGetScriptAssociatedWithObject(object)

	local sensors = {
		front = getObjectHandle("SimFinken_sensor_front", config.suffix),
		back = getObjectHandle("SimFinken_sensor_back", config.suffix),
		left = getObjectHandle("SimFinken_sensor_left", config.suffix),
		right = getObjectHandle("SimFinken_sensor_right", config.suffix),
		bottom = getObjectHandle("SimFinken_sensor_bottom", config.suffix)
	}

	local context = {
		counters = {
			global = 0,
			wallDetectedFront = {value = 0},
			wallDetectedBack = {value = 0},
			wallDetectedLeft = {value = 0},
			wallDetectedRight = {value = 0}
		},
		detectedDistances = {
			front = nil,
			back = nil,
			left = nil,
			right = nil,
			bottom = nil
		},
		randomPosition = {0, 0, 0}
	}

	local pidControllers = {
		x = newPIDController(config.pid.x),
		y = newPIDController(config.pid.y),
		z = newPIDController(config.pid.z)
	}

	-- Side effect: The attribute context is updated.
	function actuate()
		local orientation = getObjectOrientation(object)
		local errors = getErrors(orientation, sensors, context, config)

		adjustParameter("pitch", errors.x, pidControllers.x, config.pitch, script)
		adjustParameter("roll", errors.y, pidControllers.y, config.roll, script)
		adjustParameter("throttle", errors.z, pidControllers.z, config.throttle, script)

		adjustYaw(errors.yaw, orientation, script)

		context.counters.global = context.counters.global + 1
	end
	
	function getConfig()
		return config
	end

	function getDetectedDistances()
		return context.detectedDistances
	end

	return {
		actuate = actuate,
		getConfig = getConfig,
		getDetectedDistances = getDetectedDistances
	}
end

-- Side effect: The parameter config is updated.
function prepareConfig(config)
	config = config or {}

	if not config.suffix then
		simAddStatusbarMessage("WARN: config.suffix is nil. It will be set to its default value. The suffix of an existing finken should be passed as an argument e.g. newFinken{suffix=''}, newFinken{suffix='1'}!")
		config.suffix = ""
	end

	config.height = config.height or {}
	config.height.value = config.height.value or 2.4
	config.height.stability_range = config.height.stability_range or 0.2

	config.pid = config.pid or {}

	config.pid.x = config.pid.x or {}
	config.pid.x.p = config.pid.x.p or 2
	config.pid.x.i = config.pid.x.i or 0
	config.pid.x.d = config.pid.x.d or 4

	config.pid.y = config.pid.y or {}
	config.pid.y.p = config.pid.y.p or 2
	config.pid.y.i = config.pid.y.i or 0
	config.pid.y.d = config.pid.y.d or 4

	config.pid.z = config.pid.z or {}
	config.pid.z.p = config.pid.z.p or 6
	config.pid.z.i = config.pid.z.i or 0
	config.pid.z.d = config.pid.z.d or 8

	config.pitch = config.pitch or {}
	config.pitch.min = config.pitch.min or -10
	config.pitch.max = config.pitch.max or 10
	config.pitch.default = config.pitch.default or 0

	config.roll = config.roll or {}
	config.roll.min = config.roll.min or -10
	config.roll.max = config.roll.max or 10
	config.roll.default = config.roll.default or 0

	config.throttle = config.throttle or {}
	config.throttle.min = config.throttle.min or 0
	config.throttle.max = config.throttle.max or 100
	config.throttle.default = config.throttle.default or 50

	config.floor_detection = config.floor_detection or {}
	config.floor_detection.difference_range = config.floor_detection.difference_range or 0.15

	config.wall_detection = config.wall_detection or {}
	config.wall_detection.difference_range = config.wall_detection.difference_range or 0.05
	config.wall_detection.yaw_change_required_interval = config.wall_detection.yaw_change_required_interval or 15

	config.random_position = config.random_position or {}
	config.random_position.update_interval = config.random_position.update_interval or 20
	config.random_position.object_detected_factor = config.random_position.object_detected_factor or 3
	config.random_position.no_object_detected_factor = config.random_position.no_object_detected_factor or 6

	-- b > a, wCohesion + wTarget = 1
	config.attraction_repulsion = config.attraction_repulsion or {}
	config.attraction_repulsion.a = config.attraction_repulsion.a or 1
	config.attraction_repulsion.b = config.attraction_repulsion.b or 4
	config.attraction_repulsion.c = config.attraction_repulsion.c or 1.5
	config.attraction_repulsion.wCohesion = config.attraction_repulsion.wCohesion or 0.8
	config.attraction_repulsion.wTarget = config.attraction_repulsion.wTarget or 0.2

	return config
end

function getObjectHandle(name, suffix)
	if suffix and suffix ~= "" then
		name = name .. "#" .. suffix
	end

	return simGetObjectHandle(name)
end

function getObjectOrientation(object)
	local orientation = simGetObjectOrientation(object, -1)

	return {
		pitch = math.deg(orientation[3]) + 90,
		roll = -(math.deg(orientation[1]) + 90),
		yaw = -math.deg(orientation[2])
	}
end

-- Side effect: The parameter context is updated.
function getErrors(orientation, sensors, context, config)
	local errors = {}

	local _, frontDistance = simReadProximitySensor(sensors.front)
	local _, backDistance = simReadProximitySensor(sensors.back)
	local _, leftDistance = simReadProximitySensor(sensors.left)
	local _, rightDistance = simReadProximitySensor(sensors.right)
	local _, bottomDistance = simReadProximitySensor(sensors.bottom)

	if bottomDistance then
		local floorDetectedFront = isDistanceToFloor(frontDistance, bottomDistance, -orientation.pitch, config.floor_detection)
		local floorDetectedBack = isDistanceToFloor(backDistance, bottomDistance, orientation.pitch, config.floor_detection)
		local floorDetectedLeft = isDistanceToFloor(leftDistance, bottomDistance, -orientation.roll, config.floor_detection)
		local floorDetectedRight = isDistanceToFloor(rightDistance, bottomDistance, orientation.roll, config.floor_detection)

		local wallDetectedFront, yawChangeRequiredFront = areDistancesToWall(frontDistance, leftDistance, rightDistance, context.counters.wallDetectedFront, config.wall_detection)
		local wallDetectedBack, yawChangeRequiredBack = areDistancesToWall(backDistance, leftDistance, rightDistance, context.counters.wallDetectedBack, config.wall_detection)
		local wallDetectedLeft, yawChangeRequiredLeft = areDistancesToWall(leftDistance, frontDistance, backDistance, context.counters.wallDetectedLeft, config.wall_detection)
		local wallDetectedRight, yawChangeRequiredRight = areDistancesToWall(rightDistance, frontDistance, backDistance, context.counters.wallDetectedRight, config.wall_detection)

		if yawChangeRequiredFront or yawChangeRequiredBack then
			errors.yaw = getYawError(leftDistance, rightDistance)
		elseif yawChangeRequiredLeft or yawChangeRequiredRight then
			errors.yaw = getYawError(frontDistance, backDistance)
		end

		local otherObjectPositions = {}
		context.detectedDistances = {
			bottom = bottomDistance
		}

		if frontDistance and not (floorDetectedFront or wallDetectedLeft or wallDetectedRight) then
			table.insert(otherObjectPositions, {-frontDistance, 0, 0})
			context.detectedDistances.front = frontDistance
		end

		if backDistance and not (floorDetectedBack or wallDetectedLeft or wallDetectedRight) then
			table.insert(otherObjectPositions, {backDistance, 0, 0})
			context.detectedDistances.back = backDistance
		end

		if leftDistance and not (floorDetectedLeft or wallDetectedFront or wallDetectedBack) then
			table.insert(otherObjectPositions, {0, -leftDistance, 0})
			context.detectedDistances.left = leftDistance
		end

		if rightDistance and not (floorDetectedRight or wallDetectedFront or wallDetectedBack) then
			table.insert(otherObjectPositions, {0, rightDistance, 0})
			context.detectedDistances.right = rightDistance
		end

		local heightError = config.height.value - bottomDistance
		local heightStable = math.abs(heightError) < config.height.stability_range
		
		local finkenStable = heightStable and not (yawChangeRequiredFront or yawChangeRequiredBack or yawChangeRequiredLeft or yawChangeRequiredRight)
		local objectDetected = frontDistance or backDistance or leftDistance or rightDistance
		updateContextRandomPosition(finkenStable, objectDetected, context, config.random_position)

		local nextPosition = getAttractionRepulsionPosition(otherObjectPositions, context.randomPosition, config.attraction_repulsion)
		errors.x = nextPosition[1]
		errors.y = nextPosition[2]
		errors.z = heightError
	end

	return errors
end

function isDistanceToFloor(distance, bottomDistance, angle, config)
	if distance then
		local possibleDistance = bottomDistance / math.cos(math.rad(45 - angle))

		return math.abs(distance - possibleDistance) < config.difference_range
	else
		return false
	end
end

-- Side effect: The parameter counter.value is updated.
function areDistancesToWall(middleDistance, leftDistance, rightDistance, counter, config)
	local wallDetected = false
	local yawChangeRequired = false
	local counterResetRequired = true

	if (middleDistance and leftDistance and rightDistance) then
		local possibleMiddleDistance = leftDistance * rightDistance / math.sqrt(leftDistance ^ 2 + rightDistance ^ 2)
		
		if math.abs(middleDistance - possibleMiddleDistance) < config.difference_range then
			wallDetected = true

			counter.value = counter.value + 1
			if counter.value > config.yaw_change_required_interval then
				yawChangeRequired = true
			else
				counterResetRequired = false
			end
		end
	end

	if counterResetRequired then
		counter.value = 0
	end

	return wallDetected, yawChangeRequired
end

-- The parameters have the same semantic as in areDistancesToWall(...)
function getYawError(leftDistance, rightDistance)
	return math.deg(math.atan2(leftDistance, rightDistance))
end

-- Side effect: The parameter context.randomPosition is updated!
function updateContextRandomPosition(finkenStable, objectDetected, context, config)
	if finkenStable then
		if(context.counters.global % config.update_interval == 0) then
			context.randomPosition = {0, 0, 0}

			if not context.detectedDistances.front then
				context.randomPosition[1] = math.random(-1, 0)
			end

			if not context.detectedDistances.back then
				context.randomPosition[1] = context.randomPosition[1] + math.random(0, 1)
			end

			if not context.detectedDistances.left then
				context.randomPosition[2] = math.random(-1, 0)
			end

			if not context.detectedDistances.right then
				context.randomPosition[2] = context.randomPosition[2] + math.random(0, 1)
			end

			local factor

			if objectDetected then
				factor = config.object_detected_factor
			else
				factor = config.no_object_detected_factor
			end

			context.randomPosition[1] = context.randomPosition[1] * factor
			context.randomPosition[2] = context.randomPosition[2] * factor
		end
	else
		context.randomPosition = {0, 0, 0}
	end
end

function getAttractionRepulsionPosition(otherObjectPositions, targetPosition, config)
	local positionChange = {0, 0, 0}
	
	for _, otherObjectPosition in ipairs(otherObjectPositions) do
		local euclideanNorm = getEuclideanNorm(otherObjectPosition)
		local repulsion = config.b * math.exp(-(euclideanNorm ^ 2) / config.c)
		
		positionChange = addVectors(positionChange, multiplyVectorByScalar(otherObjectPosition, config.a - repulsion))
	end

	positionChange = multiplyVectorByScalar(positionChange, config.wCohesion)
	local targetChange = multiplyVectorByScalar(targetPosition, config.wTarget * config.a)

	return addVectors(positionChange, targetChange)
end

function getEuclideanNorm(position)
	local scalarProduct = scalarProduct(position, position)

	return math.sqrt(scalarProduct)
end

function addVectors(vector1, vector2)
	return {
		vector1[1] + vector2[1], 
		vector1[2] + vector2[2], 
		vector1[3] + vector2[3]
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

function adjustParameter(parameter, error, pidController, config, script)
	local value = config.default + pidController.adjust(error)

	if (value > config.max) then
		value = config.max
	elseif (value < config.min) then
		value = config.min
	end

	simSetScriptSimulationParameter(script, parameter, value)

	return value
end

function adjustYaw(error, orientation, script)
	if error then
		if error < 0 then
			simAddStatusbarMessage("ERROR: The parameter error < 0 for adjustYaw(...). It should be positive!")
		end

		local yaw = orientation.yaw + error

		if yaw > 90 then
			yaw = yaw - 90
		end

		simSetScriptSimulationParameter(script, "yaw", yaw)
	end
end

function newPIDController(config)
	local integral = 0
	local previousError = 0

	function adjust(error)
		if error then
			local timeStep = simGetSimulationTimeStep()

			integral = integral + (error * timeStep)
			local derivative = (error - previousError) / timeStep
			
			-- Prevent unexpected behavior on the first iteration, because previousError has no valid value.
			if (previousError == 0) then
				derivative = 0
			end
			
			previousError = error

			return (config.p * error) + (config.i * integral) + (config.d * derivative)
		else
			simAddStatusbarMessage("INFO: PID controller is reset.")

			integral = 0
			previousError = 0

			return 0
		end
	end

	return {
		adjust = adjust
	}
end