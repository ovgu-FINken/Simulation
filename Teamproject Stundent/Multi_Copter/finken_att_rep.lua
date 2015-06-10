function newFinken(object, otherObjects)
	local script = simGetScriptAssociatedWithObject(object)

	local xPIDController = newPIDController(6, 0, 8)
	local yPIDController = newPIDController(6, 0, 8)
	local velocityPIDController = newPIDController(1, 0, 1)

	local maxPitch = 30
	local minPitch = -30

	local maxRoll = 30
	local minRoll = -30

	local previousPosition = simGetObjectPosition(object, -1)

	function move(leaderTargetPosition)
		local targetPosition = getTargetPosition(object, otherObjects, leaderTargetPosition)
		local currentPosition = simGetObjectPosition(object, -1)

		-- Manipulate X with pitch ajustment.
		local pitchError = xPIDController.adjust(targetPosition[1] - currentPosition[1])

		if (pitchError > maxPitch) then
			pitchError = maxPitch
		elseif (pitchError < minPitch) then
			pitchError = minPitch
		end

		simSetScriptSimulationParameter(script, 'pitch', pitchError)

		-- Manipulate Y with roll adjustment.
		local rollError = yPIDController.adjust(targetPosition[2] - currentPosition[2])

		if (rollError > maxRoll) then
			rollError = maxRoll
		elseif (rollError < minRoll) then
			rollError = minRoll
		end

		simSetScriptSimulationParameter(script, 'roll', rollError)

		-- Manipulate Z with velocity-thorottle ajustment.
		local timeStep = simGetSimulationTimeStep()

		local targetVelocity = (targetPosition[3] - currentPosition[3]) / timeStep
		local currentVelocity = (currentPosition[3] - previousPosition[3]) / timeStep
	
		local throttleError = velocityPIDController.adjust(targetVelocity - currentVelocity)

		simSetScriptSimulationParameter(script, 'throttle', 50 + throttleError)

		previousPosition = currentPosition
	end

	return {
		move = move
	}
end

function newPIDController(p, i, d)
	local integral = 0
	local previousError = 0

	function adjust(error)
		local timeStep = simGetSimulationTimeStep()

		integral = integral + (error * timeStep)
		local derivative = (error - previousError) / timeStep

		if (previousError == 0) then
			derivative = 0
		end
		
		previousError = error

		return (p * error) + (i * integral) + (d * derivative)
	end

	return {
		adjust = adjust
	}
end

function getTargetPosition(object, otherObjects, targetPosition)
	-- b > a
	local a = 0.4
	local b = 0.5
	local c = 5

	-- wCohesion + wTarget = 1
	local wCohesion = 0.7
	local wTarget = 0.3

	local sum = {0, 0, 0}
	
	local objectPosition = simGetObjectPosition(object, -1)
	
	for _, otherObject in ipairs(otherObjects) do
		local otherObjectPosition = simGetObjectPosition(otherObject, -1)

		local repultion = b * math.exp(- euclideanDistance(objectPosition, otherObjectPosition, 2) / c)
		
		local vector = substractVectors(objectPosition, otherObjectPosition)
		sum = addVectors(sum, multiplyVectorByScalar(vector, repultion - a))
	end

	if (targetPosition) then
		sum = multiplyVectorByScalar(sum, wCohesion)

		local targetVector = substractVectors(targetPosition, objectPosition)
		sum = addVectors(sum, multiplyVectorByScalar(targetVector, a * wTarget))
	end

	return addVectors(objectPosition, sum)
end

function euclideanDistance(position1, position2, power)
	local vector = substractVectors(position1, position2)
	local scalarProduct = scalarProduct(vector, vector)

	power = power or 1

	if (power == 2) then
		return scalarProduct
	else
		return math.sqrt(scalarProduct) ^ power
	end
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