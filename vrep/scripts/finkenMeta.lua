
--[[
--create a new finken by copying an old one to a new position
--@return object_handle
--]]
function copyFinken(sourceFinken, positionTarget)
	local sourceFinkenSuffix, _ = simGetNameSuffix(sourceFinken)
	local nameSuffix = simGetNameSuffix(nil)
	simSetNameSuffix(sourceFinkenSuffix)
	local handle_SourceFinkenTarget=simGetObjectHandle('SimFinken_target')
	simSetNameSuffix(nameSuffix)
	local handles_TargetFinkenTarget = simCopyPasteObjects({handle_SourceFinkenTarget},1)
	simSetObjectPosition(handles_TargetFinkenTarget[1], -1, positionTarget)

	return handles_TargetFinken
end
