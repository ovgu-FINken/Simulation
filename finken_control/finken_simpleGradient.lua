local finken = {}

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end


	function self.customInit()
		helperSay("Hello World! Tschiep!")

	end


	function self.customRun()
		local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))
		-- simAddStatusbarMessage(colors[1]..' '..colors[2]..' '..colors[3]..' '..colors[4])
		speedFactor = 3
		xGrad = (colors[3] - 0.5) * speedFactor
		-- multiply with -1 because image coordinates start in top right
		yGrad = ((colors[4] - 0.5) * -1) * speedFactor
		--simAddStatusbarMessage(xGrad..' '..yGrad)
		currentTargetPosition = simGetObjectPosition(targetObj, -1)	
		currentFinkenPosition = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)
		xTarget = currentFinkenPosition[1] + xGrad
		yTarget = currentFinkenPosition[2] + yGrad
		simSetObjectPosition(targetObj, -1, {xTarget, yTarget, currentTargetPosition[3]})


		--targetObject is retrieved in the simulation script. 
		--remove if control via pitch/roll/yaw is wanted
		self.setTarget(targetObj)
	end

	function self.customSense()

	end

	function self.customClean()

	end

	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
