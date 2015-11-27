local landscape = {}
local handle = simGetObjectHandle('Landscape')
local imgIter = 1
local step = 0
local xSpeed, ySpeed, xScale, yScale, filePath
local shapeHandle

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

    function self.UpdateData()

        xSpeed=simGetFloatSignal('_xSpeed')
        ySpeed=simGetFloatSignal('_ySpeed')

        xScale=simGetFloatSignal('_xScale')
        yScale=simGetFloatSignal('_yScale')

        filePath=simGetStringSignal('_filePath')
        imgIter = 1
        step = 0

       shapeHandle = simCreateTexture(filePath, 12, nil, {xScale, yScale}, nil, 0, nil)

        simAddStatusbarMessage("Updated Data")
    end

    function self.RunSteps()

        step = (step + 1)
        if step == 99 then
            imgIter = (imgIter) % 5 + 1
        end


        --third parameter (options) set to 12, for repeat along u and v direction
        if (shapeHandle~=-1) then
            textureId = simGetShapeTextureId(shapeHandle)
        if (textureId~=-1) then
            handle=simGetObjectHandle("Landscape")
        if (handle~=-1) then
                simSetShapeTexture(handle, textureId, 0, 12, {xScale/2,yScale/2}, {step/xSpeed, step/ySpeed, 0}, nil)
                end
            end
        end

    end
    simAddStatusbarMessage("Landscape self call")
	return self
end

return landscape