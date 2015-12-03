require('vectorMath')

local fleeSteeringBehavior = {}

steeringBehaviorCore = require('steeringBehaviorCore')

local COS_45 = 0.70710678
local maxFlee = 15

function fleeSteeringBehavior.init(self)
	
	function self.getSteering(contextData)
		local steering = {0,0,0}
		
		if(table.getn(contextData.sensorDistances) > 0) then
			-- process all distances from sensor data to flee from danger
			for k, distance in pairs(contextData.sensorDistances) do
				local fleeFactor = 1 - (distance / 7.5)
				local direction = {0,0,0}
				
				-- for more accurate direction you have to transform the direction into 
				-- the local system of the finken (!!!Not done yet!!!)
				if(k == 1) then -- front
					direction = {-distance, 0, 0}
				elseif(k == 2) then -- left
					direction = {0, -distance, 0}
				elseif(k == 3) then -- back
					direction = {distance, 0, 0}
				elseif(k == 4) then -- right
					direction = {0, distance, 0}
				elseif(k == 5) then -- front_left
					direction = {-COS_45*distance, -COS_45*distance, 0}
				elseif(k == 6) then -- front_right
					direction = {-COS_45*distance, COS_45*distance, 0}
				elseif(k == 7) then -- back_left
					direction = {COS_45*distance, -COS_45*distance, 0}
				elseif(k == 8) then -- back_right
					direction = {COS_45*distance, COS_45*distance, 0}
				end
				
				steering = addVectors(steering, multiplyVectorByScalar(direction, -fleeFactor*maxFlee))
			end
		end
		-- simAddStatusbarMessage('steering ' .. 
											-- steering[1]..' '..
											-- steering[2]..' '..
											-- steering[3])
											
		simAddStatusbarMessage(string.format('sensor 1: %.2f	     2: %.2f	3: %.2f	4: %.2f	5: %.2f	6: %.2f	7: %.2f	8: %.2f',  
											contextData.sensorDistances[1],
											contextData.sensorDistances[2],
											contextData.sensorDistances[3],
											contextData.sensorDistances[4],
											contextData.sensorDistances[5],
											contextData.sensorDistances[6],
											contextData.sensorDistances[7],
											contextData.sensorDistances[8]))
		return steering
	end
	
	return self
end

function fleeSteeringBehavior.new()
	local coreBehavior = steeringBehaviorCore.new()
	return fleeSteeringBehavior.init(coreBehavior)
end

return fleeSteeringBehavior