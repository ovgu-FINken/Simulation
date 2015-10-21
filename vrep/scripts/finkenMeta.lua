
--[[
--create a new finken by copying an old one to a new position
--@return object_handle
--]]
function copyFinken(sourceFinken, positionTarget)
	local handle_SourceFinkenTarget=simGetObjectHandle('SimFinken_target')
	local handle_TargetFinken = simCopyPasteObjects({sourceFinken,handle_SourceFinkenTarget},1)
	simSetObjectPosition(handle_TargetFinken[1], -1, positionTarget)
	simSetObjectPosition(handle_TargetFinken[2], -1, positionTarget)
	return handle_TargetFinken
end
