local landscape = {}
local step = 0
local handle = simGetObjectHandle('Landscape')
local imgPath = "C:/0/uni/SwaInTeP/resources/gradient_maps/hills.png"
local _, textureId = simCreateTexture(imgPath, 12, nil, {50, 50}, nil, 0, nil)
local imgIter = 1


function landscape.init(self)

	function self.step()
		step = (step + 1)
		-- if step == 99 then
		-- 	imgIter = (imgIter) % 5 + 1
		-- end
		--if step == 100 then
			--third parameter (options) set to 12, for repeat along u and v direction
		simSetShapeTexture(handle, textureId, 0, 12, {20, 20}, {step/200, step/100, 0}, nil)
		--end
		--simAddStatusbarMessage(textureId)
	end
	simAddStatusbarMessage(textureId)

	return self
end

return landscape