require('math')

local IMU = {}
local objHandle = -1
local velocity = {0, 0, 0}
local orientation = {0, 0, 0}
local angularRate = {0, 0, 0}

function IMU.init(self, handle)
	objHandle = handle
	function self.step()
		-- get velocity
		velocity, angularRate = simGetObjectVelocity(objHandle)
		orientation = simGetObjectOrientation(objHandle, -1)

		sigma = simGetFloatSignal('imu:noiseMagnitude') or 0

		-- apply noise
		if sigma ~= 0 then
			for i, v in ipairs(velocity) do
				velocity[i] = v + pseudoNormalRandom(sigma)
			end
			--use lower noise values for angular velocity and orientation
			for i, ar in ipairs(angularRate) do
				angularRate[i] = ar + pseudoNormalRandom(sigma/180)
			end
			for i, o in ipairs(orientation) do
				orientation[i] = o + pseudoNormalRandom(sigma/180)
			end	
		end		
		--velocity x,y,z, roll, pitch (against world), yaw cannot be measured reliably in real copter, roll-, pitch-, yawrate
		simSetFloatSignal('imu:xVel', velocity[1])
		simSetFloatSignal('imu:yVel', velocity[2])
		simSetFloatSignal('imu:zVel', velocity[3])
		simSetFloatSignal('imu:roll', orientation[1])
		simSetFloatSignal('imu:pitch', orientation[2])
		simSetFloatSignal('imu:rollRate', angularRate[1])
		simSetFloatSignal('imu:pitchRate', angularRate[2])
		simSetFloatSignal('imu:yawRate', angularRate[3])

		--optional: pack multiple values in signal
	end

	-- Generates random numbers that are approximately normally distributed, with mean 0 and standard deviation ~sigma
	function pseudoNormalRandom(sigma)
		sigma = sigma or 1
		-- subtract from 1 because result can be 0, and we want to take the logarithm
		local r = 1 - math.random()
		-- devide by 1.81 to get approximately standard deviation 1
		return sigma * math.log((1-r)/r) / 1.81
	end

	simAddStatusbarMessage('initialized IMU')
	return self
end

return IMU