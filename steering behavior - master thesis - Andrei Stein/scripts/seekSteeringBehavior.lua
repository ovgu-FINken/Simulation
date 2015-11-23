require('vectorMath')

local seekSteeringBehavior = {}

steeringBehaviorCore = require('steeringBehaviorCore')

function seekSteeringBehavior.init(self)
	
	function self.getSteering(contextData)
		local steering = {0,0,0}
		-- get steering from all bahaviors and combine them
		for k, target in pairs(contextData.targets) do
			steering = subtractVectors(target, contextData.currentPosition)
		end
		return steering
	end
	
	return self
end

function seekSteeringBehavior.new()
	return seekSteeringBehavior.init(steeringBehaviorCore)
end

return seekSteeringBehavior