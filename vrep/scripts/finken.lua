local finken = {}

finkenCore = require('finkenCore')
require('psoFunctions')
--save a timestamped log array to a file
--currently only works for data arrays with 3 columns
--@newSuffix and @newDirectoryPath are optional
local function saveLog(newLogData, newLogName, newSuffix, newDirectoryPath, newTimeString)
	newTimeString = newTimeString or os.date("%Y%m%d%H%M%S")
	newDirectoryPath = newDirectoryPath or ""
	newSuffix = newSuffix or ""
	local myLogFile = assert(io.open(newDirectoryPath.."sim" .. newTimeString .. "finken" .. newSuffix .. newLogName .. ".log", "w"))
	local timestamp, logValue
	local sortedLogKeys = {}
	for timestamp, logValue in pairs(newLogData) do
		table.insert(sortedLogKeys,timestamp)
	end
	table.sort(sortedLogKeys)

	for  _, timestamp in ipairs(sortedLogKeys) do
		logValue = newLogData[timestamp]
		
		if type(logValue)=='table' then
			myLogFile:write(timestamp, "; ", table.concat(logValue, '; '), "\n")
		else
			myLogFile:write(timestamp, "; ", logValue, "\n")
		end
		myLogFile:flush()
	end
	return myLogFile:close()
end

local function saveConfig(newConfig, newDirectoryPath, newTimeString)
	newTimeString = newTimeString or os.date("%Y%m%d%H%M%S")
	newDirectoryPath = newDirectoryPath or ""
	local myLogFile = assert(io.open(newDirectoryPath.."sim" .. newTimeString .. "config" ..  ".cfg", "w"))
	for k,v in pairs(newConfig) do
		if type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean' then
			myLogFile:write(k, ": ", v, "\n")
		end
	end
	if newConfig.problemFunction == ackley then
			myLogFile:write("problemFunction: ackley\n")
	else
		if newConfig.problemFunction == rosenbrock then
			myLogFile:write("problemFunction: rosenbrock\n")
		end
	end
	for k, v in pairs(newConfig.attractionRepulsion) do
		if type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean' then
			myLogFile:write("attractionRepulsion.",k, ": ", v, "\n")
		end
	end
	for k, v in pairs (newConfig.pso) do
		if type(v) == 'string' or type(v) == 'number' or type(v) == 'boolean' then
			myLogFile:write("pso.",k, ": ", v, "\n")
		end
	end
	myLogFile:flush()
end

--local function parseData(newData)
	--''
