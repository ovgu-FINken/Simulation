function newFinken(config)
	config = prepareConfig(config)

	local object = getObjectHandle(config.object, config)
	local script = simGetScriptAssociatedWithObject(object)

	local sensors = {
		front = getObjectHandle(config.sensor.front, config),
		back = getObjectHandle(config.sensor.back, config),
		left = getObjectHandle(config.sensor.left, config),
		right = getObjectHandle(config.sensor.right, config),
		bottom = getObjectHandle(config.sensor.bottom, config)
	}

	local pidControllers = {
		x = newPIDController(config.pid.x),
		y = newPIDController(config.pid.y),
		z = newPIDController(config.pid.z)
	}

	local context = {
		randomDirection = {0, 0, 0},
		iterations = {
			global = 0,
			frontWall = {value = 0},
			backWall = {value = 0},
			leftWall = {value = 0},
			rightWall = {value = 0}
		}
	}

	function actuate()
		local orientation = getObjectOrientation(object)
		local errors = getErrors(orientation, sensors, context, config)

		ajustParameter(errors.x, pidControllers.x, config.pitch, script)
		ajustParameter(errors.y, pidControllers.y, config.roll, script)
		ajustParameter(errors.z, pidControllers.z, config.throttle, script)

		ajustYaw(errors.yaw, orientation, config.yaw, script)

		context.iterations.global = context.iterations.global + 1
	end

	return {
		actuate = actuate
	}
end

function prepareConfig(config)
	config = config or {}

	config.object = config.object or "SimFinken"
	config.suffix = config.suffix or ""
	config.height = config.height or 2.4

	config.sensor = config.sensor or {}	
	config.sensor.front = config.sensor.front or "SimFinken_sensor_front"
	config.sensor.back = config.sensor.back or "SimFinken_sensor_back"
	config.sensor.left = config.sensor.left or "SimFinken_sensor_left"
	config.sensor.right = config.sensor.right or "SimFinken_sensor_right"
	config.sensor.bottom = config.sensor.bottom or "SimFinken_sensor_bottom"

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
	config.pitch.name = config.pitch.name or "pitch"
	config.pitch.min = config.pitch.min or -10
	config.pitch.max = config.pitch.max or 10
	config.pitch.default = config.pitch.default or 0

	config.roll = config.roll or {}
	config.roll.name = config.roll.name or "roll"
	config.roll.min = config.roll.min or -10
	config.roll.max = config.roll.max or 10
	config.roll.default = config.roll.default or 0

	config.throttle = config.throttle or {}
	config.throttle.name = config.throttle.name or "throttle"
	config.throttle.min = config.throttle.min or 0
	config.throttle.max = config.throttle.max or 100
	config.throttle.default = config.throttle.default or 50

	config.yaw = config.yaw or {}
	config.yaw.name = config.yaw.name or "yaw"

	-- b > a, wCohesion + wTarget = 1
	config.attr_rep = config.attr_rep or {}
	config.attr_rep.a = config.attr_rep.a or 1
	config.attr_rep.b = config.attr_rep.b or 4
	config.attr_rep.c = config.attr_rep.c or 1.5
	config.attr_rep.wCohesion = config.attr_rep.wCohesion or 0.8
	config.attr_rep.wTarget = config.attr_rep.wTarget or 0.2

	return config
end

function getObjectHandle(name, config)
	if config.suffix then
		name = name .. "#" .. config.suffix
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

