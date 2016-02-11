local landscape = {}
local handle = simGetObjectHandle('Landscape')
local imgIter = 1
local step = 0
local xSpeed, ySpeed, xScale, yScale, filePath, fileName
local xOffset = 0
local yOffset = 0
local shapeHandle =-1

function landscape.init(self)

	function self.step()
        step = (step + 1)
        if step == 99 then
            imgIter = (imgIter) % 5 + 1
        end
        --if step == 100 then
            simSetShapeTexture(handle, textureId, 0, 12, {20, 20}, {step/100, step/100, 0}, nil)
        --end
        simAddStatusbarMessage("Old step method")
    end

    function self.customInit( )
        -- This is executed exactly once, the first time this script is executed
        landscapesParent=simGetObjectAssociatedWithScript(sim_handle_self)
        -- following is the handle of landscape's associated UI (user interface):
        conveyorUIControl=simGetUIHandle("ConveyorControls")
        -- Set the title of the user interface: 
        simSetUIButtonLabel(conveyorUIControl,0,"Parameters for map:")
        simSetUIButtonLabel(conveyorUIControl,3,"xSpeed:") 
        simSetUIButtonLabel(conveyorUIControl,4,"ySpeed:") 
        simSetUIButtonLabel(conveyorUIControl,5,"xScale:") 
        simSetUIButtonLabel(conveyorUIControl,6,"yScale:") 
        simSetUIButtonLabel(conveyorUIControl,7,"Path:") 
        simSetUIButtonLabel(conveyorUIControl,8,"Filename:")
        simSetUIButtonLabel(conveyorUIControl,14,"Update")

        -- Retrieve the desired data from the user interface:
        xSpeed = tonumber(simGetUIButtonLabel(conveyorUIControl,9))
        ySpeed = tonumber(simGetUIButtonLabel(conveyorUIControl,10))
        xScale = tonumber(simGetUIButtonLabel(conveyorUIControl,11))
        yScale = tonumber(simGetUIButtonLabel(conveyorUIControl,12))
        filePath = simGetUIButtonLabel(conveyorUIControl,13)
        fileName = simGetUIButtonLabel(conveyorUIControl,16)
        
        --Setup all signals to be called from outside this scene
        simSetFloatSignal('_xSpeed',xSpeed)
        simSetFloatSignal('_ySpeed',ySpeed)
        simSetFloatSignal('_xScale',xScale)
        simSetFloatSignal('_yScale',yScale)
        simSetStringSignal('_filePath',filePath)
        simSetStringSignal('_fileName',fileName)

        self.UpdateData()
        xOffset = math.random() * xScale
        yOffset = math.random() * yScale
        self.CreateTexture()
        simAddStatusbarMessage("Data: "..xSpeed..ySpeed..xScale..yScale..filePath..fileName)
    end

    function self.CreateTexture()
        shapeHandle = simCreateTexture(filePath..fileName, 12, nil, {xScale, yScale}, nil, 0, nil)
        simSetObjectPosition(shapeHandle, -1, {0,0,100}) -- away from arena
    end

    function self.UpdateData()

        xSpeed=simGetFloatSignal('_xSpeed')
        ySpeed=simGetFloatSignal('_ySpeed')

        xScale=simGetFloatSignal('_xScale')
        yScale=simGetFloatSignal('_yScale')

        filePath=simGetStringSignal('_filePath')

        fileName=simGetStringSignal('_fileName')
        --simAddStatusbarMessage("Updated Data")
    end

    function self.CheckUIButton( )
        --pass values as signals to landscape class
        -- check if update button is pressed
        updateBtnValue = simGetUIEventButton(conveyorUIControl)
        boolValue = 14
        if(updateBtnValue == boolValue) then
            -- Retrieve the desired data from the user interface:
            xSpeed = tonumber(simGetUIButtonLabel(conveyorUIControl,9))
            ySpeed = tonumber(simGetUIButtonLabel(conveyorUIControl,10))
            xScale = tonumber(simGetUIButtonLabel(conveyorUIControl,11))
            yScale = tonumber(simGetUIButtonLabel(conveyorUIControl,12))
            filePath = simGetUIButtonLabel(conveyorUIControl,13)
            fileName = simGetUIButtonLabel(conveyorUIControl,16)
            
            --Setup all signals to be called from outside this scene
            simSetFloatSignal('_xSpeed',xSpeed)
            simSetFloatSignal('_ySpeed',ySpeed)
            simSetFloatSignal('_xScale',xScale)
            simSetFloatSignal('_yScale',yScale)
            simSetStringSignal('_filePath',filePath)
            simSetStringSignal('_fileName',fileName)
            --myLandscape.UpdateData()
        end
    end

    function self.RunSteps()
        self.CheckUIButton()
        self.UpdateData()

        --third parameter (options) set to 12, for repeat along u and v direction
        if (shapeHandle~=-1) then
            textureId = simGetShapeTextureId(shapeHandle)
            if (textureId~=-1) then
                handle=simGetObjectHandle("Landscape")
                if (handle~=-1) then
                        xOffset = xOffset + xSpeed/100
                        yOffset = yOffset + ySpeed/100

                        finkenPos = simGetObjectPosition(simGetObjectHandle('SimFinken_base'), -1)
                        finkenPos[3] = 0
                        simSetShapeTexture(handle, textureId, 0, 13, {xScale/2,yScale/2}, {xOffset, yOffset, 0}, nil)
                        simSetObjectPosition(handle, -1, finkenPos)
                        --
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