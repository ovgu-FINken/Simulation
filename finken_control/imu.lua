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

		--TODO: add noise

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

	return self
	simAddStatusbarMessage('initialized IMU')
end

return IMU