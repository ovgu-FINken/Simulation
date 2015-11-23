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
	local lenght = getEuclideanNorm(vector)
	local normalizedVecotr = multiplyVectorByScalar(vector, 1/lenght)
	return normalizedVecotr
end