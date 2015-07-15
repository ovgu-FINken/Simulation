
function GetSSE(a, b, c)
	-- Get all object handles
	local SSE_FinkenList = {}
	local SSE_SensorList = {}
	local index = -1
	repeat
		local finkenHandle
		local front
		local back
		local left
		local right
		if index == -1 then
			finkenHandle = simGetObjectHandle('SimFinken#')
			front = simGetObjectHandle("SimFinken_sensor_front#")
			back = simGetObjectHandle("SimFinken_sensor_back#")
			left = simGetObjectHandle("SimFinken_sensor_left#")
			right = simGetObjectHandle("SimFinken_sensor_right#")
		else
			finkenHandle = simGetObjectHandle("SimFinken#" .. index)
			front = simGetObjectHandle("SimFinken_sensor_front#" .. index)
			back = simGetObjectHandle("SimFinken_sensor_back#" .. index)
			left = simGetObjectHandle("SimFinken_sensor_left#" .. index)
			right = simGetObjectHandle("SimFinken_sensor_right#" .. index)
		end
		
		if finkenHandle ~= -1 then
			table.insert(SSE_FinkenList, finkenHandle)
			table.insert(SSE_SensorList, front)
			table.insert(SSE_SensorList, back)
			table.insert(SSE_SensorList, left)
			table.insert(SSE_SensorList, right)
		end
		index = index + 1
    until finkenHandle == -1 

	-- Calculate the SSE
	local SSE = 0
	local n = 0
	
	delta = math.sqrt(c * math.log(b/a))

	-- Calculate the sum of the squared error for each sensor
	for _, sensor in ipairs(SSE_SensorList) do
		local _, senorDistance = simReadProximitySensor(sensor)
		if (senorDistance) then
			SSE = SSE + (senorDistance - delta)*(senorDistance - delta)
			n = n + 1
		end
	end

	local MSE = SSE / n
	
	simAddStatusbarMessage(" Delta: " .. delta)
	simAddStatusbarMessage(" SSE: " .. SSE)
	simAddStatusbarMessage(" MSE: " .. MSE)
	simAddStatusbarMessage("---------------------")

	return SSE
end