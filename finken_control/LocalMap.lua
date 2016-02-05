local LocalMap = {}
LocalMap.__index = LocalMap

local LMTextureHandle =-1
local LMTextureID = -1
local LMResolution =-1

function LocalMap.new( totalSize, fieldSize )
	local self = setmetatable({}, LocalMap)
    self.totalSize = totalSize
    self.fieldSize = fieldSize
    self.resolution = math.floor(totalSize/fieldSize) -- The local map will have resolution*resolution fields
    simAddStatusbarMessage('Map resolution: '..self.resolution..'x'..self.resolution)
    self.map = {}
    self.offsets = {}
    -- initialize map data with -1, -1
    for x = 1,self.resolution do
        self.map[x] = {}
        self.offsets[x] = {}
    end
    self.localOffset = {fieldSize/2, fieldSize/2}
    self.centerIdx = math.ceil(self.resolution/2)

    --create a texture for local map UI once and update it later
    self:CreateTextureLocalMapDataTable()
    return self
end

-- limited functionality, when the elements in the map are tables
function LocalMap:printData()
    simAddStatusbarMessage('PRINTING MAP DATA')
    simAddStatusbarMessage('offset: '..self.localOffset[1]..' '..self.localOffset[2])
    for x = 1,self.resolution do
        for y = 1,self.resolution do
            if self.map[x][y] ~= nil then
                simAddStatusbarMessage(x..', '..y..': '..tostring(self.map[x][y]))
            end
        end
    end
end


function LocalMap:shiftLocalMap(xOffset, yOffset)
    if(xOffset > 0) then
        for x = 1,self.resolution do
            for y = 1,self.resolution do
                if(x + xOffset > self.resolution ) then -- check if it would be trying to copy values from outside map --> create new empty column
                        self.map[x][y] = nil
                        self.offsets[x][y] = nil
                else
                    self.map[x][y] = self.map[x + xOffset][y]
                    self.offsets[x][y] = self.offsets[x + xOffset][y]
                end
            end -- yloop
        end -- xloop
    end

    if(xOffset < 0) then
        for x = self.resolution, 1, -1 do
            for y = 1,self.resolution do
                if(x + xOffset < 1) then
                        self.map[x][y] = nil
                        self.offsets[x][y] = nil
                else
                    self.map[x][y] = self.map[x + xOffset][y]
                    self.offsets[x][y] = self.offsets[x + xOffset][y]
                end
            end -- yloop
        end -- xloop
    end

    if(yOffset > 0) then
        for x = 1,self.resolution do
            for y = 1,self.resolution do
                if(y + yOffset > self.resolution ) then
                        self.map[x][y] = nil
                        self.offsets[x][y] = nil
                else
                    self.map[x][y] = self.map[x][y+yOffset]
                    self.offsets[x][y] = self.offsets[x][y+yOffset]
                end
            end -- yloop
        end -- xloop
    end

    if(yOffset < 0) then
        for x = 1,self.resolution do
            for y = self.resolution, 1, -1 do
                if(y + yOffset < 1) then
                        self.map[x][y] = nil
                        self.offsets[x][y] = nil
                else
                    self.map[x][y] = self.map[x][y+yOffset]
                    self.offsets[x][y] = self.offsets[x][y+yOffset]
                end
            end -- yloop
        end -- xloop
    end
end


-- Create Texture and WriteTexture for the UI of local map visualization

function  LocalMap:CreateTextureLocalMapDataTable()
    --Create an empty texture with some scale
    -- THE EmptyTexture.png resolution should map the, local map size and field size to proper visualization.
    --number shapeHandle,number textureId,table_2 resolution=simCreateTexture(string fileName,number options,table_2 planeSizes=nil,table_2 scalingUV=nil,table_2 xy_g=nil,number fixedResolution=0,table_2 resolution=nil)

    LMTextureHandle, LMTextureID, LMResolution= simCreateTexture('/Users/asemahassan/Documents/Simulation/resources/gradient_maps/map_images/EmptyTexture16.png',3, {self.totalSize/50,self.totalSize/50}, {1,1}, nil, 0, {1,1})
    simAddStatusbarMessage('R:'..LMResolution[1]..LMResolution[2])

    --Add the texture as the child of finken
    --number result=simSetObjectParent(number objectHandle,number parentObjectHandle,boolean keepInPlace)
    finkenCurrentPos=simGetObjectPosition(simGetObjectHandle('SimFinken_base'),-1)
    simSetObjectParent(LMTextureHandle,simGetObjectHandle('SimFinken_base'),false)
    simSetObjectPosition(LMTextureHandle, -1, {finkenCurrentPos[1],finkenCurrentPos[2],finkenCurrentPos[3]+0.25})

    LMTextureID = simGetShapeTextureId(LMTextureHandle)
    simSetShapeTexture(simGetObjectHandle('LocalMapVisual'), -1, 0,3, {1, 1}, {0, 0, 0}, nil)

end

