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

	function move(swarmTargetPosition)
		local targetPosition = {0,0,0}
		if(otherObjects) then
			targetPosition = getTargetPosition(object, otherObjects, swarmTargetPosition)
		else
			targetPosition = swarmTargetPosition
		end

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
	local a = 0.4
	local b = 0.5
	local c = 5
	local sum = {0, 0, 0}
	
	local objectPosition = simGetObjectPosition(object, -1)
	
	for _, otherObject in ipairs(otherObjects) do
		local repultion = b * math.exp(- (euclideanDistance(object, otherObject) ^ 2) / c)
		
		local otherObjectPosition = simGetObjectPosition(otherObject, -1)
		local vec = substractVectors(objectPosition, otherObjectPosition)
		local func =  multiplyVectorByScalar(vec, repultion - a)
		
		sum = addVectors(sum, func)
	end

	--sum = multiplyVectorByScalar(sum, 0.7)

	return addVectors(objectPosition, sum)

	--local targetFunc = substractVectors(targetPosition, objectPosition)
	
	--return addVectors(result, multiplyVectorByScalar(targetFunc,a * 0.3))
end

function euclideanDistance(object1, object2)
	local position1 = simGetObjectPosition(object1, -1)
	local position2 = simGetObjectPosition(object2, -1)

	local sum = (position1[1] - position2[1]) ^ 2 
				+ (position1[2] - position2[2]) ^ 2
				+ (position1[3] - position2[3]) ^ 2

	return math.sqrt(sum)
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