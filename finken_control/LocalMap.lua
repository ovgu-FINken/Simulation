local LocalMap = {}
LocalMap.__index = LocalMap

function LocalMap.new( totalSize, fieldSize )
	local self = setmetatable({}, LocalMap)
    self.totalSize = totalSize
    self.fieldSize = fieldSize
    self.resolution = math.floor(totalSize/fieldSize) -- The local map will have resolution*resolution fields
    simAddStatusbarMessage('Map resolution: '..self.resolution..'x'..self.resolution)
    self.map = {}
    -- initialize map data with -1, -1
    for x = 1,self.resolution do
        self.map[x] = {}
    end
    self.localOffset = {fieldSize/2, fieldSize/2}
    self.centerIdx = math.ceil(self.resolution/2)
    return self
end

-- limited functionality, when the elements in the map are tables
function LocalMap:printData()
    simAddStatusbarMessage('PRINTING MAP DATA')
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
                else
                    self.map[x][y] = self.map[x + xOffset][y]
                end
            end -- yloop
        end -- xloop
    end

    if(xOffset < 0) then
        for x = self.resolution, 1, -1 do
            for y = 1,self.resolution do
                if(x + xOffset < 1) then
                        self.map[x][y] = nil
                else
                    self.map[x][y] = self.map[x + xOffset][y]
                end
            end -- yloop
        end -- xloop
    end

    if(yOffset > 0) then
        for x = 1,self.resolution do
            for y = 1,self.resolution do
                if(y + yOffset > self.resolution ) then
                        self.map[x][y] = nil
                else
                    self.map[x][y] = self.map[x][y+yOffset]
                end
            end -- yloop
        end -- xloop
    end

    if(yOffset < 0) then
        for x = 1,self.resolution do
            for y = self.resolution, 1, -1 do
                if(y + yOffset < 1) then
                        self.map[x][y] = nil
                else
                    self.map[x][y] = self.map[x][y+yOffset]
                end
            end -- yloop
        end -- xloop
    end
end

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

    self.localOffset[1] = shiftOffset[1] - shift[1]
    self.localOffset[2] = shiftOffset[2] - shift[2]
    
    self:shiftLocalMap(shift[1], shift[2])

    if self.map[self.centerIdx][self.centerIdx]==nil or replace or  not average then
        self.map[self.centerIdx][self.centerIdx]=value
    else
        if type(value=='number') then
            self.map[self.centerIdx][self.centerIdx]=self.map[self.centerIdx][self.centerIdx]+alpha*value
        elseif type(value=='table') then
            for key,value in pairs(self.map[self.centerIdx][self.centerIdx]) do
                self.map[self.centerIdx][self.centerIdx][key] = self.map[self.centerIdx][self.centerIdx][key] + alpha * value[key]
            end
        else
            error('Cannot average non-numbers!')
        end
    end
end

return LocalMap