local landscape = {}
local handle = simGetObjectHandle('Landscape')
local imgIter = 1
local step = 0
local xSpeed, ySpeed, xScale, yScale, filePath
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


    function self.CreateTexture()
        shapeHandle = simCreateTexture(filePath, 12, nil, {xScale, yScale}, nil, 0, nil)
    end

    function self.UpdateData()

        xSpeed=simGetFloatSignal('_xSpeed')
        ySpeed=simGetFloatSignal('_ySpeed')

        xScale=simGetFloatSignal('_xScale')
        yScale=simGetFloatSignal('_yScale')

        filePath=simGetStringSignal('_filePath')

        --simAddStatusbarMessage("Updated Data")
    end

    function self.RunSteps()
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
                simSetShapeTexture(handle, textureId, 0, 12, {xScale/2,yScale/2}, {xOffset, yOffset, 0}, nil)
                simSetObjectPosition(handle, -1, finkenPos)
                end
            end
        end
    end
    simAddStatusbarMessage("Landscape self call")
	return self
end

return landscape