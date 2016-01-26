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
        targetEpsilon = 0.05
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

        speedFactor = 0.2
        -- calculate actual gradient from encoded information, so that we can compare with our estimates
        xGrad_true = (colors[3] - 0.5) * speedFactor
        --     --multiply with -1 because image coordinates start in top left
        yGrad_true = ((colors[4] - 0.5) * -1) * speedFactor

        if targetReached then
            neighborMat, neighborArr = myMap:getEightNeighbors()
            gradientCalc, mapValues = canCalculateGradient(neighborArr)
            if gradientCalc ~= -1 then
                xGrad, yGrad = calculateGradient(gradientCalc, mapValues, neighborMat[2][2])
                if xGrad ~= 0 or yGrad ~= 0 then
                    gradientLength = math.sqrt(xGrad*xGrad + yGrad*yGrad)
                    xGrad = xGrad/gradientLength * speedFactor
                    yGrad = yGrad/gradientLength * speedFactor
                    xTarget = currentFinkenPosition[1] + xGrad
                    yTarget = currentFinkenPosition[2] + yGrad
                    self.setTargetToPosition(xTarget, yTarget)
                    targetReached = false
                    esti_ang = math.acos(xGrad/speedFactor) *180 /math.pi
                    true_ang = math.acos(xGrad_true/math.sqrt(xGrad_true*xGrad_true + yGrad_true*yGrad_true))/math.pi *180
                    -- simAddStatusbarMessage('length:'..gradientLength..' x '..xGrad)
                    simAddStatusbarMessage('estimate: '..esti_ang)
                    simAddStatusbarMessage('actual: '..true_ang )
                end
            else
                -- self.setTargetToPosition(currentFinkenPosition[1] + math.random()*0.1, currentFinkenPosition[2] + math.random()*0.1)
                orthoPresent = getFilledDirection(neighborArr)
                -- go in clockwise orthogonal because why not
                speedFactor2 = 2
                if orthoPresent == 2 then
                    self.setTargetToPosition(currentFinkenPosition[1]+sizeOfField/100*speedFactor2, currentFinkenPosition[2])
                elseif orthoPresent == 4 then
                    self.setTargetToPosition(currentFinkenPosition[1], currentFinkenPosition[2]+sizeOfField/100*speedFactor2)
                elseif orthoPresent == 6 then
                    self.setTargetToPosition(currentFinkenPosition[1]-sizeOfField/100*speedFactor2, currentFinkenPosition[2])
                else
                    self.setTargetToPosition(currentFinkenPosition[1], currentFinkenPosition[2]-sizeOfField/100*speedFactor2)
                end
            end
        else
            self.setTarget(targetObj)
            currentTargetPosition = simGetObjectPosition(targetObj, -1)
            -- manhattan distance to target
            distToTarget = math.abs(currentTargetPosition[1]-currentFinkenPosition[1]) + math.abs(currentTargetPosition[2]-currentFinkenPosition[2])
            if distToTarget < targetEpsilon then
                targetReached = true
                -- simAddStatusbarMessage('target reached')
            end
        end
        -- self.setTargetToPosition(0, 1)
        myMap:updateMap(xSpeed, ySpeed, colors[2], true, 0.01, true)
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

-- there are 12 potential ways to calculate the gradient
-- the returned number indicates, that the three values as indicated are available:
-- O -->---1   2--->-- O 
-- |       |   |       |
-- |       |   |       |
-- |       |   |       |
-- 8---<--       ---<--3
--           C
-- 7--->--       --->--4
-- |       |   |       |
-- |       |   |       |
-- |       |   |       |
-- O --<---6   5---<-- O

-- O                   O 
--         |   |       
--         |   |       
--         |   |       
--  --->--12   9--->--
--           C
--  ---<--11   10--<---
--         |   |       
--         |   |       
--         |   |       
-- O                   O
function canCalculateGradient( arr )
    -- prefer the ones where we actually calculate the gradient at the current position
    for i = 9,12 do
        if arr[(i-8)*2] ~= nil and arr[((i-8)*2)%8+2] ~= nil then
            return i, {arr[(i-8)*2], arr[((i-8)*2)%8+2]}
        end
    end
    for i = 1,8 do
        if arr[i] ~= nil and arr[(i%8)+1] ~= nil then
            return i, {arr[i], arr[(i%8)+1]}
        end
    end
    return -1
end

function calculateGradient( version, mapValues, centerValue)
    local xGrad = 0
    local yGrad = 0
    
    
    if version == 1 then
        xGrad = mapValues[2] - mapValues[1]
        yGrad = centerValue - mapValues[2]
    elseif version == 2 then
        xGrad = mapValues[1] - mapValues[2]
        yGrad = centerValue - mapValues[1]
    elseif version == 5 then
        xGrad = mapValues[1] - mapValues[2]
        yGrad = mapValues[2] - centerValue
    elseif version == 6 then
        xGrad = mapValues[2] - mapValues[1]
        yGrad = mapValues[2] - centerValue
    elseif version == 3 then
        xGrad = mapValues[2] - centerValue
        yGrad = mapValues[2] - mapValues[1]
    elseif version == 4 then
        xGrad = mapValues[1] - centerValue
        yGrad = mapValues[2] - mapValues[1]
    elseif version == 7 then
        xGrad = centerValue - mapValues[2]
        yGrad = mapValues[1] - mapValues[2]
    elseif version == 8 then
        xGrad = centerValue - mapValues[1]
        yGrad = mapValues[1] - mapValues[2]
    elseif version == 9 then
        xGrad = mapValues[2] - centerValue
        yGrad = centerValue - mapValues[1]
    elseif version == 10 then
        xGrad = mapValues[1] - centerValue
        yGrad = mapValues[2] - centerValue
    elseif version == 11 then
        xGrad = centerValue - mapValues[2]
        yGrad = mapValues[1] - centerValue
    else
        xGrad = centerValue - mapValues[1]
        yGrad = centerValue - mapValues[2]
    end

    return xGrad, yGrad
end



function getFilledDirection( arr )
    for i = 2,8,2 do
        if arr[i] ~= nil then
            return i
        end
    end
    return 2
end

return finken