--end
--implement the FINken main class
function finken.init(self, selfConfig)
	local positionLog = {}
	local fitnessLog= {}
	local lBestLog= {}
	local gBestLog = {}
	local msgTimestampLog= {}
	local msgSenderLog= {}
	local messages = {}
	local timestamps = {}
	local formattedData = {}
    local stepsSinceCommunication = 0
	local pos=simGetObjectPosition(self.getBaseHandle(),-1)
    local optPosition_memory = {x = pos[1], y = pos[2]}
	local cfg = finken.prepareConfig(selfConfig)
    local optimum_memory = cfg.problemFunction(pos[1], pos[2])
	--example of a local helper function only for the FINken class
	local function helperSay(textToSay)
		simAddStatusbarMessage(textToSay)
	end
	--example of a new function for the FINken
	--use with care, better write a local function and call it e.g. in self.customRun()
	function self.helloWorld()
		helperSay("Hello World. Tschieep!")
	end

	--@TODO check if reference should be with :
	function self.getArenaPosition()
		local handle_myReference = simGetObjectHandle("Master#")
		local handle_mySelfBase = self.getBaseHandle()
		local myPosition = simGetObjectPosition(handle_mySelfBase, handle_myReference)
		return myPosition
	end

	function self.getInitTarget()
		return {math.random(math.ceil(cfg.xMin), math.floor(cfg.xMax)), math.random(math.ceil(cfg.yMin), math.floor(cfg.yMax)), cfg.zInit}
	end
	
	--[[
 	-- function to format the received messages to enable further processing
 	-- senderIds = {vrepHandle}, rawData = {simPackFloats(fitness, x,y)}
 	--@return {vrepHandle.fitness, vrepHandle.x, vrepHandle.x}
 	--]]
	local function formatDataFitXY(senderIds, rawData)
		for k, v in ipairs(senderIds) do
			formattedData[v] = {fitnessVal = nil, x = nil, y = nil}
			formattedData[v].fitnessVal, formattedData[v].x, formattedData[v].y = unpack(simUnpackFloats(rawData[k], 0, 3, 0)) 
		end
	end

	--[[
 	-- function to make the received messages available to the FINken
 	-- msgTable =  {ID, fitnessVal, posX, posY}
 	--@return 
 	--]]
	function self.receiveAllData(dataNameGet)
		local receivedData = {}
		local senderID = {}
		local dataHeader = {}
		local dataName = {}
		local i = 1
		receivedData[i], senderID[i], dataHeader[i], dataName[i] = simReceiveData(802154, dataNameGet, sim_handle_self, i-1)
		while receivedData[i] do
			--formattedData[senderID[i]] = {fitnessVal = nil, x = nil, y = nil}
			--formattedData[senderID[i]].fitnessVal, formattedData[senderID[i]].x, formattedData[senderID[i]].y = unpack(simUnpackFloats(receivedData[i])) 
			i = i + 1
			receivedData[i], senderID[i], dataHeader[i], dataName[i] = simReceiveData(802154, dataNameGet, sim_handle_self, i-1)
		end
		local timestamp = math.floor(simGetSimulationTime()*1000)
		msgSenderLog[timestamp] = senderID 
		formatDataFitXY(senderID, receivedData)
	end

	local function newTargetPosition()
		local handle_mySelfBase = self.getBaseHandle()
		local pos=simGetObjectPosition(handle_mySelfBase,-1)
		local posTarget=simGetObjectPosition(self.getTarget(),-1)
    	local fitness = cfg.problemFunction(pos[1], pos[2])
    	if fitness < optimum_memory then
    		optimum_memory = fitness
			optPosition_memory = {x = pos[1], y = pos[2]}
		end
		local targetNeighbour= {x = posTarget[1], y = posTarget[2]}
		local f_cohesion = {0, 0}
		
		for _, v in pairs(formattedData) do
			--find best fitness in neighbourhood
			if  (v.fitnessVal < fitness) then
				fitness = v.fitnessVal
				targetNeighbour.x = v.x
				targetNeighbour.y = v.y
			end
			--compute attraction and repulsion for each known neighbour
			local euclidianDist = getEuclidianDist_minDimension(pos, {v.x, v.y})
			local f_repulsion = cfg.attractionRepulsion.b  * math.exp(-(euclidianDist ^ 2) / cfg.attractionRepulsion.c)
			local relativePosition = addVectors({v.x, v.y}, multVectorScalar(pos, -1))
			f_cohesion = addVectors(f_cohesion, multVectorScalar(relativePosition, cfg.attractionRepulsion.a - f_repulsion))

		end
		local timestamp = math.floor(simGetSimulationTime()*1000)
		gBestLog[timestamp] = fitness 
		
		local f_targetNeighbours = addVectors({targetNeighbour.x, targetNeighbour.y}, multVectorScalar(pos, -1))
		local f_targetMemory = addVectors({optPosition_memory.x, optPosition_memory.y}, multVectorScalar(pos, -1))
		local f_target = {0,0}
		--f_target[1] = cfg.pso.cCognitive * (math.random()) * f_targetNeighbours[1] +cfg.pso.cSocial *(math.random()) * f_targetMemory[1]
		--f_target[2] = cfg.pso.cCognitive * (math.random())* f_targetNeighbours[2] +cfg.pso.cSocial *(math.random()) * f_targetMemory[2]
		f_target[1] = cfg.pso.cCognitive * (math.random()/2+0.5) * f_targetNeighbours[1] +cfg.pso.cSocial *(math.random()/2+0.5) * f_targetMemory[1]
		f_target[2] = cfg.pso.cCognitive * (math.random()/2+0.5)* f_targetNeighbours[2] +cfg.pso.cSocial *(math.random()/2+0.5) * f_targetMemory[2]
		--f_target[1] = cfg.pso.cCognitive * f_targetNeighbours[1] +cfg.pso.cSocial * f_targetMemory[1]
		--f_target[2] = cfg.pso.cCognitive * f_targetNeighbours[2] +cfg.pso.cSocial * f_targetMemory[2]

		
		--target should only be reached in first step or without neighbours. then default to random walk
		---[[
		--if (math.abs(f_target[1]) + math.abs(f_target[2]) < 0.1) then
		if ((getEuclidianDist_minDimension(pos, posTarget)) < 0.01) then
			simAddStatusbarMessage("randomWalk because: " .. getEuclidianDist_minDimension(pos, simGetObjectPosition(self.getTarget(), -1))) 
			f_target= {math.random(-1, 1),math.random(-1, 1)}
		end--]]
		
		if (cfg.logLevel > 2 and targetNeighbour) then simAddStatusbarMessage("bestFitnessTarget: " .. targetNeighbour["x"] .. '; ' ..  targetNeighbour["y"]) end
		if (cfg.logLevel > 4 and pos) then simAddStatusbarMessage("currentCoords: " .. pos[1] .. '; ' ..  pos[2]) end
		if (cfg.logLevel > 3 and f_target) then simAddStatusbarMessage("f_target: " .. f_target[1] .. '; ' .. f_target[2]) end
		if (cfg.logLevel > 2 and f_cohesion) then simAddStatusbarMessage("f_cohesion: " .. f_cohesion[1] .. '; ' ..  f_cohesion[2]) end
		
		f_cohesion = multVectorScalar(f_cohesion, cfg.attractionRepulsion.wCohesion)
		f_target = multVectorScalar(f_target, cfg.attractionRepulsion.wTarget)
		local targetCoordinates = {x = 0, y = 0}
		targetCoordinates.x = pos[1] + f_target[1] + f_cohesion[1]
		targetCoordinates.y = pos[2] + f_target[2] + f_cohesion[2]
		return targetCoordinates
	end

	--function customRun should be called in the vrep child script in the actuation part
	--put here any custom function that should be called each simulation time step
	function self.customRun()
		local timestamp = math.floor(simGetSimulationTime()*1000)
		positionLog[timestamp] = self.getArenaPosition()
		lBestLog[timestamp] = optimum_memory 
    	--header 802154
    	--dataName 0
    	--simSendData(sim_handle_all, 802154, 0, "test0", sim_handle_self, 15, 3.1416, 6.283, 0)
    	local pos=simGetObjectPosition(finken_base_handle,-1)
    	local fitValue = cfg.problemFunction(pos[1], pos[2])
		fitnessLog[timestamp] = fitValue
      
    	local data = simPackFloats({fitValue, pos[1], pos[2]}, 0, 3)
    	local simulationTimeStep = simGetSimulationTimeStep()
    	if stepsSinceCommunication > cfg.communicationFrequentness then 
    		if (cfg.communication < 0) then
    			simSendData(sim_handle_all, 802154, 0, data, sim_handle_self, cfg.communicationRange, 3.1416, 6.283, 1*simulationTimeStep)
    		else
				data = data .. string.rep('0', 102-string.len(data))
				simExtFinken_sendData(cfg.communication, sim_handle_all, data, cfg.payloadSize)
				local debugData = {fitnessVal = nil, x = nil, y = nil}
				debugData.fitnessVal, debugData.x, debugData.y = unpack(simUnpackFloats(data, 0, 3, 0)) 
				if (cfg.logLevel > 0 and debugData ) then simAddStatusbarMessage("fit: " .. debugData.fitnessVal .. " x: " .. debugData.x .. " y: " .. debugData.y) end
    		end
    		stepsSinceCommunication = 0 
		else
			stepsSinceCommunication = stepsSinceCommunication + 1
		end
	end
	
	--function customSense should be called in the vrep child scrip in the sense part
	--put here any custom function that should be called in the sensing phase (second main phase) of the simulation
	function self.customSense()
		--disable proximity sensor for pso-scene
		--self.sense()
    	if (cfg.communication < 0) then
			self.receiveAllData(0)
    	else
			local senderID = {}
			local timestamps = {}
			local receivedData = {}
			senderID, timestamps, receivedData =  simExtFinken_receiveData(cfg.communication)
			formatDataFitXY(senderID, receivedData)

			if (cfg.logLevel > 5 and senderID) then 
				for k, v in pairs(senderID) do
					simAddStatusbarMessage(" sender =" .. k .. ":" .. v) 
				end
			end
			if (cfg.logLevel > 5 and timestamps) then 
				for k, v in pairs(timestamps) do
					simAddStatusbarMessage(" timestamp =" .. k .. ":" .. v) 
				end
			end
			--@TODO log timestamps
			local timestamp = math.floor(simGetSimulationTime()*1000)
			msgTimestampLog[timestamp] = timestamps 
				
			--if (cfg.logLevel > 0 and formattedData) then simAddStatusbarMessage(": x=" .. formattedData[senderID[1]].x .. ' y=' .. formattedData[senderID[1]].y) end
    	end
		local newPosition = newTargetPosition()
		local cTargetPosition = simGetObjectPosition(self.getTarget(), -1)
		if (cfg.logLevel > 1 and newPosition) then simAddStatusbarMessage("newTargetPosition: x=" .. newPosition.x .. ' y=' .. newPosition.y ..' z=' .. cTargetPosition[3]) end
		
		simSetObjectPosition(self.getTarget(), -1, {newPosition.x, newPosition.y, cTargetPosition[3]}) 
	end

	--function customClean should be called in the vrep child scrip in the cleanup part
	--put here any custom function that should be called at the end of the simulation
	function self.customClean()
		local myTimeString = os.date("%Y%m%d%H%M%S")
		saveLog(positionLog, "Position", cfg.suffix, "finkenlogs/", myTimeString)
		saveLog(gBestLog, "gBest", cfg.suffix, "finkenlogs/", myTimeString)
		saveLog(lBestLog, "lBest", cfg.suffix, "finkenlogs/", myTimeString)
		saveLog(fitnessLog, "fitness", cfg.suffix, "finkenlogs/", myTimeString)
		if cfg.communication >= 0 then
			saveLog(msgTimestampLog, "msgArrival", cfg.suffix, "finkenlogs/", myTimeString)
		else
			saveLog(msgSenderLog, "msgArrival", cfg.suffix, "finkenlogs/", myTimeString)
		end
		saveConfig(cfg, "finkenlogs/", myTimeString)
	end
	return self
