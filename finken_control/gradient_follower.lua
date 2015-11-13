local finken = {}

finkenCore = require('finkenCore')


function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

	function self.helloWorld()
		helperSay("Hello World. Tschieep!")
	end

	function finken.sense()
		return self.sense()
	end

	function finken.step()
		simAddStatusbarMessage('test hello')
		targetHandle = simGetObjectHandle('SimFinken_target')
		finkenPosition = simGetObjectPosition(simGetObjectHandle('MyFinken'), -1)
		--simSetObjectPosition(targetHandle, -1, {1, 1, 1})
		--self.setTarget(targetHandle)
		--self.printControlValues()
		simAddStatusbarMessage(finkenPosition[3])
		return self.step()
	end

	return self
end

function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
