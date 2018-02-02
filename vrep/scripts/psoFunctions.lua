--@TODO introduce global offset variable to arbitrarily shift function center

--[[
--rosenbrock function with fixed parameters
--@return number rosenbrock
--]]
function rosenbrock(x, y)
	local a = 1
	local b = 100
	local rosenbrock = (a - x)^2 + b * (y - x^2)^2
	return rosenbrock
end


--[[
--ackley function with fixed parameters
--@return number ackley
--]]
function ackley(x,y)
	local a = 20
	local b = 0.2
	local c = 2*math.pi
	local ackley = -a * math.exp(-b * math.sqrt(0.5 * (x^2 + y^2))) - math.exp(0.5 * (math.cos(c * x) + math.cos(c * y))) + math.exp(1) + a 
	return ackley
end
