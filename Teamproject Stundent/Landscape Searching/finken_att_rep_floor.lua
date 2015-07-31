--this function acts as a constructor for a Finken object
--parameters
--	object - the V-REP object handle of the finken
--  suffix - #number for more than one finken
--	otherObjects - table of all other finken handles to do attraction and repulsion
--returns a table / object reference containing the function move()
function newFinken(object, suffix, otherObjects)
	-- object attributes
	local script = simGetScriptAssociatedWithObject(object)

	local xPIDController = newPIDController(6, 0, 8)
	local yPIDController = newPIDController(6, 0, 8)
	local velocityPIDController = newPIDController(1, 0, 1)

	local maxPitch = 30
	local minPitch = -30

	local maxRoll = 30
	local minRoll = -30
	-- used to store state of the finken for the next iteration
	local previousPosition = simGetObjectPosition(object, -1)
	local oldGradient = 0
	local oldDirection = {}
	-- used only for the random walk to restrict the randomness to specific runs
	iterationCount = 0
	-- finken control function, finken moves towards a target by PID control
	function move()
		local targetPosition = getTargetPosition(object,suffix)
		local currentPosition = simGetObjectPosition(object, -1)

		-- adjust pitch by PID-controller
		local pitchError = xPIDController.adjust(targetPosition[1] - currentPosition[1])
		-- too big peaks are cut off for stability purpose
		if (pitchError > maxPitch) then
			pitchError = maxPitch
		elseif (pitchError < minPitch) then
			pitchError = minPitch
		end

		simSetScriptSimulationParameter(script, 'pitch', pitchError)

		-- adjust roll by PID-controller
		local rollError = yPIDController.adjust(targetPosition[2] - currentPosition[2])
		-- too big peaks are cut off for stability purpose
		if (rollError > maxRoll) then
			rollError = maxRoll
		elseif (rollError < minRoll) then
			rollError = minRoll
		end

		simSetScriptSimulationParameter(script, 'roll', rollError)

		-- adjust Z-velocity by PID-controller
		local timeStep = simGetSimulationTimeStep()

		local targetVelocity = (targetPosition[3] - currentPosition[3]) / timeStep
		local currentVelocity = (currentPosition[3] - previousPosition[3]) / timeStep
	
		local throttleError = velocityPIDController.adjust(targetVelocity - currentVelocity)

		simSetScriptSimulationParameter(script, 'throttle', 50 + throttleError)

		previousPosition = currentPosition
	end
	-- calculates the finken's target based on random walk and attraction
	-- and repulsion if it detects walls or other finkens
	-- parameters
	--	object - the V-REP object handle of the finken
	--  suffix - #number for more than one finken
	function getTargetPosition(object, suffix)
		-- get the sensors to this finken object
		local front = simGetObjectHandle("SimFinken_sensor_front" .. suffix)
		local back = simGetObjectHandle("SimFinken_sensor_back" .. suffix)
		local left = simGetObjectHandle("SimFinken_sensor_left" .. suffix)
		local right = simGetObjectHandle("SimFinken_sensor_right" .. suffix)
		local finken_cam = simGetObjectHandle("Floor_camera" .. suffix)
		-- read the sensor data
		local _, frontDist = simReadProximitySensor(front)
		local _, backDist = simReadProximitySensor(back)
		local _, leftDist = simReadProximitySensor(left)
		local _, rightDist = simReadProximitySensor(right)
		-- the vision sensor finken_cam returns a table of values
		-- the first element colors[1] is the overall lightness of the image
		local _, colors = simReadVisionSensor(finken_cam)
		-- for landscape searching the actual color is stored
		local gradient = nil
		if(colors == nil) then
			gradient = 1 -- if the vision sensor did not return a value the gradient color is set to black
		else
			-- colors[1] == 0 refers to black
			-- to minimze, the gradient is set to 1 - colors[1]
			-- thus, gradient == 0 is white
			gradient = 1 - colors[1] 
		end
		--here, the absolute height is still used
		local objectPosition = simGetObjectPosition(object, -1);
		objectPosition[3] = 1.5
		
		-- stores every object that is detected by the finken
		local otherObjectPositions = {}
		
		local hasDetectedSomething = false
		-- If some sensor detected an object then an approximate position is inserted into the table
		-- based on the sensor that detected the object. Only four horizontal directions are possible.
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
		-- analogously for the landscape gradient, for a negative gradient the old direction
		-- is used for attraction, first iteration is not considered here as there is no gradient. 
		if( oldDirection ~= nil and (gradient - oldGradient) < 0 ) then
			otherObjectpositions = oldDirection
			hasDetectedSomething = true
		end
		
		-- if there is no object to be attracted or repelled then it does a random walk 
		if(hasDetectedSomething == false) then
			iterationCount = iterationCount + 1
			if(iterationCount % 5 == 0) then
				table.insert(otherObjectPositions, getRandomDirection(objectPosition))
				--table.insert(otherObjectPositions, getRandomDirection(objectPosition, frontDist, backDist, leftDist, rightDist))
				simAddStatusbarMessage("Finken" .. suffix .. " Random Mode")
			end
		end
			
		-- b > a
		local a = 0.4 -- linear attraction
		local b = 0.5 -- magnitude of unbounded repulsion
		local c = 4   -- repulsion smoothness factor 
	
		local sum = {0, 0, 0}
		
		for _, otherObjectPosition in ipairs(otherObjectPositions) do
			local repulsion = b * math.exp(- euclideanDistance(objectPosition, otherObjectPosition, 2) / c)
			
			local vector = substractVectors(objectPosition, otherObjectPosition)
			sum = addVectors(sum, multiplyVectorByScalar(vector, repulsion - a))
		end
		
		oldGradient = gradient
		oldDirection = otherObjectPositions
		return addVectors(objectPosition, sum)
	end
	
	return {
		move = move
	}
end

-- this function acts as a constructor for the PID controller object
--parameters
--	p - constant for the proportional component
--	i - constant for the integral component
--	d - constant for the derivative component
-- returns a table / object reference containing the function adjust
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


-- returns a target position front, back, left or right by random relative to the finken
-- parameters
--	objectPosition - the finken's position
function getRandomDirection(objectPosition)
	local randomDirections = { {objectPosition[1] - 2, objectPosition[2], objectPosition[3]},
							   {objectPosition[1] + 2, objectPosition[2], objectPosition[3]},
							   {objectPosition[1], objectPosition[2] - 2, objectPosition[3]},
							   {objectPosition[1], objectPosition[2] + 2, objectPosition[3]}}
	
	local index = math.random(4)
	return randomDirections[index]
end

-- returns the euclidean distance to the power of power
--parameters
--	position1 - first position
--	position2 - second position
--	power - exponent, e.g. with 2 the result equals the scalar product 
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

-- elementwise vector addition
function addVectors(vector1, vector2)
	return {
		vector1[1] + vector2[1], 
		vector1[2] + vector2[2], 
		vector1[3] + vector2[3]
	}
end

-- elementwise vector substraction
function substractVectors(vector1, vector2)
	return {
		vector1[1] - vector2[1], 
		vector1[2] - vector2[2], 
		vector1[3] - vector2[3]
	}
end

-- scalar multiplication
function multiplyVectorByScalar(vector, scalar)
	return {
		vector[1] * scalar,
		vector[2] * scalar,
		vector[3] * scalar
	}
end

-- scalar product
function scalarProduct(vector1, vector2)
	return vector1[1] * vector2[1] 
		+ vector1[2] * vector2[2] 
		+ vector1[3] * vector2[3]
end