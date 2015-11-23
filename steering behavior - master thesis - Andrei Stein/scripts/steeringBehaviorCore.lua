local steeringBehaviorCore = {}

--[[
--getSteering() is called for each simulation step and returns the new force created by the steering
--behavior.
-- The contextData has the data about the current position, the list of targets, the sensor ditances.
-- For more info about contextData look into contextData.lua
--@return(steering force {x,y,z})
--]]
function steeringBehaviorCore.getSteering(contextData)

end

return steeringBehaviorCore