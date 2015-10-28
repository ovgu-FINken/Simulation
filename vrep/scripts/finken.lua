local finken = {}

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

	function self.getArenaPosition()
		local handle_myReference = simGetObjectHandle("Master#")
		local handle_mySelf = self.getHandle()
		local myPosition = simGetObjectPosition(handle_mySelf, handle_myReference) 
		return myPosition
	end

	function self.helloWorld()
		helperSay("Hello World. Tschieep!")
	end

	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
