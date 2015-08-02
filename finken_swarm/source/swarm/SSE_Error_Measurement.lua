
-- List of all finken scripts of the scene
SSE_AllFinkens = {}

function GetSSE(a, b, c)
	-- Get all sensor data
	local SSE_DistanceList = {}
	for _, finkenScript in ipairs(SSE_AllFinkens) do
		-- Get the distances from the sensor of the finken
		local detectedDistances = finkenScript.getDetectedDistances()
		
		if detectedDistances.front then table.insert(SSE_DistanceList, detectedDistances.front) end
		if detectedDistances.back then table.insert(SSE_DistanceList, detectedDistances.back) end
		if detectedDistances.left then table.insert(SSE_DistanceList, detectedDistances.left) end
		if detectedDistances.right then table.insert(SSE_DistanceList, detectedDistances.right) end
	end
	
	-- Calculate the SSE
	local SSE = 0
	local n = 0
	
	delta = math.sqrt(c * math.log(b/a))

	-- Calculate the sum of the squared error for each sensor
	for _, sensorDistance in ipairs(SSE_DistanceList) do
			SSE = SSE + (sensorDistance - delta)*(sensorDistance - delta)
			n = n + 1
	end

	local MSE = SSE / n
	
	simAddStatusbarMessage(" Delta: " .. delta)
	simAddStatusbarMessage(" SSE: " .. SSE)
	simAddStatusbarMessage(" MSE: " .. MSE)
	simAddStatusbarMessage(table.getn(SSE_AllFinkens))
	simAddStatusbarMessage("---------------------")

	return SSE
end