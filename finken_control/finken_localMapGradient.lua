local LocalMap = require('LocalMap')
local writingfile = require("writingfile")
local finken = {}

local boxContainer, sizeOfContainer, sizeOfField, currentMapHeight
local heightLog = {}
finkenCore = require('finkenCore')

function finken.init(self)
	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

    --save a timestamped log array to a file
    --currently only works for data arrays with 3 columns
    --@newSuffix and @newDirectoryPath are optional
    --fileExtension can be .txt .csv .log
    -- we need csv to plot graphs (data separated by commas)

    local function SaveLogDataToFile(logData, newLogName, mapName, newSuffix, newDirectoryPath, fileExtension)

        local headerOnce=false
        local myTimeString = os.date("%Y%m%d%H%M%S")
        simAddStatusbarMessage(newDirectoryPath)
        newDirectoryPath = newDirectoryPath..'../../logs/'
        newSuffix = newSuffix or ""
        local myLogFile = assert(io.open(newDirectoryPath..mapName.."_".. newSuffix.."_"..newLogName.."_"..myTimeString..fileExtension, "w"))

        if headerOnce==false then
            local lMapRes = simGetFloatSignal('_LM_SizeOfContainer')/simGetFloatSignal('_LM_SizeOfField')
            myLogFile:write("GradientMap:,",mapName,"\n")
            myLogFile:write("GradientMap Scale:,",simGetFloatSignal('_xScale'),"*",simGetFloatSignal('_yScale'),"\n")
            myLogFile:write("LMap TotalSize:,",simGetFloatSignal('_LM_SizeOfContainer'),"\n")
            myLogFile:write("LMap FieldSize:,",simGetFloatSignal('_LM_SizeOfField'),"\n")
            myLogFile:write("LMap Resolution:,",lMapRes,"*",lMapRes,"\n")

            myLogFile:write("Mode:,",simGetIntegerSignal('_mode') or 0,"\n") -- if 0 then straight line, if 1 then drunk, if 2 then random
            myLogFile:write("Gradient Speed:,",simGetFloatSignal('_gradientSpeed') or 0.3,"\n") --,self.gradientSpeed
            myLogFile:write("Explore Speed:,",simGetFloatSignal('_exploreSpeed') or 2.0,"\n") --self.exploreSpeed
            myLogFile:write("Target Epsilon:,",simGetFloatSignal('_targetEpsilon') or 0.05,"\n") --self.targetEpsilon
            
            myLogFile:write("Width Factor:,",simGetFloatSignal('_widthFactor') or 30,"\n") --self.widthFactor
            myLogFile:write("Step Factor:,",simGetFloatSignal('_stepFactor') or 0.5,"\n") --self.stepFactor
            myLogFile:write("CP EpsilonRatio:,",simGetFloatSignal('_checkpointEpsilonRatio') or 0.995,"\n") --self.checkpointEpsilonRatio

            myLogFile:write("IMU Noise:,",simGetFloatSignal('imu:noiseMagnitude') or 0,"\n")



            myLogFile:write("\n\n")
             
            myLogFile:write("Time steps,Height\n")
            headerOnce=true
        end
        local timestamp, logValue
        local sortedLogKeys = {}

        for timestamp, logValue in pairs(logData) do
            table.insert(sortedLogKeys,timestamp)
        end

        table.sort(sortedLogKeys)
        for  _, timestamp in ipairs(sortedLogKeys) do
            logValue = logData[timestamp]
            myLogFile:write(timestamp, ",",logValue, "\n")
            myLogFile:flush()
        end
        return myLogFile:close()
    end

    function  self.SaveLogDataEachTimeStep()
        local timestamp = math.floor(simGetSimulationTime()*1000)
        heightLog[timestamp] = currentMapHeight
    end

    function self.initializeUI()
        -- Set the title of the user interface: 
        simSetUIButtonLabel(finkenLocalMapUI,0,"Finken Local map:")
        simSetUIButtonLabel(finkenLocalMapUI,3,"Size of Map (in CM):") 
        simSetUIButtonLabel(finkenLocalMapUI,4,"Size of Field (in CM):") 
        simSetUIButtonLabel(finkenLocalMapUI,7,"Update")
        simSetUIButtonLabel(finkenLocalMapUI,8,"Display Data")

        -- Retrieve the desired data from the user interface:
        sizeOfContainer = tonumber(simGetUIButtonLabel(finkenLocalMapUI,5))
        sizeOfField = tonumber(simGetUIButtonLabel(finkenLocalMapUI,6))
        
        --Setup all signals to be called from outside this scene
        simSetFloatSignal('_LM_SizeOfContainer',sizeOfContainer)
        simSetFloatSignal('_LM_SizeOfField',sizeOfField)
    end


	function self.customInit()
		helperSay("Follow the gradient estimated from the local map...")

        -- Following is the handle of FINken2's associated UI (user interface):
        finkenLocalMapUI=simGetUIHandle("FinkenLocalMap")

        isRemoteApi = simGetIntegerSignal('_isRemoteApi') or 0
        simAddStatusbarMessage("IsRemoteApi:"..isRemoteApi)

        if isRemoteApi==0 then
            self.initializeUI()
        end

        self.CopterPositionSetToCenterOfMap()
        -- Update the local map data and then setup a map around finken
        self.UpdateLocalMapDataFromUI()

        --Create a VirtualBoxAround the Finken
        self.CreateAVirtualBoxAroundFinken()
        -- initialize magic numbers and state information
        self.targetReached = 1 -- 0 for false and 1 for true
        self.gradientSpeed = simGetFloatSignal('_gradientSpeed') or 0.3
        self.exploreSpeed = simGetFloatSignal('_exploreSpeed') or 2.0
        self.targetEpsilon = simGetFloatSignal('_targetEpsilon') or 0.05
        self.mode = simGetIntegerSignal('_mode') or 0 -- 0 for straight line gradient, 1 for drunk gradient, 2 for random
        if self.mode==1 then
            self.widthFactor = simGetFloatSignal('_widthFactor') or 30
            self.stepFactor = simGetFloatSignal('_stepFactor') or 0.5
            -- the higher this value, the further away the target can be
            self.checkpointEpsilonRatio = simGetFloatSignal('_checkpointEpsilonRatio') or 0.995
            self.checkpoints = {}
            self.remainingCheckpoints = 0
        end
        self.position = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)
        --Create a local map data table, initialise with {0,0}
        for k, v in pairs(LocalMap) do
            simAddStatusbarMessage(k)
        end
        self.myMap = LocalMap.new(sizeOfContainer, sizeOfField)
        for k, v in pairs(self.myMap) do
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
        simSetObjectPosition(targetObj, -1, {x, y, 2})
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
        sizeOfContainer =  simGetFloatSignal('_LM_SizeOfContainer') or 10
        sizeOfField = simGetFloatSignal('_LM_SizeOfField') or 1
        simAddStatusbarMessage('Map: '..sizeOfContainer..'  Field: '..sizeOfField)
    end


    function self.CheckUIButton()
        --check if display data button is pressed
        btnValue = simGetUIEventButton(finkenLocalMapUI)
        if(btnValue == 8) then
            self.myMap:printData()
        end
    end

	function self.customRun()
        -- Gradient images from matlab
        -- R: height
        -- G: x gradient (0.5 intensity corresponds to 0 gradient)
        -- B: y gradient
        -- the vision sensor Floor_camera returns a table of values
        -- the first element colors[1] is the overall lightness of the image
        -- the other elements colors[2] is Red, colors[3] is Green, colors[4] is Blue

        self.CheckUIButton()

		local _, colors = simReadVisionSensor(simGetObjectHandle('Floor_camera'))
        -- Setting the speed signals, so that the texture and arena can be moved
        oldFinkenPosition = self.position
        self.position= simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)
        xSpeed = self.position[1] - oldFinkenPosition[1]
        ySpeed = self.position[2] - oldFinkenPosition[2]
        simSetFloatSignal('_xSpeed', -xSpeed*100)
        simSetFloatSignal('_ySpeed', -ySpeed*100)

        if colors==nil then 
            return
        end

        --saving current height of map where finken is at this time step.
        currentMapHeight = colors[2]
        self.updateTarget()
        imu_xVel = simGetFloatSignal('imu:xVel') * 0.05 or 0      -- multiply with 0.05 because imu gives speed in m/s and one simulation step is 50 ms 
        imu_yVel = simGetFloatSignal('imu:yVel') * 0.05 or 0
        
        self.myMap:updateMap(imu_xVel, imu_yVel, currentMapHeight, true, 0.01, false)
        self.myMap:UpdateTextureLocalMapDataTableForUI()

        self.SaveLogDataEachTimeStep()
	end

    function self.updateTarget()
        if self.mode==2 then
            self.setTargetToPosition(self.position[1]+(math.random()-0.5) * self.gradientSpeed, self.position[1]+(math.random()-0.5) * self.gradientSpeed)
        elseif self.targetReached==1 then
            self.setNewTarget()
        else
            self.setTarget(targetObj)
            currentTargetPosition = simGetObjectPosition(targetObj, -1)
            -- euclidean distance to target
            xDist = currentTargetPosition[1]-self.position[1]
            yDist = currentTargetPosition[2]-self.position[2]
            distToTarget = math.sqrt(xDist * xDist + yDist * yDist)
            self.updateReachedStatus( distToTarget )
        end
    end 

    function self.updateReachedStatus( distToTarget )
        if self.mode==1 and self.remainingCheckpoints > 0 then
            targetDist = sizeOfField/100 * self.widthFactor * self.checkpointEpsilonRatio
        else
            targetDist = self.targetEpsilon
        end
        if distToTarget < targetDist then
            self.targetReached = 1 -- 0 for false and 1 for true
            simSetShapeColor(simGetObjectHandle('SimFinken_target'), nil, 0, {0, 1, 0})
        end 
    end

    function self.setNewTarget()
        if self.mode==1 and self.remainingCheckpoints > 0 then
            self.setTargetToPosition(self.checkpoints[self.remainingCheckpoints][1], self.checkpoints[self.remainingCheckpoints][2])
            self.remainingCheckpoints = self.remainingCheckpoints - 1
            simSetShapeColor(simGetObjectHandle('SimFinken_target'), nil, 0, {0, 0, 1})
            if self.remainingCheckpoints == 0 then
                simSetShapeColor(simGetObjectHandle('SimFinken_target'), nil, 0, {1, 0, 0})
            end
            self.targetReached = 0 -- 0 for false and 1 for true
        else
            neighborMat, neighborArr, matOffset, arrOffset = self.myMap:getEightNeighbors()
            gradientCalc, mapValues, localOffsets = canCalculateGradient(neighborArr, arrOffset)
            if gradientCalc ~= -1 then
                xGrad, yGrad = calculateGradient(gradientCalc, mapValues, neighborMat[2][2], localOffsets, matOffset[2][2])
                if xGrad ~= 0 or yGrad ~= 0 then
                    self.setTargetToGradient(xGrad, yGrad)
                end -- else it will continue in previous direction
            else
                self.setTargetToExplore(neighborArr)
            end
        end
    end

    function self.setTargetToGradient(xGrad, yGrad)
        gradientLength = math.sqrt(xGrad*xGrad + yGrad*yGrad)
        xGradNormalized = xGrad/gradientLength
        yGradNormalized = yGrad/gradientLength
        
        xGrad = xGradNormalized * self.gradientSpeed
        yGrad = yGradNormalized * self.gradientSpeed
        if self.mode==1 then
            onLinePosition = self.position
            xStep = xGradNormalized * sizeOfField/100 * self.stepFactor
            yStep = yGradNormalized * sizeOfField/100 * self.stepFactor
            xSideStep = yGradNormalized * sizeOfField/100 * self.widthFactor
            ySideStep = -xGradNormalized * sizeOfField/100 * self.widthFactor
            numCheckpoints = math.ceil(self.gradientSpeed / (sizeOfField/100 * self.stepFactor)) -- all that fit in between, plus one for final target
            self.remainingCheckpoints = numCheckpoints - 1
            while numCheckpoints > 1 do
                onLinePosition = {onLinePosition[1] + xStep, onLinePosition[2] + yStep}
                self.checkpoints[numCheckpoints] = {onLinePosition[1] + xSideStep, onLinePosition[2] + ySideStep}
                numCheckpoints = numCheckpoints - 1
                xSideStep = -xSideStep
                ySideStep = -ySideStep
            end
            self.checkpoints[1] = {self.position[1] + xGrad, self.position[2] + yGrad}

            self.setTargetToPosition(self.checkpoints[self.remainingCheckpoints+1][1], self.checkpoints[self.remainingCheckpoints+1][2])
            simSetShapeColor(simGetObjectHandle('SimFinken_target'), nil, 0, {0, 0, 1})
            self.targetReached = 0 -- 0 for false and 1 for true
        else
            xTarget = self.position[1] + xGrad
            yTarget = self.position[2] + yGrad
            self.setTargetToPosition(xTarget, yTarget)
            simSetShapeColor(simGetObjectHandle('SimFinken_target'), nil, 0, {1, 0, 0})
            self.targetReached = 0 -- 0 for false and 1 for true
        end
    end

    function self.setTargetToExplore( neighborArr )
        orthoPresent = getFilledDirection(neighborArr)
        -- go in clockwise orthogonal because why not
        exploreTargetOffset = sizeOfField/100*self.exploreSpeed
        if orthoPresent == 2 then
            self.setTargetToPosition(self.position[1]+exploreTargetOffset, self.position[2])
        elseif orthoPresent == 4 then
            self.setTargetToPosition(self.position[1], self.position[2]+exploreTargetOffset)
        elseif orthoPresent == 6 then
            self.setTargetToPosition(self.position[1]-exploreTargetOffset, self.position[2])
        else
            self.setTargetToPosition(self.position[1], self.position[2]-exploreTargetOffset)
        end
    end

	function self.customSense()

	end

	function self.customClean()
        --Called once at the end of simulation, write log data here
        SaveLogDataToFile(heightLog, "Height",simGetStringSignal('_fileName'),simGetNameSuffix(nil), simGetStringSignal('_filePath'), ".csv")
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
function canCalculateGradient( arr, offset )
    -- prefer the ones where we actually calculate the gradient at the current position
    for i = 9,12 do
        if arr[(i-8)*2] ~= nil and arr[((i-8)*2)%8+2] ~= nil then
            return i, {arr[(i-8)*2], arr[((i-8)*2)%8+2]}, {offset[(i-8)*2], offset[((i-8)*2)%8+2]}
        end
    end
    for i = 1,8 do
        if arr[i] ~= nil and arr[(i%8)+1] ~= nil then
            return i, {arr[i], arr[(i%8)+1]}, {offset[i], offset[(i%8)+1]}
        end
    end
    return -1
