local finken = {}

finkenCore = require('finkenCore')


local function saveLog(newLog, newLogName, newSuffix, newDirectoryPath)
	local myTimeString = os.date("%Y%m%d%H%M%S")
	newDirectoryPath = newDirectoryPath or ""
	newSuffix = newSuffix or ""
	local myLogFile = assert(io.open(newDirectoryPath.."simulation" .. newSuffix .. newLogName .. myTimeString .. ".log", "w"))
	local timestamp, logValue 
	local sortedLogKeys = {}
	for timestamp, logValue in pairs(newLog) do
		table.insert(sortedLogKeys,timestamp)
	end
	table.sort(sortedLogKeys)

	for  _, timestamp in ipairs(sortedLogKeys) do
		logValue = newLog[timestamp]
		myLogFile:write(timestamp, ": ", logValue[1], " ", logValue[2]," ", logValue[3], "\n")
		myLogFile:flush()
	end
	return myLogFile:close()
end

function finken.init(self)
	local positionLog = {}
	local orientationLog = {}	
	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end

	function self.getArenaPosition()
		local handle_myReference = simGetObjectHandle("Master#")
		local handle_mySelf = self.getHandle()
		local myPosition = simGetObjectPosition(handle_mySelf, handle_myReference) 
		return myPosition
	end

	function self.helloWorld()
		helperSay("Hello World. Tschieep!")
	end


	--function customRun should be called in the vrep child script in the actuation part
	--put here any custom function that should be called each simulation time step
	function self.customRun()
		local timestamp = math.floor(simGetSimulationTime()*1000)
		positionLog[timestamp] = self.getArenaPosition()
		orientationLog[timestamp] = simGetObjectOrientation(self.getHandle(), -1);
	end
	
	--function customClean should be called in the vrep child scrip in the cleanup part
	--put here any custom function that should be called at the end of the simulation
	function self.customClean()
		saveLog(positionLog, "Position", self.thisIDsuffix)
		saveLog(orientationLog, "Orientation", self.thisIDsuffix)
	end
	return self
end



function finken.new()
	finkenCore.init()
	return finken.init(finkenCore)
end

return finken