end


function finken.new()
	finkenCore.init()
	local macSuffix = simGetNameSuffix(nil)
	if not macSuffix then 
		macSuffix = 1 
	else 
		macSuffix = macSuffix + 2
	end
	simExtFinken_registerMac(0, "0A:AA:00:00:00:00:00:" .. string.format('%02X', macSuffix))
	local config = {suffix = string.format('%X', macSuffix)}
	--local config = {}
	return finken.init(finkenCore, config)
end

--[[
-- euclidian distance, for the lowest common dimension 
-- @return numer
--]]
function getEuclidianDist_minDimension(p, q)
	local sum = 0
	if table.getn(p) > table.getn(q) then
		for k, v in ipairs(q) do
			sum = sum + (p[k] - q[k])^2	
		end
	else
		for k, v in ipairs(p) do
			sum = sum + (p[k] - q[k])^2	
		end
	end
	return math.sqrt(sum)
end
--[[
-- vector addition with zero padding for dimensions
-- @return vector
--]]
function addVectors(p, q)
	local sum = {} 
	if table.getn(p) > table.getn(q) then
		sum = p
		for k, _ in ipairs(q) do
			sum[k] = sum[k] +  q[k]	
		end
	else
		sum = q
		for k, _ in ipairs(p) do
			sum[k] = sum[k] +  p[k]	
		end
	end
	return sum
