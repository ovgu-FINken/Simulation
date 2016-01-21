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

function subtractVectors(vector1, vector2)
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

function getNormalizedVector(vector)
	if not(isZeroVector(vector)) then
		local lenght = getEuclideanNorm(vector)
		local normalizedVecotr = multiplyVectorByScalar(vector, 1/lenght)
		return normalizedVecotr
	else 
		return {0,0,0}
	end
end

function truncateVector(vector, maxLenght)
	if not(isZeroVector(vector)) then
	
		local lenght = getEuclideanNorm(vector)
		if lenght > maxLenght then
				local normalizedVecotr = getNormalizedVector(vector)
				return multiplyVectorByScalar(normalizedVecotr, maxLenght)
		else
			return vector
		end
	else
		return {0,0,0}
	end
end

function getAngleInRad(vector1, vector2)
	local angle = scalarProduct(vector1,vector2) / (getEuclideanNorm(vector1)*getEuclideanNorm(vector2))
	angle = math.acos(angle)
	return angle
end

function getCosBetweenVectors(vector1, vector2)
	local angle = scalarProduct(vector1,vector2) / (getEuclideanNorm(vector1)*getEuclideanNorm(vector2))
	return angle
end

function isZeroVector(vector)
	return vector[1] == 0 and vector[2] == 0 and vector[3] == 0
end

-- this function sorts the key according to the values
function getKeysSortedByValue(tbl, sortFunction)
  
  -- use default sort order, if no specific order was passed by
  sortFunction = sortFunction or function(a, b) return a < b end
  
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)

  return keys
end

-- this function transforms a postion into the local system of an object
function TransformToLokalSystem(objectHandle, position)
	local finkenMatrix = simGetObjectMatrix(objectHandle, -1)
	local finkenMatrixInverse = simGetInvertedMatrix(finkenMatrix)
	local transformedPosition = simMultiplyVector(finkenMatrixInverse, position)
	--simAddStatusbarMessage('OutputX: ' .. tostring(transformedPosition[1]))
	--simAddStatusbarMessage('OutputY: ' .. tostring(transformedPosition[2]))
	--simAddStatusbarMessage('OutputZ: ' .. tostring(transformedPosition[3]))
	return transformedPosition
end

-- this function transforms a postion into the world system of an object
function TransformToWorldSystem(objectHandle, position)
	local finkenMatrix = simGetObjectMatrix(objectHandle, -1)
	local transformedPosition = simMultiplyVector(finkenMatrix, position)
	--simAddStatusbarMessage('OutputX: ' .. tostring(transformedPosition[1]))
	--simAddStatusbarMessage('OutputY: ' .. tostring(transformedPosition[2]))
	--simAddStatusbarMessage('OutputZ: ' .. tostring(transformedPosition[3]))
	return transformedPosition
end