function getErrors(orientation, sensors, context, config)
	local errors = {}

	local _, frontDistance = simReadProximitySensor(sensors.front)
	local _, backDistance = simReadProximitySensor(sensors.back)
	local _, leftDistance = simReadProximitySensor(sensors.left)
	local _, rightDistance = simReadProximitySensor(sensors.right)
	local _, bottomDistance = simReadProximitySensor(sensors.bottom)

	if bottomDistance then
		local frontFloor = isDistanceToFloor(frontDistance, bottomDistance, orientation.pitch)
		local backFloor = isDistanceToFloor(backDistance, bottomDistance, -orientation.pitch)
		local leftFloor = isDistanceToFloor(leftDistance, bottomDistance, orientation.roll)
		local rightFloor = isDistanceToFloor(rightDistance, bottomDistance, -orientation.roll)

		local frontWall, frontYawChange = areDistancesToWall(frontDistance, leftDistance, rightDistance, context.iterations.frontWall)
		local backWall, backYawChange = areDistancesToWall(backDistance, leftDistance, rightDistance, context.iterations.backWall)
		local leftWall, leftYawChange = areDistancesToWall(leftDistance, frontDistance, backDistance, context.iterations.leftWall)
		local rightWall, rightYawChange = areDistancesToWall(rightDistance, frontDistance, backDistance, context.iterations.rightWall)

		local otherObjectPositions = {}
		local sensedDirections = {
			front = false, 
			back = false, 
			left = false, 
			right = false
		}

		if frontDistance and not (frontFloor or leftWall or rightWall) then
			table.insert(otherObjectPositions, {-frontDistance, 0, 0})
			sensedDirections.front = true
		end

		if backDistance and not (backFloor or leftWall or rightWall) then
			table.insert(otherObjectPositions, {backDistance, 0, 0})
			sensedDirections.back = true
		end

		if leftDistance and not (leftFloor or frontWall or backWall) then
			table.insert(otherObjectPositions, {0, -leftDistance, 0})
			sensedDirections.left = true
		end

		if rightDistance and not (rightFloor or frontWall or backWall) then
			table.insert(otherObjectPositions, {0, rightDistance, 0})
			sensedDirections.right = true
		end

		local heightError = config.height - bottomDistance
		local heightUnstable = math.abs(heightError) > 0.2

		local yawChange = frontYawChange or backYawChange or leftYawChange or rightYawChange

		if heightUnstable or yawChange then
			context.randomDirection = {0, 0, 0}
		else
			if(context.iterations.global % 20 == 0) then
				context.randomDirection = {0, 0, 0}

				if not sensedDirections.front then
					context.randomDirection[1] = math.random(-1, 0)
				end

				if not sensedDirections.back then
					context.randomDirection[1] = context.randomDirection[1] + math.random(0, 1)
				end

				if not sensedDirections.left then
					context.randomDirection[2] = math.random(-1, 0)
				end

				if not sensedDirections.right then
					context.randomDirection[2] = context.randomDirection[2] + math.random(0, 1)
				end

				local change = 3
				
				if not (frontDistance or backDistance or leftDistance or rightDistance) then
					change = 2 * change
				end

				context.randomDirection[1] = context.randomDirection[1] * change
				context.randomDirection[2] = context.randomDirection[2] * change
			end
		end

		local nextPosition = getAttractionRepulsionPosition(otherObjectPositions, context.randomDirection, config.attr_rep)
		errors.x = nextPosition[1]
		errors.y = nextPosition[2]
		errors.z = heightError

		if frontYawChange or backYawChange then
			errors.yaw = getYawError(rightDistance, leftDistance)
		end

		if leftYawChange or rightYawChange then
			errors.yaw = getYawError(backDistance, frontDistance)
		end
	end

	return errors
end

function isDistanceToFloor(distance, bottomDistance, angle)
	if distance then
		local possibleDistance = bottomDistance / math.cos(math.rad(45 + angle))

		return math.abs(distance - possibleDistance) < 0.15
	end

	return false
end

function areDistancesToWall(middle, left, right, iterations)
	local distancesToWall = false
	local yawChange = false
	local iterationsValueCleaned = true

	if (middle and left and right) then
		local possibleMiddle = left * right / math.sqrt(left ^ 2 + right ^ 2)
		
		if math.abs(middle - possibleMiddle) < 0.05 then
			distancesToWall = true

			iterations.value = iterations.value + 1
			if iterations.value > 15 then
				yawChange = true
			else
				iterationsValueCleaned = false
			end
		end
	end

	if iterationsValueCleaned then
		iterations.value = 0
	end

	return distancesToWall, yawChange
end

function getYawError(distance1, distance2)
	return math.deg(math.atan2(distance1, distance2))
end

function getAttractionRepulsionPosition(otherObjectPositions, targetPosition, config)
	local positionChange = {0, 0, 0}
	
	for _, otherObjectPosition in ipairs(otherObjectPositions) do
		local norm = getEuclideanNorm(otherObjectPosition)
		local repultion = config.b * math.exp(-(norm ^ 2) / config.c)
		
		positionChange = addVectors(positionChange, multiplyVectorByScalar(otherObjectPosition, config.a - repultion))
	end

	positionChange = multiplyVectorByScalar(positionChange, config.wCohesion)
	local targetChange = multiplyVectorByScalar(targetPosition, config.a * config.wTarget)

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

function ajustYaw(adjustment, orientation, config, script)
	if adjustment then
		if adjustment < 0 then
			simAddStatusbarMessage("ERROR: adjustment < 0. It should be positive!")
		end

		local yaw = orientation.yaw + adjustment

		if yaw > 90 then
			yaw = yaw - 90
		end

		simSetScriptSimulationParameter(script, config.name, yaw)
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
			
			-- Prevent unexpected behaviour on the first iteration, because previousError has no valid value.
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