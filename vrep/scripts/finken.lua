local finken = {}

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end


	function customRun()
		--targetObject is retrieved in the simulation script. 
		--remove if control via pitch/roll/yaw is wanted
		self.setTarget(targetObj)

		helperSay("Hello World! Tschiep!")
	end

	function customSense()

	end

	function customClean()

	end

	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
