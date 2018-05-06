local finkenPID= {}

function finkenPID.new()
	local self = {}
	local p = 0
	local i = 0
	local d = 0
	local e = 0
	local e_prev = 0
	local e_sum = 0

	local function sign(x)
		return (x<0 and -1) or 1
	end


	function self.init(newP, newI, newD)
		p = newP
		i = newI
		d = newD
		e = 0
		e_prev = 0
		e_sum = 0
	end
	
 	function self.step(newE, deltat)
		e_prev = e
		e = newE
		if sign(newE) == sign(e_prev) then
			e_sum = e_sum + newE * deltat
		else
			e_sum = 0
		end
		return (p*e + d*((e-e_prev)/deltat) + i*e_sum)
	end

	function self.printValues()
		simAddStatusbarMessage("error: "..e)
		simAddStatusbarMessage("previous error: "..e_prev)
		simAddStatusbarMessage("accumulated error: "..e_sum)
		simAddStatusbarMessage("p: "..p)
		simAddStatusbarMessage("i: "..i)
		simAddStatusbarMessage("d: "..d)
	end
	return self
end
return finkenPID
