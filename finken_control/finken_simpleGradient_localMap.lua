local finken = {}

local boxContainer, sizeOfContainer,sizeOfField, resolutionOfMap,localMapDataTable = {n=1000}, row, col, xRes, yRes,midIndex, midIndexCol

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
        simSetObjectPosition(simGetObjectHandle('FINken2'), -1, {0,0,0.5})
    end

    function self.SetTargetPositionToCenterOfMap()
        --For testing of local map
        simSetObjectPosition(targetObj, -1, {0, 0, 0})
        self.setTarget(targetObj)
    end

    function self.CreateAVirtualBoxAroundFinken()
        dupTolerance =0.0
        parentObjectHandle = simGetObjectHandle('SimFinken_base')
        maxItemCount = 1

        boxContainer=simAddDrawingObject(sim_drawing_quadpoints+sim_drawing_itemsizes+sim_drawing_wireframe,sizeOfContainer,dupTolerance,parentObjectHandle,maxItemCount)

        finkenSize=simGetObjectSizeFactor(simGetObjectHandle('SimFinken_base'))
        finkenCurrentPos=simGetObjectPosition(simGetObjectHandle('SimFinken_base'),-1)

        --sim_drawing_quadpoints items are "rectangle points"
        --(6 values per item (x;y;z;Nx;Ny;Nz) (N=normal vector)) + auxiliary values)
        -- itemData = {position (x,y,z), normal(x,y,z), sizeOfContainer}
        -- sizeOfContainer (0.05 to 1.0) meters, but if user enters in centimeters (5,100) then sizeOfContainer/100
        itemData={finkenCurrentPos[1],finkenCurrentPos[2],finkenCurrentPos[3],0,0,1,sizeOfContainer/100}
        simAddDrawingObjectItem(boxContainer,itemData)
    end

    function self.UpdateLocalMapDataFromUI()
        sizeOfContainer =  simGetFloatSignal('_LM_SizeOfContainer')
        sizeOfField = simGetFloatSignal('_LM_SizeOfField')
        simAddStatusbarMessage('Map: '..sizeOfContainer..'  Field: '..sizeOfField)
    end


    function self.CalculateResolutionFromUserData()
        -- User specifies the size of container and field size (each block in cm's)
        -- Calculate how many fields can fit into the size of container, which will define the resolution of local map

        resolutionOfMap = (sizeOfContainer*sizeOfField) --resolution as array size, how many fields in an 2D array
        simAddStatusbarMessage('ResolutionMap:  '..resolutionOfMap)

        --to get array size
        xRes = resolutionOfMap
        yRes = resolutionOfMap

        simAddStatusbarMessage('SizeOfMap X: '..xRes..' Y: '..yRes)

        localMapDataTable = {n=yRes}
        row =1
        col =1
    end

    function self.CreateLocalMapDataTable()
        -- Calculating table index as : CurrentRow * MaxColumns + CurrentColumn

        -- Set the default value at midSize of array to be the current position of Finken
        -- Lets say, localMapDataTable[(xRes/2) * yRes + (yRes/2)] = {0,0}
        for r=1,xRes do
            for c=1,yRes do
                        localMapDataTable[r*yRes + c] = {0,0}
                    end
            end

        --Set center value of array to be, where copter is initially positioned, sample value {1,1}
        midIndexCol =(yRes/2)
        midIndex =((xRes/2) * yRes + midIndexCol)
        localMapDataTable[midIndex] = {1,1}
    end


    function self.PrintLocalMapDataTable()
        for r=1,xRes do
            for c=1,yRes do
                simAddStatusbarMessage('AtIndex: '..(r*yRes + c)..' X: '..localMapDataTable[r*yRes + c][1]..', Y:'..localMapDataTable[r*yRes + c][2])
            end
        end
    end

    function self.UpdateLocalMapWithColorSensorValue()

        local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))
        --colors[2] is Red, colors[3] is Green, colors[4] is Blue
        r = colors[2]
        g = colors[3]
        b = colors[4]

        colorValue = {g,b}

        --get xSpeed of map and shift index of localMap data accoridng to that.
        xSpeed= simGetFloatSignal('_xSpeed')

            if(xSpeed > 0) then
                
                 if(midIndex > (yRes)) then
                    --shift array index to +1 and save prev. value to the new Index
                    prevValue = {}
                    prevValue[1] = localMapDataTable[midIndex][1]
                    prevValue[2] = localMapDataTable[midIndex][2]
                    
                    localMapDataTable[midIndex]  = colorValue

                        if(midIndexCol > 0) then
                            midIndexCol = midIndexCol - 1
                            midIndex =((xRes/2) * yRes + midIndexCol)
                            localMapDataTable[midIndex] = prevValue
                        end
                 end
            end

            if(xSpeed < 0) then
                
                if(midIndex < ((xRes*yRes) + yRes)) then

                --shift array index to -1 and save prev. value to the new Index
                prevValue = {}
                prevValue[1] = localMapDataTable[midIndex][1]
                prevValue[2] = localMapDataTable[midIndex][2]
                
                localMapDataTable[midIndex]  = colorValue

                    if(midIndexCol < yRes) then
                        midIndexCol = midIndexCol + 1
                        midIndex =((xRes/2) * yRes + midIndexCol)
                        localMapDataTable[midIndex] = prevValue
                    end
                end
            end
    end --end of function

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
            xGrad = (colors[3] - 0.5) * speedFactor

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