end

function calculateGradient( version, mapValues, centerValue, mapOffsets, centerOffset)
    local xGrad = 0
    local yGrad = 0
    if version == 1 then
        xGrad = mapValues[2] - mapValues[1]
        xScale = sizeOfField + mapOffsets[2][1] - mapOffsets[1][1]
        yGrad = centerValue - mapValues[2]
        yScale = sizeOfField + centerOffset[2] - mapOffsets[2][2]
    elseif version == 2 then
        xGrad = mapValues[2] - mapValues[1]
        xScale = sizeOfField + mapOffsets[2][1] - mapOffsets[1][1]
        yGrad = centerValue - mapValues[1]
        yScale = sizeOfField + centerOffset[2] - mapOffsets[1][2]
    elseif version == 3 then
        xGrad = mapValues[2] - centerValue
        xScale = sizeOfField + mapOffsets[2][1] - centerOffset[1]
        yGrad = mapValues[2] - mapValues[1]
        yScale = sizeOfField + mapOffsets[2][2] - mapOffsets[1][2]
    elseif version == 4 then
        xGrad = mapValues[1] - centerValue
        xScale = sizeOfField + mapOffsets[1][1] - centerOffset[1]
        yGrad = mapValues[2] - mapValues[1]
        yScale = sizeOfField + mapOffsets[2][2] - mapOffsets[1][2]
    elseif version == 5 then
        xGrad = mapValues[1] - mapValues[2]
        xScale = sizeOfField + mapOffsets[1][1] - mapOffsets[2][1]
        yGrad = mapValues[2] - centerValue
        yScale = sizeOfField + mapOffsets[2][2] - centerOffset[2]
    elseif version == 6 then
        xGrad = mapValues[1] - mapValues[2]
        xScale = sizeOfField + mapOffsets[1][1] - mapOffsets[2][1]
        yGrad = mapValues[1] - centerValue
        yScale = sizeOfField + mapOffsets[1][2] - centerOffset[2]
    elseif version == 7 then
        xGrad = centerValue - mapValues[2]
        xScale = sizeOfField + centerOffset[1] - mapOffsets[2][1]
        yGrad = mapValues[1] - mapValues[2]
        yScale = sizeOfField + mapOffsets[1][2] - mapOffsets[2][2]
    elseif version == 8 then
        xGrad = centerValue - mapValues[1]
        xScale = sizeOfField + centerOffset[1] - mapOffsets[1][1]
        yGrad = mapValues[1] - mapValues[2]
        yScale = sizeOfField + mapOffsets[1][2] - mapOffsets[2][2]
    elseif version == 9 then
        xGrad = mapValues[2] - centerValue
        xScale = sizeOfField + mapOffsets[2][1] - centerOffset[1]
        yGrad = centerValue - mapValues[1]
        yScale = sizeOfField + centerOffset[2] - mapOffsets[1][2]
    elseif version == 10 then
        xGrad = mapValues[1] - centerValue
        xScale = sizeOfField + mapOffsets[1][1] - centerOffset[1]
        yGrad = mapValues[2] - centerValue
        yScale = sizeOfField + mapOffsets[2][2] - centerOffset[2]
    elseif version == 11 then
        xGrad = centerValue - mapValues[2]
        xScale = sizeOfField + centerOffset[1] - mapOffsets[2][1]
        yGrad = mapValues[1] - centerValue
        yScale = sizeOfField + mapOffsets[1][2] - centerOffset[2]
    else
        xGrad = centerValue - mapValues[1]
        xScale = sizeOfField + centerOffset[1] - mapOffsets[1][1]
        yGrad = centerValue - mapValues[2]
        yScale = sizeOfField + centerOffset[2] - mapOffsets[2][2]
    end
    xGrad = xGrad * xScale
    yGrad = yGrad * yScale
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
