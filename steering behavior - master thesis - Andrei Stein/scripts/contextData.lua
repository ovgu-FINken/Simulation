local contextData = {}

function contextData.new()
	-- current position of the finken as a vecotor {x,y,z}
	contextData.currentPosition = {}
	
	-- a list of target positions as key, value pair ('goal1' = {4,2,2})
	contextData.targets = {}
	
	-- the distances given by the senosors in this order:
	-- 1=front, 2=left, 3=back, 4=right, 5=front_left, 6=font_right, 7=back_left, 8=back_right
	contextData.sensorDistances = {}
	return contextData
end

return contextData