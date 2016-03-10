local landscape = {}
local handle = simGetObjectHandle('Landscape')
local step = 0
local xPosition, yPosition, xScale, yScale, filePath, fileName, numFinken
local xOffset = 0
local yOffset = 0
local shapeHandle =-1

function landscape.init(self)

    function self.initializeUI()
        -- Retrieve the desired data from the user interface:
        xScale = tonumber(simGetUIButtonLabel(conveyorUIControl,4))
        yScale = tonumber(simGetUIButtonLabel(conveyorUIControl,6))
        filePath = simGetUIButtonLabel(conveyorUIControl,8)
        fileName = simGetUIButtonLabel(conveyorUIControl,10)
    end

    function self.customInit()
        -- following is the handle of landscape's associated UI (user interface):
        conveyorUIControl=simGetUIHandle("ConveyorControls")

        isRemoteApi = simGetIntegerSignal('_isRemoteApi') or 0
        simAddStatusbarMessage("IsRemoteApi:"..isRemoteApi)

        self.initializeUI()
        simSetStringSignal('_filePath',filePath)
        if isRemoteApi==0 then
            --Setup all signals to be called from outside this scene
            simSetFloatSignal('_xScale',xScale)
            simSetFloatSignal('_yScale',yScale)
            simSetStringSignal('_fileName',fileName)
        end

        -- count how many Finkens there are
        numFinken = 1
        while true do
            suffix = numFinken-1
            finkenHandle = simGetObjectHandle('FINken2#'..suffix)
            if finkenHandle ~= -1 then
                numFinken = numFinken + 1
            else
               break
            end
        end

        self.UpdateData()
        xOffset = math.random() * xScale
        yOffset = math.random() * yScale
        self.CreateTexture()
        simAddStatusbarMessage("Landscape data: "..xScale.." "..yScale.." "..filePath.." "..fileName)


    end

    function self.CreateTexture()
       -- fileName=simGetStringSignal('_fileName')
        shapeHandle = simCreateTexture(filePath..fileName, 12, nil, {xScale, yScale}, nil, 0, nil)
        simSetObjectPosition(shapeHandle, -1, {0,0,100}) -- away from arena
    end

    function self.UpdateData()

        -- get all the Finken positions and compute the center
        totalPos = simGetObjectPosition(simGetObjectHandle('FINken2'), -1)
        for i = 2, numFinken do
            finkenHandle = simGetObjectHandle('FINken2#'..(i-2))
            finkenPos = simGetObjectPosition(finkenHandle, -1)
            totalPos[1] = totalPos[1] + finkenPos[1]
            totalPos[2] = totalPos[2] + finkenPos[2]
        end
        xPosition = totalPos[1] / numFinken
        yPosition = totalPos[2] / numFinken

        xScale= simGetFloatSignal('_xScale') or 10
        yScale= simGetFloatSignal('_yScale') or 10

        filePath= simGetStringSignal('_filePath') or simGetUIButtonLabel(conveyorUIControl,8)

        fileName=simGetStringSignal('_fileName')
    end

    function self.CheckUIButton( )
        --pass values as signals to landscape class
        -- check if update button is pressed
        updateBtnValue = simGetUIEventButton(conveyorUIControl)
        boolValue = 11
        if(updateBtnValue == boolValue) then
            -- Retrieve the desired data from the user interface:
            xScale = tonumber(simGetUIButtonLabel(conveyorUIControl,4))
            yScale = tonumber(simGetUIButtonLabel(conveyorUIControl,6))
            filePath = simGetUIButtonLabel(conveyorUIControl,8)
            fileName = simGetUIButtonLabel(conveyorUIControl,10)
            
            --Setup all signals to be called from outside this scene
            simSetFloatSignal('_xScale',xScale)
            simSetFloatSignal('_yScale',yScale)
            simSetStringSignal('_filePath',filePath)
            simSetStringSignal('_fileName',fileName)
        end
    end

    function self.RunSteps()
        self.CheckUIButton()
        self.UpdateData()

        if (shapeHandle~=-1) then
            textureId = simGetShapeTextureId(shapeHandle)
            if (textureId~=-1) then
                handle=simGetObjectHandle("Landscape")
                if (handle~=-1) then

                        landscapePos = simGetObjectPosition(simGetObjectHandle('Landscape'), -1)
                        xOffset = xOffset - xPosition + landscapePos[1]
                        yOffset = yOffset - yPosition + landscapePos[2]

                        --third parameter (options) set to 13, for repeat along u and v direction and no interpolation
                        simSetShapeTexture(handle, textureId, 0, 13, {xScale/2,yScale/2}, {xOffset, yOffset, 0}, nil)
                        simSetObjectPosition(handle, -1, {xPosition, yPosition, 0})
                else
                    simAddStatusbarMessage('There appears to be an error, could not find the texture or corresponding Object.')
                end
            end
        end
    end
    simAddStatusbarMessage("Landscape self call")
	return self
end

return landscape