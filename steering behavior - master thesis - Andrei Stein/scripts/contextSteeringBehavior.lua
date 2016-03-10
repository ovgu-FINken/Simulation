require('vectorMath')

local contextSteeringBehavior = {}

steeringBehaviorCore = require('steeringBehaviorCore')

local COS_45 = 0.707--0,70710678
local MAX_TARGET_DISTANCE = 7.5
local MAX_DANGER = 0.5--0.2
local MIN_SAME_DIRECTION = 0.2--0.4
local MIN_ATTRACTION = 0.2

function contextSteeringBehavior.init(self)
	
	-- reset context-ui at startup
	-- local ui_handle2 = simGetUIHandle('UI_Context_Maps')
	-- simSetUISlider(ui_handle2, 41, MAX_DANGER*1000)
	-- simSetUIButtonLabel(ui_handle2, 43, MAX_DANGER)
	-- simSetUISlider(ui_handle2, 42, MIN_SAME_DIRECTION*1000)
	-- simSetUIButtonLabel(ui_handle2, 44, MIN_SAME_DIRECTION)
	
	function self.getSteering(contextData)
		local steering = nil
		local interestMap = {0,0,0,0,0,0,0,0}
		local dangerMap = {0,0,0,0,0,0,0,0}
		local sameDirectionMap = {1,1,1,1,1,1,1,1}
		local attractionMap = {0,0,0,0,0,0,0,0}
		
		--local ui_handle = simGetUIHandle('UI_Context_Maps')
		
		-- calculate danger values for each direction
		for i=1,8,1 do
			local danger = 1 - contextData.sensorDistances[i]/7.5
			dangerMap[i] = danger 
			--simSetUIButtonColor(ui_handle, 14+i, {1-danger, 1-danger, 1-danger})
		end
		
		-- calculate interest values for each direction
		for k, target in pairs(contextData.targets) do
			local vectorToTarget = TransformToLokalSystem(contextData.objectHandle, target)
			local lenght = getEuclideanNorm(vectorToTarget)
			if(lenght < 0.6) then
				-- if(k == 'goal1') then
					-- if(contextData.targets['goal1']) then
						-- contextData.targets['goal1'] = nil
					-- end
					-- local target_handle = simGetObjectHandle('Sphere')
					-- simSetModelProperty(target_handle, sim_modelproperty_not_visible)
				-- end
				-- if(k == 'goal2') then
					-- if(contextData.targets['goal2']) then
						-- contextData.targets['goal2'] = nil
					-- end
					-- local target_handle = simGetObjectHandle('Sphere0')
					-- simSetModelProperty(target_handle, sim_modelproperty_not_visible)
				-- end
				-- if(k == 'goal3') then
					-- if(contextData.targets['goal3']) then
						-- contextData.targets['goal3'] = nil
					-- end
					-- local target_handle = simGetObjectHandle('Sphere1')
					-- simSetModelProperty(target_handle, sim_modelproperty_not_visible)
				-- end
			end
			
			vectorToTarget = truncateVector(vectorToTarget, MAX_TARGET_DISTANCE)
			
			local direction = {0,0,0}
			local angleCos = 0
			
			-- simAddStatusbarMessage(string.format('target x: %.2f	     y: %.2f	z: %.2f',
											-- target[1], target[2], target[3]))
			
			for i=1,8,1 do
				if(i == 1) then -- front
					direction = {0, -1, 0} --direction = {-1, 0, 0}
					--simAddStatusbarMessage('d1')
				elseif(i == 2) then -- left
					direction = {0, 0, -1} --direction = {0, -1, 0}
				elseif(i == 3) then -- back
					direction = {0, 1, 0} --direction = {1, 0, 0}
				elseif(i == 4) then -- right
					direction = {0, 0, 1} --direction = {0, 1, 0}
				elseif(i == 5) then -- front_left
					 direction = {0, -1, -1} --direction = {-1, -1, 0}
				elseif(i == 6) then -- front_right
					direction = {0, -1, 1} --direction = {-1, 1, 0}
				elseif(i == 7) then -- back_left
					direction = {0, 1, -1} --direction = {1, -1, 0}
				elseif(i == 8) then -- back_right
					direction = {0, 1, 1} --direction = {1, 1, 0}
				end
				
				-- simAddStatusbarMessage(string.format('direction x: %.2f	     y: %.2f	z: %.2f',
											-- direction[1], direction[2], direction[3]))
											
				-- simAddStatusbarMessage(string.format('vector to target x: %.2f	     y: %.2f	z: %.2f',
											-- vectorToTarget[1], vectorToTarget[2], vectorToTarget[3]))
				
				angleCos = getCosBetweenVectors(vectorToTarget, direction)
				--if angleCos > 0 then -- vectors are pointing in same direction
					-- map the cos value in the range of [0 - 1] and write it into the interestMap
					angleCos = ((angleCos + 1) / 2)*(1-(lenght/35))-- delete this *(1-(lenght/35)) if no nearest target should be supplied
					if angleCos > interestMap[i] then
						interestMap[i] = angleCos
						--simSetUIButtonColor(ui_handle, 6+i, {angleCos, angleCos, angleCos})
					end
				--end
				-- simAddStatusbarMessage(string.format('cos:   %.2f',angleCos))
			end
		end
		
		-- create sameDirectionMap values
		if not(isZeroVector(contextData.lastDirection)) then
			local lastDirectionTransfomed = TransformToLokalSystem(contextData.objectHandle, 
				addVectors(contextData.lastDirection, contextData.currentPosition))
			local direction = {0,0,0}
			local angleCos = 0
			
			for i=1,8,1 do
				
				-- for more accurate direction you have to transform the direction into
				if(i == 1) then -- front
					direction = {0, -1, 0} --direction = {-1, 0, 0}
				elseif(i == 2) then -- left
					direction = {0, 0, -1} --direction = {0, -1, 0}
				elseif(i == 3) then -- back
					direction = {0, 1, 0} --direction = {1, 0, 0}
				elseif(i == 4) then -- right
					direction = {0, 0, 1} --direction = {0, 1, 0}
				elseif(i == 5) then -- front_left
					 direction = {0, -1, -1} --direction = {-1, -1, 0}
				elseif(i == 6) then -- front_right
					direction = {0, -1, 1} --direction = {-1, 1, 0}
				elseif(i == 7) then -- back_left
					direction = {0, 1, -1} --direction = {1, -1, 0}
				elseif(i == 8) then -- back_right
					direction = {0, 1, 1} --direction = {1, 1, 0}
				end
				
				--simAddStatusbarMessage(string.format('direction x: %.2f	     y: %.2f	z: %.2f',
											--contextData.lastDirection[1], contextData.lastDirection[2], contextData.lastDirection[3]))
											
				-- simAddStatusbarMessage(string.format('vector to target x: %.2f	     y: %.2f	z: %.2f',
											-- vectorToTarget[1], vectorToTarget[2], vectorToTarget[3]))
				
				angleCos = getCosBetweenVectors(lastDirectionTransfomed, direction)
				sameDirectionMap[i] = angleCos
				--simSetUIButtonColor(ui_handle, 22+i, {angleCos, angleCos, angleCos})
				-- simAddStatusbarMessage(string.format('cos:   %.2f',angleCos))
			end
		end
		
		-- create attractionMap values
		local areCoptersNearby = false
		for i=1,8,1 do
			if(contextData.copters[i] == true) then
				areCoptersNearby = true
				if(i == 1) then -- front
					attractionMap[1] = 1
					if(attractionMap[2] < 0.5) then attractionMap[2] = 0.5 end
					if(attractionMap[4] < 0.5) then attractionMap[4] = 0.5 end
					if(attractionMap[5] < 0.75) then attractionMap[5] = 0.75 end
					if(attractionMap[6] < 0.75) then attractionMap[6] = 0.75 end
					if(attractionMap[7] < 0.25) then attractionMap[7] = 0.25 end
					if(attractionMap[8] < 0.25) then attractionMap[8] = 0.25 end
				elseif(i == 2) then -- left
					if(attractionMap[1] < 0.5) then attractionMap[1] = 0.5 end
					attractionMap[2] = 1
					if(attractionMap[3] < 0.5) then attractionMap[3] = 0.5 end
					if(attractionMap[5] < 0.75) then attractionMap[5] = 0.75 end
					if(attractionMap[6] < 0.25) then attractionMap[6] = 0.25 end
					if(attractionMap[7] < 0.75) then attractionMap[7] = 0.75 end
					if(attractionMap[8] < 0.25) then attractionMap[8] = 0.25 end
				elseif(i == 3) then -- back
					if(attractionMap[2] < 0.5) then attractionMap[2] = 0.5 end
					attractionMap[3] = 1
					if(attractionMap[4] < 0.5) then attractionMap[3] = 0.5 end
					if(attractionMap[5] < 0.25) then attractionMap[5] = 0.25 end
					if(attractionMap[6] < 0.25) then attractionMap[6] = 0.25 end
					if(attractionMap[7] < 0.75) then attractionMap[7] = 0.75 end
					if(attractionMap[8] < 0.75) then attractionMap[8] = 0.75 end
				elseif(i == 4) then -- right
					if(attractionMap[1] < 0.5) then attractionMap[1] = 0.5 end
					if(attractionMap[3] < 0.5) then attractionMap[3] = 0.5 end
					attractionMap[4] = 1
					if(attractionMap[5] < 0.25) then attractionMap[5] = 0.25 end
					if(attractionMap[6] < 0.75) then attractionMap[6] = 0.75 end
					if(attractionMap[7] < 0.25) then attractionMap[7] = 0.25 end
					if(attractionMap[8] < 0.75) then attractionMap[8] = 0.75 end
				elseif(i == 5) then -- front_left
					if(attractionMap[1] < 0.75) then attractionMap[1] = 0.75 end
					if(attractionMap[2] < 0.75) then attractionMap[2] = 0.75 end
					if(attractionMap[3] < 0.25) then attractionMap[3] = 0.25 end
					if(attractionMap[4] < 0.25) then attractionMap[4] = 0.25 end
					attractionMap[5] = 1
					if(attractionMap[6] < 0.5) then attractionMap[6] = 0.5 end
					if(attractionMap[7] < 0.5) then attractionMap[7] = 0.5 end
				elseif(i == 6) then -- front_right
					if(attractionMap[1] < 0.75) then attractionMap[1] = 0.75 end
					if(attractionMap[2] < 0.25) then attractionMap[2] = 0.25 end
					if(attractionMap[3] < 0.25) then attractionMap[3] = 0.25 end
					if(attractionMap[4] < 0.75) then attractionMap[4] = 0.75 end
					if(attractionMap[5] < 0.5) then attractionMap[5] = 0.5 end
					attractionMap[6] = 1
					if(attractionMap[8] < 0.5) then attractionMap[8] = 0.5 end
				elseif(i == 7) then -- back_left
					if(attractionMap[1] < 0.25) then attractionMap[1] = 0.25 end
					if(attractionMap[2] < 0.75) then attractionMap[2] = 0.75 end
					if(attractionMap[3] < 0.75) then attractionMap[3] = 0.75 end
					if(attractionMap[4] < 0.25) then attractionMap[4] = 0.25 end
					if(attractionMap[5] < 0.5) then attractionMap[5] = 0.5 end
					attractionMap[7] = 1
					if(attractionMap[8] < 0.5) then attractionMap[8] = 0.5 end
				elseif(i == 8) then -- back_right
					if(attractionMap[1] < 0.25) then attractionMap[1] = 0.25 end
					if(attractionMap[2] < 0.25) then attractionMap[2] = 0.25 end
					if(attractionMap[3] < 0.75) then attractionMap[3] = 0.75 end
					if(attractionMap[4] < 0.75) then attractionMap[4] = 0.75 end
					if(attractionMap[6] < 0.5) then attractionMap[6] = 0.5 end
					if(attractionMap[7] < 0.5) then attractionMap[7] = 0.5 end
					attractionMap[8] = 1
				end
			end
		end
		
		-- choose a direction with high interest an smal danger values
		-- sort interest values in decreasing order
		local sortedKeys = getKeysSortedByValue(interestMap, function(a, b) return a > b end)
		
		-- clear context UI-Chosen_Direction
		-- for i=1,8,1 do
			-- simSetUIButtonColor(ui_handle, 30+i, {1, 1, 1})
		-- end
		
		for _, key in ipairs(sortedKeys) do
			-- set the right steering direction
			if steering == nil then
				if dangerMap[key] <= MAX_DANGER and 
				   sameDirectionMap[key] >= MIN_SAME_DIRECTION and
				   (attractionMap[key] >= MIN_ATTRACTION or areCoptersNearby == false) then
					--simAddStatusbarMessage('I: '..interestMap[key]..'    A: '..attractionMap[key]..'   D: '..dangerMap[key]..'
					if(key == 1) then -- front
						steering = {0, -1, 0} --steering = {-1, 0, 0}
						--simAddStatusbarMessage('d1')
						--simSetUIButtonColor(ui_handle, 31, {0, 0.75, 0})
					elseif(key == 2) then -- left
						steering = {0, 0, -1} --steering = {0, -1, 0}
						--simAddStatusbarMessage('d2')
						--simSetUIButtonColor(ui_handle, 32, {0, 0.75, 0})
					elseif(key == 3) then -- back
						steering = {0, 1, 0} --steering = {1, 0, 0}
						--simAddStatusbarMessage('d3')
						--simSetUIButtonColor(ui_handle, 33, {0, 0.75, 0})
					elseif(key == 4) then -- right
						steering = {0, 0, 1} --steering = {0, 1, 0}
						--simAddStatusbarMessage('d4')
						--simSetUIButtonColor(ui_handle, 34, {0, 0.75, 0})
					elseif(key == 5) then -- front_left
						steering = {0, -COS_45, -COS_45} --steering = {-COS_45, -COS_45, 0}
						--simAddStatusbarMessage('d5')
						--simSetUIButtonColor(ui_handle, 35, {0, 0.75, 0})
					elseif(key == 6) then -- front_right
						steering = {0, -COS_45, COS_45} --steering = {-COS_45, COS_45, 0}
						--simAddStatusbarMessage('d6')
						--simSetUIButtonColor(ui_handle, 36, {0, 0.75, 0})
					elseif(key == 7) then -- back_left
						steering = {0, COS_45, -COS_45} --steering = {COS_45, -COS_45, 0}
						--simAddStatusbarMessage('d7')
						--simSetUIButtonColor(ui_handle, 37, {0, 0.75, 0})
					elseif(key == 8) then -- back_right
						steering = {0, COS_45, COS_45} --steering = {COS_45, COS_45, 0}
						--simAddStatusbarMessage('d8')
						--simSetUIButtonColor(ui_handle, 38, {0, 0.75, 0})
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
											
		-- simAddStatusbarMessage(string.format('dangerMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											-- dangerMap[1],
											-- dangerMap[2],
											-- dangerMap[3],
											-- dangerMap[4],
											-- dangerMap[5],
											-- dangerMap[6],
											-- dangerMap[7],
											-- dangerMap[8]))
											
		-- simAddStatusbarMessage(string.format('interestMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											-- interestMap[1],
											-- interestMap[2],
											-- interestMap[3],
											-- interestMap[4],
											-- interestMap[5],
											-- interestMap[6],
											-- interestMap[7],
											-- interestMap[8]))
											
											
		-- simAddStatusbarMessage(string.format('sameDirectionMap 	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f	%.2f',
											-- sameDirectionMap[1],
											-- sameDirectionMap[2],
											-- sameDirectionMap[3],
											-- sameDirectionMap[4],
											-- sameDirectionMap[5],
											-- sameDirectionMap[6],
											-- sameDirectionMap[7],
											-- sameDirectionMap[8]))
				
		steering = steering or {0,0,0}
		 -- simAddStatusbarMessage(string.format('steering x: %.2f	     y: %.2f	z: %.2f',
											 -- steering[1], steering[2], steering[3]))
		steering = TransformToWorldSystem(contextData.objectHandle, steering)
		
		-- update character values
		--self.updateCharacter()
		
		return subtractVectors(steering, contextData.currentPosition)--steering
	end
	
	-- chages the character properties with the ui-sliders
	function self.updateCharacter()
		local ui_handle = simGetUIHandle('UI_Context_Maps')
		MAX_DANGER = simGetUISlider(ui_handle, 41)/1000
		simSetUIButtonLabel(ui_handle, 43, MAX_DANGER)
		MIN_SAME_DIRECTION = simGetUISlider(ui_handle, 42)/1000
		simSetUIButtonLabel(ui_handle, 44, MIN_SAME_DIRECTION)
	end
	
	return self
end

function contextSteeringBehavior.new()
	local coreBehavior = steeringBehaviorCore.new()
	return contextSteeringBehavior.init(coreBehavior)
end

return contextSteeringBehavior