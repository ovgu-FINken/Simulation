function newFinken(object, suffix, otherObjects)
	local script = simGetScriptAssociatedWithObject(object)

	local xPIDController = newPIDController(6, 0, 8)
	local yPIDController = newPIDController(6, 0, 8)
	local velocityPIDController = newPIDController(1, 0, 1)

	local maxPitch = 30
	local minPitch = -30

	local maxRoll = 30
	local minRoll = -30

	local previousPosition = simGetObjectPosition(object, -1)
	local oldGradient = 0
	local oldDirection = {}
	
	iterationCount = 0

	function move(leaderTargetPosition)
		local targetPosition = getTargetPosition(object,suffix)
		--getTargetPosition(object, otherObjects, leaderTargetPosition)
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
	function getTargetPosition(object, suffix)
		local front = simGetObjectHandle("SimFinken_sensor_front" .. suffix)
		local back = simGetObjectHandle("SimFinken_sensor_back" .. suffix)
		local left = simGetObjectHandle("SimFinken_sensor_left" .. suffix)
		local right = simGetObjectHandle("SimFinken_sensor_right" .. suffix)
		local finken_cam = simGetObjectHandle("Floor_camera" .. suffix)
		
		local _, frontDist = simReadProximitySensor(front)
		local _, backDist = simReadProximitySensor(back)
		local _, leftDist = simReadProximitySensor(left)
		local _, rightDist = simReadProximitySensor(right)
		local _, colors = simReadVisionSensor(finken_cam)
		local gradient = nil
		if(colors == nil) then
			gradient = 1
		else
			gradient = 1 - colors[1]
		end
		local objectPosition = simGetObjectPosition(object, -1);
		objectPosition[3] = 1.5
		
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
		
		if( oldDirection ~= nil and (gradient - oldGradient) < 0 ) then
			otherObjectpositions = oldDirection
			hasDetectedSomething = true
		end
		
		if(hasDetectedSomething == false) then
			iterationCount = iterationCount + 1
			if(iterationCount % 5 == 0) then
				table.insert(otherObjectPositions, getRandomDirection(objectPosition))
				--table.insert(otherObjectPositions, getRandomDirection(objectPosition, frontDist, backDist, leftDist, rightDist))
				simAddStatusbarMessage("Finken" .. suffix .. " Random Mode")
			end
		end
			
		-- b > a
		local a = 0.4
		local b = 0.5
		local c = 4
	
		local sum = {0, 0, 0}
		
		for _, otherObjectPosition in ipairs(otherObjectPositions) do
			local repultion = b * math.exp(- euclideanDistance(objectPosition, otherObjectPosition, 2) / c)
			
			local vector = substractVectors(objectPosition, otherObjectPosition)
			sum = addVectors(sum, multiplyVectorByScalar(vector, repultion - a))
		end
		
		oldGradient = gradient
		oldDirection = otherObjectPositions
		return addVectors(objectPosition, sum)
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



function getRandomDirection(objectPosition)
	local randomDirections = { {objectPosition[1] - 2, objectPosition[2], objectPosition[3]},
							   {objectPosition[1] + 2, objectPosition[2], objectPosition[3]},
							   {objectPosition[1], objectPosition[2] - 2, objectPosition[3]},
							   {objectPosition[1], objectPosition[2] + 2, objectPosition[3]}}
	
	local index = math.random(4)
	return randomDirections[index]
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