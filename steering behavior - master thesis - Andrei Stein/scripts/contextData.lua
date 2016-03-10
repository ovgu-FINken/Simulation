local contextData = {}

function contextData.new()
	-- object handle of a finken
	contextData.objectHandle = nil
		
	-- current position of the finken as a vecotor {x,y,z}
	contextData.currentPosition = {}
	
	-- a list of target positions as key, value pair ('goal1' = {4,2,2})
	contextData.targets = {}
	
	-- the distances given by the senosors in this order:
	-- 1=front, 2=left, 3=back, 4=right, 5=front_left, 6=font_right, 7=back_left, 8=back_right
	contextData.sensorDistances = {}
	
	-- detected copters nearby given by the senosors in this order:
	-- 1=front, 2=left, 3=back, 4=right, 5=front_left, 6=font_right, 7=back_left, 8=back_right
	contextData.copters = {}
	
	-- the last chosen direction. Vector3 {x,y,z}
	contextData.lastDirection = {0,0,0}
	
	return contextData
end

return contextData