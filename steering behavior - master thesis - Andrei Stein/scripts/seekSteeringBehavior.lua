require('vectorMath')

local seekSteeringBehavior = {}

steeringBehaviorCore = require('steeringBehaviorCore')

local MAX_SEEK = 7.5 

function seekSteeringBehavior.init(self)
	
	function self.getSteering(contextData)
		local steering = {0,0,0}
		-- process all targets
		for k, target in pairs(contextData.targets) do
			local vectorToTarget = subtractVectors(target, contextData.currentPosition)
			steering = addVectors(steering, vectorToTarget)
		end
		
		steering = truncateVector(steering, MAX_SEEK)
		return steering
	end
	
	return self
end

function seekSteeringBehavior.new()
	local coreBehavior = steeringBehaviorCore.new()
	return seekSteeringBehavior.init(coreBehavior)
end

return seekSteeringBehavior