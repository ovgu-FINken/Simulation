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

function newFinken(object)
	local script = simGetScriptAssociatedWithObject(object)

	local xPIDController = newPIDController(5, 0, 8)
	local yPIDController = newPIDController(5, 0, 8)
	local velocityPIDController = newPIDController(1, 0, 1)

	local maxPitch = 30
	local minPitch = -30

	local maxRoll = 30
	local minRoll = -30

	local previousPosition = simGetObjectPosition(object, -1)

	function move(targetPosition)
		local currentPosition = simGetObjectPosition(object, -1)

		-- Manipulate X with pitch ajustment.
		local targetX = targetPosition[1]
		local currentX = currentPosition[1]
		
		local pitchError = xPIDController.adjust(targetX - currentX)

		if (pitchError > maxPitch) then
			pitchError = maxPitch
		elseif (pitchError < minPitch) then
			pitchError = minPitch
		end

		simSetScriptSimulationParameter(script, 'pitch', pitchError)

		-- Manipulate Y with roll adjustment.
		local targetY = targetPosition[2]
		local currentY = currentPosition[2]
		
		local rollError = -1 * yPIDController.adjust(targetY - currentY)

		if (rollError > maxRoll) then
			rollError = maxRoll
		elseif (rollError < minRoll) then
			rollError = minRoll
		end

		simSetScriptSimulationParameter(script, 'roll', rollError)

		-- Manipulate Z with velocity-thorottle ajustment.
		local timeStep = simGetSimulationTimeStep()

		local targetZ = targetPosition[3]
		local currentZ = currentPosition[3]
		local previousZ = previousPosition[3]

		local targetVelocity = (targetZ - currentZ) / timeStep
		local currentVelocity = (currentZ - previousZ) / timeStep
	
		local throttleError = velocityPIDController.adjust(targetVelocity - currentVelocity)

		simSetScriptSimulationParameter(script, 'throttle', 50 + throttleError)

		-- Update previous position
		previousPosition = currentPosition
	end

	return {
		move = move
	}
end