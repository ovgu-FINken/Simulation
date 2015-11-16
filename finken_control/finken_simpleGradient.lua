local finken = {}

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

	function self.customInit()
		helperSay("First task, Create gradient follower copter behavior ")

	end


	function self.customRun()

        -- Gradient images from matlab
        -- R: height
        -- G: x gradient (0.5 intensity corresponds to 0 gradient)
        -- B: y gradient

        -- the vision sensor Floor_camera returns a table of values
        -- the first element colors[1] is the overall lightness of the image
        -- the other elements colors[2] is Red, colors[3] is Green, colors[4] is Blue

		local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))
		--simAddStatusbarMessage(colors[1]..' '..colors[2]..' '..colors[3]..' '..colors[4])
		speedFactor = 1.5

            --For hill.png gradient
            -- passing colors[3] Green to xGrad.
            xGrad = (colors[3] - 0.5) * speedFactor

            -- passing colors[4] Blue to yGrad.
            --multiply with -1 because image coordinates start in top right
            yGrad = ((colors[4] - 0.5) * -1) * speedFactor

            --height is represented by Red which shows hills
            zGrad = ((colors[2] + 0.5)) * speedFactor

            currentTargetPosition = simGetObjectPosition(targetObj, -1)
            currentFinkenPosition = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)

            xTarget = currentFinkenPosition[1] + xGrad
            yTarget = currentFinkenPosition[2] + yGrad
            zTarget =  zGrad

            --keeping the Z value same as current target position, for hill.png gradient
            simSetObjectPosition(targetObj, -1, {xTarget, yTarget,zTarget})

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
