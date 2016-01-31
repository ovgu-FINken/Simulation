local finkenPID= {}

local p = 0
local i = 0
local d = 0

local e = 0
local e_prev = 0
local e_sum = 0

local function finkenPID.init(self, newP, newI, newD)
	self.p = newP
	self.i = newI
	self.d = newD

	self.e = 0
	self.e_prev = 0
	self.e_sum = 0
end

local function step(self, newE, deltat)
	self.e_prev = self.e
	self.e = newE
	self.e_sum = self.e_sum + newE
	
	local correctionVal = self.p*self.e + self.d*((self.e-self.e_prev)/deltat) + self.i*self.e_sum
	return correctionVal
end

local function printValues(self)
	simAddStatusbarMessage("error: "..self.e)
	simAddStatusbarMessage("previous error: "..self.e_prev)
	simAddStatusbarMessage("accumulated error: "..self.e_sum)
	simAddStatusbarMessage("p: "..self.p)
	simAddStatusbarMessage("i: "..self.i)
	simAddStatusbarMessage("d: "..self.d)

end

local methods = {
	init = init,
	step = step,
	printValues = printValues,
}

local function new()
	return setmetatable({}, {__index = methods})
end

return {new = new}