end
--[[
--multiply vector with scalar
--@return vector
--]]
function multVectorScalar(p, n)
	local resultVector = {}	
	for k, _ in ipairs(p) do
		resultVector[k] = p[k] * n	
	end
	return resultVector
end

function finken.prepareConfig(config)
	local config = config or {}
	-- -1 for VREP-communication, otherwise use OMNeT instance $config.communication
	config.communication = config.communication or -1 
	config.communicationFrequentness = config.communicationFrequentness or 2 
	config.communicationRange = config.communicationRange or 5 
	config.payloadSize = config.payloadSize or 12
	config.logLevel = config.logLevel or 1 
	config.xMin = config.xMin or -12
	config.xMax = config.xMax or 12
	config.yMin = config.yMin or -12
	config.yMax = config.yMax or 12
	config.zInit = config.zInit or 0.9
	if not config.suffix then
		simAddStatusbarMessage("WARN: config.suffix is nil. It will be set to its default value. The suffix of an existing finken should be passed as an argument e.g. newFinken{suffix=''}, newFinken{suffix='1'}!")
		config.suffix = ""
	end
	-- b > a, wCohesion + wTarget = 1
	config.attractionRepulsion = config.attractionRepulsion or {}
	config.attractionRepulsion.a = config.attractionRepulsion.a or 0
	config.attractionRepulsion.b = config.attractionRepulsion.b or 10
	config.attractionRepulsion.c = config.attractionRepulsion.c or 3 
	config.attractionRepulsion.wCohesion = config.attractionRepulsion.wCohesion or 0.4
	config.attractionRepulsion.wTarget = config.attractionRepulsion.wTarget or 0.6
	config.problemFunction = config.problemFunction or ackley
	config.pso = config.pso or {}
	config.pso.cSocial = config.pso.cSocial or 1 
	config.pso.cCognitive = config.pso.cCognitive or 1
	return config
end

return finken
