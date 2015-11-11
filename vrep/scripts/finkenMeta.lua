
--[[
--create a new finken by copying an old one to a new position
--@return table object_handle
--]]
function copyFinken(sourceFinken, positionTarget)
	local sourceFinkenSuffix, _ = simGetNameSuffix(sourceFinken)
	local nameSuffix = simGetNameSuffix(nil)
	simSetNameSuffix(sourceFinkenSuffix)
	local handle_SourceFinkenTarget=simGetObjectHandle('SimFinken_target')
	simSetNameSuffix(nameSuffix)
	local handles_TargetFinkenTarget = simCopyPasteObjects({handle_SourceFinkenTarget},0)
	simSetObjectPosition(handles_TargetFinkenTarget[1], -1, positionTarget)
	local handles_TargetFinken= simCopyPasteObjects({sourceFinken},1)
	simSetObjectPosition(handles_TargetFinken[1], -1, positionTarget)

	
	return {handles_TargetFinkenTarget[1], handles_TargetFinken[1]} 
end
