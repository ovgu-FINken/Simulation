local finken = {}

local boxContainer

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

	function self.customInit()
		helperSay("First task, Create gradient follower copter behavior ")
	end


    -- Region # New methods for local map

    function self.CopterPositionSetToCenterOfMap()
        -- Set copter initial position in the center of map
        simSetObjectPosition(simGetObjectHandle('SimFinken_base'), -1, {0,0,0})
    end

    function self.CreateAVirtualBoxAroundFinken()

        sizeOfContainer=1
        dupTolerance =0.0
        parentObjectHandle = simGetObjectHandle('SimFinken_base')
        maxItemCount = 1

        boxContainer=simAddDrawingObject(sim_drawing_cubepoints+sim_drawing_itemsizes+sim_drawing_wireframe,sizeOfContainer,dupTolerance,parentObjectHandle,maxItemCount)

        finkenSize=simGetObjectSizeFactor(simGetObjectHandle('SimFinken_base'))
        finkenCurrentPos=simGetObjectPosition(simGetObjectHandle('SimFinken_base'),-1)

    --sim_drawing_cubepoints items are "cube points" (6 values per item (x;y;z;Nx;Ny;Nz) (N=normal vector)) + auxiliary values)
        itemData={finkenCurrentPos[1],finkenCurrentPos[2],finkenCurrentPos[3],0,0,1,0.25*finkenSize}

        simAddDrawingObjectItem(boxContainer,itemData)
    end

    function self.UpdateLocalMapWithColorSensorValue()
        local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))

        --colors[2] is Red, colors[3] is Green, colors[4] is Blue
        xPos = (colors[3] - 0.5) * speedFactor
        yPos = ((colors[4] - 0.5) * -1) * speedFactor
        zPos = ((colors[2] + 0.5)) * speedFactor

        simSetObjectPosition(boxContainer,{xPos,yPos,zPos})

    end

    -- end of new methods region

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
