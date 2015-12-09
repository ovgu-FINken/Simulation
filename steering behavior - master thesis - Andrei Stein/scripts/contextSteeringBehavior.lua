require('vectorMath')

local contextSteeringBehavior = {}

steeringBehaviorCore = require('steeringBehaviorCore')

local COS_45 = 0.707--0,70710678
local MAX_TARGET_DISTANCE = 7.5
local MAX_DANGER = 0.2
local MIN_SAME_DIRECTION = 0.4

function contextSteeringBehavior.init(self)
	
	function self.getSteering(contextData)
		local steering = nil
		local interestMap = {0,0,0,0,0,0,0,0}
		local dangerMap = {0,0,0,0,0,0,0,0}
		local sameDirectionMap = {1,1,1,1,1,1,1,1}
		
		
		-- calculate danger values for each direction
		for i=1,8,1 do
			local danger = 1 - contextData.sensorDistances[i]/7.5
			if danger > dangerMap[i] then dangerMap[i] = danger end
		end
		
		-- calculate interest values for each direction
		for k, target in pairs(contextData.targets) do
			local vectorToTarget = subtractVectors(target, contextData.currentPosition)
			vectorToTarget = truncateVector(vectorToTarget, MAX_TARGET_DISTANCE)
			
			local direction = {0,0,0}
			local angleCos = 0
			
			-- simAddStatusbarMessage(string.format('target x: %.2f	     y: %.2f	z: %.2f',
											-- target[1], target[2], target[3]))
			
			for i=1,8,1 do
				
				-- for more accurate direction you have to transform the direction into 
				-- the local system of the finken (!!!Not done yet!!!)
				if(i == 1) then -- front
					direction = {-1, 0, 0}
					--simAddStatusbarMessage('d1')
				elseif(i == 2) then -- left
					direction = {0, -1, 0}
				elseif(i == 3) then -- back
					direction = {1, 0, 0}
				elseif(i == 4) then -- right
					direction = {0, 1, 0}
				elseif(i == 5) then -- front_left
					direction = {-1, -1, 0}
				elseif(i == 6) then -- front_right
					direction = {-1, 1, 0}
				elseif(i == 7) then -- back_left
					direction = {1, -1, 0}
				elseif(i == 8) then -- back_right
					direction = {1, 1, 0}
				end
				
				-- simAddStatusbarMessage(string.format('direction x: %.2f	     y: %.2f	z: %.2f',
											-- direction[1], direction[2], direction[3]))
											
				-- simAddStatusbarMessage(string.format('vector to target x: %.2f	     y: %.2f	z: %.2f',
											-- vectorToTarget[1], vectorToTarget[2], vectorToTarget[3]))
				
				angleCos = getCosBetweenVectors(vectorToTarget, direction)
				--if angleCos > 0 then -- vectors are pointing in same direction
					-- map the cos value in the range of [0 - 1] and write it into the interestMap
					angleCos = (angleCos + 1) / 2
					if angleCos > interestMap[i] then interestMap[i] = angleCos end
				--end
				-- simAddStatusbarMessage(string.format('cos:   %.2f',angleCos))
			end
		end
		
		-- create sameDirectionMap values
		if not(isZeroVector(contextData.lastDirection)) then
		
			local direction = {0,0,0}
			local angleCos = 0
			
			for i=1,8,1 do
				
				-- for more accurate direction you have to transform the direction into 
				-- the local system of the finken (!!!Not done yet!!!)
				if(i == 1) then -- front
					direction = {-1, 0, 0}
				elseif(i == 2) then -- left
					direction = {0, -1, 0}
				elseif(i == 3) then -- back
					direction = {1, 0, 0}
				elseif(i == 4) then -- right
					direction = {0, 1, 0}
				elseif(i == 5) then -- front_left
					direction = {-1, -1, 0}
				elseif(i == 6) then -- front_right
					direction = {-1, 1, 0}
				elseif(i == 7) then -- back_left
					direction = {1, -1, 0}
				elseif(i == 8) then -- back_right
					direction = {1, 1, 0}
				end
				
				simAddStatusbarMessage(string.format('direction x: %.2f	     y: %.2f	z: %.2f',
											contextData.lastDirection[1], contextData.lastDirection[2], contextData.lastDirection[3]))
											
				-- simAddStatusbarMessage(string.format('vector to target x: %.2f	     y: %.2f	z: %.2f',
											-- vectorToTarget[1], vectorToTarget[2], vectorToTarget[3]))
				
				angleCos = getCosBetweenVectors(contextData.lastDirection, direction)
				sameDirectionMap[i] = angleCos 
				-- simAddStatusbarMessage(string.format('cos:   %.2f',angleCos))
			end
		end
		
		-- choose a direction with high interest an smal danger values
		-- sort interest values in decreasing order
		local sortedKeys = getKeysSortedByValue(interestMap, function(a, b) return a > b end)
		
		for _, key in ipairs(sortedKeys) do
			-- set the right steering direction
			if steering == nil then
				if dangerMap[key] <= MAX_DANGER and 
				   sameDirectionMap[key] >= MIN_SAME_DIRECTION then
					simAddStatusbarMessage('I: '..interestMap[key]..'   D: '..dangerMap[key]..'		S: '..sameDirectionMap[key])
					
					if(key == 1) then -- front
						steering = {-1, 0, 0}
						simAddStatusbarMessage('d1')
					elseif(key == 2) then -- left
						steering = {0, -1, 0}
						simAddStatusbarMessage('d2')
					elseif(key == 3) then -- back
						steering = {1, 0, 0}
						simAddStatusbarMessage('d3')
					elseif(key == 4) then -- right
						steering = {0, 1, 0}
						simAddStatusbarMessage('d4')
					elseif(key == 5) then -- front_left
						steering = {-COS_45, -COS_45, 0}
						simAddStatusbarMessage('d5')
					elseif(key == 6) then -- front_right
						steering = {-COS_45, COS_45, 0}
						simAddStatusbarMessage('d6')
					elseif(key == 7) then -- back_left
						steering = {COS_45, -COS_45, 0}
						simAddStatusbarMessage('d7')
					elseif(key == 8) then -- back_right
						steering = {COS_45, COS_45, 0}
						simAddStatusbarMessage('d8')
					end
				end
			end
		end
											
		-- simAddStatusbarMessage(string.format('sensor 1: %.2f	     2: %.2f	3: %.2f	4: %.2f	5: %.2f	6: %.2f	7: %.2f	8: %.2f',  
											-- contextData.sensorDistances[1],
											-- contextData.sensorDistances[2],
											-- contextData.sensorDistances[3],
											-- contextData.sensorDistances[4],
											-- contextData.sensorDistances[5],
											-- contextData.sensorDistances[6],
											-- contextData.sensorDistances[7],
											-- contextData.sensorDistances[8]))
											
		simAddStatusbarMessage(string.format('dangerMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											dangerMap[1],
											dangerMap[2],
											dangerMap[3],
											dangerMap[4],
											dangerMap[5],
											dangerMap[6],
											dangerMap[7],
											dangerMap[8]))
											
		simAddStatusbarMessage(string.format('interestMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											interestMap[1],
											interestMap[2],
											interestMap[3],
											interestMap[4],
											interestMap[5],
											interestMap[6],
											interestMap[7],
											interestMap[8]))
											
											
		simAddStatusbarMessage(string.format('sameDirectionMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											sameDirectionMap[1],
											sameDirectionMap[2],
											sameDirectionMap[3],
											sameDirectionMap[4],
											sameDirectionMap[5],
											sameDirectionMap[6],
											sameDirectionMap[7],
											sameDirectionMap[8]))
				
		steering = steering or {0,0,0}
		-- simAddStatusbarMessage(string.format('steering x: %.2f	     y: %.2f	z: %.2f',
											-- steering[1], steering[2], steering[3]))
		return steering
	end
	
	return self
end

function contextSteeringBehavior.new()
	local coreBehavior = steeringBehaviorCore.new()
	return contextSteeringBehavior.init(coreBehavior)
end

return contextSteeringBehavior