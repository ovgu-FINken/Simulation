local LocalMap = require('LocalMap')
local finken = {}

local boxContainer, sizeOfContainer, sizeOfField, targetReached, targetEpsilon, myMap

finkenCore = require('finkenCore')

function finken.init(self)

	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

    function self.initializeUI()
        -- Following is the handle of FINken2's associated UI (user interface):
        finkenLocalMapUI=simGetUIHandle("FinkenLocalMap")
        printLocalMapData=simGetUIHandle("PrintLocalMapData")
        -- Set the title of the user interface: 
        simSetUIButtonLabel(finkenLocalMapUI,0,"Finken Local map:")
        simSetUIButtonLabel(finkenLocalMapUI,3,"Size of Map (in CM):") 
        simSetUIButtonLabel(finkenLocalMapUI,4,"Size of Field (in CM):") 
        simSetUIButtonLabel(finkenLocalMapUI,7,"Update") 

        -- Retrieve the desired data from the user interface:
        sizeOfContainer = tonumber(simGetUIButtonLabel(finkenLocalMapUI,5))
        sizeOfField = tonumber(simGetUIButtonLabel(finkenLocalMapUI,6))
        
        --Setup all signals to be called from outside this scene
        simSetFloatSignal('_LM_SizeOfContainer',sizeOfContainer)
        simSetFloatSignal('_LM_SizeOfField',sizeOfField)
    end

	function self.customInit()
		helperSay("Follow the gradient estimated from the local map...")
        -- set some initializations
        self.initializeUI()
        self.CopterPositionSetToCenterOfMap()

        -- Update the local map data and then setup a map around finken
        self.UpdateLocalMapDataFromUI()
        --Create a VirtualBoxAround the Finken
        self.CreateAVirtualBoxAroundFinken()
        --Create a local map data table, initialise with {0,0}
        targetReached = true
        targetEpsilon = 0.25
        for k, v in pairs(LocalMap) do
            simAddStatusbarMessage(k)
        end
        myMap = LocalMap.new(sizeOfContainer, sizeOfField)
        for k, v in pairs(myMap) do
            simAddStatusbarMessage(k)
        end
    end

    -- Region # New methods for local map
    function self.CopterPositionSetToCenterOfMap()
        currentFinkenPosition = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)
        -- Set copter initial position in the center of map
        simSetObjectPosition(simGetObjectHandle('FINken2'), -1, {0,0,currentFinkenPosition[3]})
    end

    function self.setTargetToPosition( x, y )
        simSetObjectPosition(targetObj, -1, {x, y, 1})
        self.setTarget(targetObj)
    end

    function self.SetTargetPositionToCenterOfMap()
        --For testing of local map
        self.setTargetToPosition(0, 0)
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


    function self.CheckUIButton()
        --check if update button is pressed
        startBtnValue = simGetUIEventButton(printLocalMapData)
        boolValue = 3
        if(startBtnValue == boolValue) then
            myMap:printData()
        end
    end


	function self.customRun()
        self.CheckUIButton()
        -- Gradient images from matlab
        -- R: height
        -- G: x gradient (0.5 intensity corresponds to 0 gradient)
        -- B: y gradient
        -- the vision sensor Floor_camera returns a table of values
        -- the first element colors[1] is the overall lightness of the image
        -- the other elements colors[2] is Red, colors[3] is Green, colors[4] is Blue

		local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))
		--simAddStatusbarMessage(colors[1]..' '..colors[2]..' '..colors[3]..' '..colors[4])

        -- Setting the speed signals, so that the texture and arena can be moved
        oldFinkenPosition = currentFinkenPosition or {0, 0, 0}
        currentFinkenPosition = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)

        xSpeed = currentFinkenPosition[1] - oldFinkenPosition[1]
        ySpeed = currentFinkenPosition[2] - oldFinkenPosition[2]

        simSetFloatSignal('_xSpeed', -xSpeed*100)
        simSetFloatSignal('_ySpeed', -ySpeed*100)

        if colors==nil then 
            return
        end

        currentTargetPosition = simGetObjectPosition(targetObj, -1)
        if targetReached then -- and can calculate gradient
            -- calculate target from gradient information
            speedFactor = 1.5
            xGrad = (colors[3] - 0.5) * speedFactor
            --multiply with -1 because image coordinates start in top left
            yGrad = ((colors[4] - 0.5) * -1) * speedFactor

            --height is represented by Red which shows hills
            zGrad = ((colors[2] + 0.5)) * speedFactor

            xTarget = currentFinkenPosition[1] + xGrad
            yTarget = currentFinkenPosition[2] + yGrad
            zTarget =  zGrad

            --keeping the Z value same as current target position, for hill.png gradient
            simSetObjectPosition(targetObj, -1, {xTarget, yTarget,zTarget})

            self.setTarget(targetObj)
            targetReached = false
        -- else if cannot calculate gradient
        --     explore area
        else
            self.setTarget(targetObj)
            -- manhattan distance to target
            distToTarget = math.abs(currentTargetPosition[1]-currentFinkenPosition[1]) + math.abs(currentTargetPosition[2]-currentFinkenPosition[2])
            if distToTarget < targetEpsilon then
                targetReached = true
            end
        end
        -- self.setTargetToPosition(0, 1)
        myMap:updateMap(xSpeed, ySpeed, colors[2], true, 0.2, true)
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