function  LocalMap:UpdateTextureLocalMapDataTableForUI()

    --TODO: save the image in directory ?

    local textureDataMap = ''
    rgb = {}

     --get resolution of actual texture that you're writing and then iterate over each field and fill it with black color'
    for i=1, LMResolution[1]*LMResolution[2]* 3 do
        rgb[i]= 0
    end

    for r=1,self.resolution do
        for c=1,self.resolution do
            --string data=simPackBytes(table byteNumbers,number startByteIndex=0,number bytecount=0)
            rgb[((c-1)*self.resolution+r)*3-2] = self.map[r][c]

            if(rgb[((c-1)*self.resolution+r)*3-2] == nil) then
                rgb[((c-1)*self.resolution+r)*3-2] = 0
            else
               rgb[((c-1)*self.resolution+r)*3-2]= math.floor(self.map[r][c]*255)
            end

       end
    end

    textureDataMap = simPackBytes(rgb)

	--simWriteTexture(number textureId,number options,string textureData,number posX=0,number posY=0,number sizeX=0,number sizeY=0)
    simWriteTexture(LMTextureID,0,textureDataMap)
    simSetShapeTexture(simGetObjectHandle('LocalMapVisual'), LMTextureID, 0, 3, {1, 1}, {0, 0, 0}, nil)

end --function



function LocalMap:updateMap( xDistance, yDistance, value, average, alpha, replace )
    -- xDistance, yDistance: Distance the copter has moved (in meters)
    -- value: the value to be written into the local map
    -- average: whether to average the vaules, if the copter has not moved to another field, assumes, that value is a table of numeric values
    -- alpha: factor, that determines how strongly the new value is weighted in the average. alpha=0: always use the first value measured for this field. alpha=1: always use the lates measured value
    -- whether to replace existing values in the map, when the field is being revisited, otherwise average
    average = average or false
    alpha = alpha or 0.2
    replace = replace or true

    -- convert to cm
    xDistance = xDistance * 100
    yDistance = yDistance * 100
    shiftOffset = {}
    shiftOffset[1] = self.localOffset[1] + xDistance
    shiftOffset[2] = self.localOffset[2] + yDistance
    -- simAddStatusbarMessage('x, y distance: '..xDistance..' '..yDistance)

    -- how many fields the copter has moved, i.e. how far the map values need to be shifted
    shift = {}
    shift[1] = math.floor(shiftOffset[1]/self.fieldSize)
    shift[2] = math.floor(shiftOffset[2]/self.fieldSize)
    -- simAddStatusbarMessage('x y shift: '..shift[1]..' '..shift[2])

    self.localOffset[1] = shiftOffset[1] - shift[1]*self.fieldSize
    self.localOffset[2] = shiftOffset[2] - shift[2]*self.fieldSize
    
    self:shiftLocalMap(shift[1], shift[2])

    if self.map[self.centerIdx][self.centerIdx]==nil or replace or not average then
        self.map[self.centerIdx][self.centerIdx]=value
        self.offsets[self.centerIdx][self.centerIdx] = {self.localOffset[1], self.localOffset[2]}
    else
        xLocalOffset = (1-alpha)*self.offsets[self.centerIdx][self.centerIdx][1] + alpha * self.localOffset[1]
        yLocalOffset = (1-alpha)*self.offsets[self.centerIdx][self.centerIdx][2] + alpha * self.localOffset[2]
        self.offsets[self.centerIdx][self.centerIdx] = {xLocalOffset, yLocalOffset}
        if type(value=='number') then
            self.map[self.centerIdx][self.centerIdx]=(1-alpha)*self.map[self.centerIdx][self.centerIdx]+alpha*value
        elseif type(value=='table') then
            for key,value in pairs(self.map[self.centerIdx][self.centerIdx]) do
                self.map[self.centerIdx][self.centerIdx][key] = (1-alpha)*self.map[self.centerIdx][self.centerIdx][key] + alpha * value[key]
            end
        else
            error('Cannot average non-numbers!')
        end
    end
end

function LocalMap:getEightNeighbors()
    -- returns the immediate neighbors of the central field and the center itself as a 3x3 array, and the neighbors only as a 1x8 array, starting at top left corner
    mat = {}
    arr = {}
    matOffset = {}
    arrOffset = {}
    for x = 1,3 do
        mat[x] = {}
        arr[x] = self.map[self.centerIdx+(x-2)][self.centerIdx-1]
        matOffset[x] = {}
        arrOffset[x] = self.offsets[self.centerIdx+(x-2)][self.centerIdx-1]
        for y = 1,3 do
            mat[x][y] = self.map[self.centerIdx+(x-2)][self.centerIdx+(y-2)]
            matOffset[x][y] = self.offsets[self.centerIdx+(x-2)][self.centerIdx+(y-2)]
        end
    end
    arr[4] = self.map[self.centerIdx+1][self.centerIdx]
    arr[8] = self.map[self.centerIdx-1][self.centerIdx]
    arrOffset[4] = self.offsets[self.centerIdx+1][self.centerIdx]
    arrOffset[8] = self.offsets[self.centerIdx-1][self.centerIdx]
    for i = 5,7 do
        arr[i] = self.map[self.centerIdx-(i-6)][self.centerIdx+1]
        arrOffset[i] = self.offsets[self.centerIdx-(i-6)][self.centerIdx+1]
    end
    return mat, arr, matOffset, arrOffset
end

return LocalMap