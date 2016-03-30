 -- DO NOT WRITE CODE OUTSIDE OF THE if-then-end SECTIONS BELOW!! (unless the code is a function definition)
 --
 if (sim_call_type==sim_childscriptcall_initialization) then
	FINkenHandleList = {}
	-- insert FINken object handles here
	table.insert(FINkenHandleList, simGetObjectHandle("Cuboid#"))
	table.insert(FINkenHandleList, simGetObjectHandle("Cuboid0#"))
	
	-- get parameters
 	scriptHandle=sim_handle_self

 	numSegments   = simGetScriptSimulationParameter(scriptHandle,"numSegments")
 	wallWidth     = simGetScriptSimulationParameter(scriptHandle,"wallWidth")
	segmentMass   = simGetScriptSimulationParameter(scriptHandle,"segmentMass")
 	jointForce    = simGetScriptSimulationParameter(scriptHandle,"jointForce")
 	threshold     = simGetScriptSimulationParameter(scriptHandle,"threshold")
	friction      = simGetScriptSimulationParameter(scriptHandle,"friction")
	maxAmplitude  = simGetScriptSimulationParameter(scriptHandle,"maxAmplitude")
	PID_P         = simGetScriptSimulationParameter(scriptHandle,"PID_P")
	PID_I         = simGetScriptSimulationParameter(scriptHandle,"PID_I")
	PID_D         = simGetScriptSimulationParameter(scriptHandle,"PID_D")
 	segmentWidth  = wallWidth / numSegments

	-- get handles
	wallHandle=simGetObjectAssociatedWithScript(sim_handle_self)
 	children = simGetObjectsInTree(wallHandle, sim_object_shape_type) -- also includes all the Hinge objects...
 	wallSegments = {} -- ...so we filter them and put them here
 	wallJoints = {}   -- ...and their parents here
	
	bar = simCreatePureShape(2, 25, {wallWidth, 0.01, 0.01}, 0)
	simSetObjectPosition(bar, wallHandle, {0.0, 0.0, 0.01})
	simSetObjectOrientation(bar, wallHandle, {0.0, 0.0, 0.0})
		
	simSetObjectParent(bar, wallHandle, true)
 													
	startingPos = {-wallWidth / 2.0, 0.0, 0.0}
	pi = 3.141592654 -- needed for setting orientation
 	for i = 0, numSegments-1, 1.0 do
 		jointPos = {}
 		jointPos[1] = startingPos[1] + (segmentWidth * i)
 		jointPos[2] = startingPos[2]
 		jointPos[3] = startingPos[3]
		jointHandle = simCreateJoint(sim_joint_revolute_subtype, sim_jointmode_force, 1)
		simSetObjectPosition(jointHandle, wallHandle, jointPos)
 		simSetObjectOrientation(jointHandle, wallHandle, {0.0, 0.5*pi, 0.0})
		simSetObjectIntParameter(jointHandle, 2000, 1)

		local p = simGetObjectSpecialProperty(jointHandle)
		p = simBoolOr16(p, sim_objectspecialproperty_renderable)
 		p = simBoolOr16(p, sim_objectspecialproperty_measurable)
		simSetObjectSpecialProperty(jointHandle, p)

		local segmentHandle = simCreatePureShape(0, 9, {segmentWidth*0.9, 0.05, 1.0}, segmentMass)
 		simSetObjectPosition(segmentHandle, jointHandle, {0.5,0.0,0.0})
 		simSetObjectOrientation(segmentHandle, jointHandle, {0.0, -0.5*pi, 0.0})
		p = simGetObjectSpecialProperty(segmentHandle)
		p = simBoolOr16(p, sim_objectspecialproperty_collidable)
 		p = simBoolOr16(p, sim_objectspecialproperty_renderable)
		p = simBoolOr16(p, sim_objectspecialproperty_measurable)
 		simSetObjectSpecialProperty(segmentHandle, p)
		simSetObjectParent(jointHandle, bar, true)
		simSetObjectParent(segmentHandle, jointHandle, true)
 		table.insert(wallJoints, jointHandle)
 		table.insert(wallSegments, segmentHandle)		
	end		
end

if (sim_call_type==sim_childscriptcall_actuation) then
	for key1, segmentHandle in pairs(wallSegments) do
		jointHandle = wallJoints[key1]
		jointPosition = simGetJointPosition(jointHandle)
		segmentPos = simGetObjectPosition(segmentHandle, -1)

		local distance = 2*threshold -- arbitrary default value over threshold
		
		-- get smallest distance to a FINken
		for key2, FINkenHandle in pairs(FINkenHandleList) do
			FINkenPos = simGetObjectPosition(FINkenHandle, -1)
			difX = FINkenPos[1] - segmentPos[1]
			difY = FINkenPos[2] - segmentPos[2]
			-- calculate manhatten distance to find out whether we even need to calculate the euclidean distance 
			manh_dist = math.abs(difX) + math.abs(difY)
			culling = ( manh_dist < threshold * 1.5 )
			if (culling) then
				local result, dist=simCheckDistance(segmentHandle, FINkenHandle, 0.0)
				if(dist[7] < distance) then
					distance = dist[7]
				end
			end
		end

		-- set PID if distance is smaller than threshold
		if (distance < threshold) then
			-- configure PID-controller
			simSetObjectIntParameter(jointHandle, 2001, 1)
			simSetObjectIntParameter(jointHandle, 2002, 1)
			simSetObjectIntParameter(jointHandle, 2003, 2)
			simSetObjectIntParameter(jointHandle, 2004, 1)
			simSetJointForce(jointHandle, jointForce)
			-- invert and normalize distance (0 = threshold distance, 1 = zero distance)
			local inv_dist = (threshold - distance) / threshold
			-- apply formula
			local x = inv_dist
			local target_pos = 3.3*x*x*x - 7*x*x + 4.8*x 
			simSetJointTargetPosition(jointHandle, target_pos * maxAmplitude)
		else -- otherwise deactivate PID and apply friction
			simSetObjectIntParameter(jointHandle, 2001, 0)
			simSetJointForce(jointHandle, friction)
		end
	end
end
