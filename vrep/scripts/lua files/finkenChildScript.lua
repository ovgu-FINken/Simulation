-- DO NOT WRITE CODE OUTSIDE OF THE if-then-end SECTIONS BELOW!!

if (sim_call_type==sim_childscriptcall_initialization) then
-- Make sure we have version 2.4.13 or above (the particles are not supported otherwise)
    v=simGetInt32Parameter(sim_intparam_program_version)
    if (v<20413) then
        simDisplayDialog('Warning','The propeller model is only fully supported from V-REP version 2.4.13 and above.&&nThis simulation will not run as expected!',sim_dlgstyle_ok,false,'',nil,{0.8,0,0,0,0,0})
    end

    finken = require("finken")
    myFinken = finken.new()
    myFinken.customInit()

    finken_base_handle=simGetObjectHandle('SimFinken_base')
    finken_handle=simGetObjectAssociatedWithScript(sim_handle_self)

    -- Detatch the manipulation sphere:
    targetObj=simGetObjectHandle('SimFinken_target')
    simSetObjectParent(targetObj,-1,true)


    -- This control algo was quickly written and is dirty and not optimal. It just serves as a SIMPLE example


    particlesAreVisible=simGetScriptSimulationParameter(sim_handle_self,'particlesAreVisible')
    simSetScriptSimulationParameter(sim_handle_tree,'particlesAreVisible',tostring(particlesAreVisible))
    simulateParticles=simGetScriptSimulationParameter(sim_handle_self,'simulateParticles')
    simSetScriptSimulationParameter(sim_handle_tree,'simulateParticles',tostring(simulateParticles))

    propellerScripts={-1,-1,-1,-1}
    for i=1,4,1 do
        propellerScripts[i]=simGetScriptHandle('SimFinken_rotor_respondable'..i)
    end


    particlesTargetVelocities={0,0,0,0}





    fakeShadow=simGetScriptSimulationParameter(sim_handle_self,'fakeShadow')
    if (fakeShadow) then
        shadowCont=simAddDrawingObject(sim_drawing_discpoints+sim_drawing_cyclic+sim_drawing_25percenttransparency+sim_drawing_50percenttransparency+sim_drawing_itemsizes,0.2,0,-1,1)
    end


    -- Put some initialization code here

    -- Make sure you read the section on "Accessing general-type objects programmatically"
    -- For instance, if you wish to retrieve the handle of a scene object, use following instruction:
    --
    -- handle=simGetObjectHandle('sceneObjectName')
    --
    -- Above instruction retrieves the handle of 'sceneObjectName' if this script's name has no '#' in it
    --
    -- If this script's name contains a '#' (e.g. 'someName#4'), then above instruction retrieves the handle of object 'sceneObjectName#4'
    -- This mechanism of handle retrieval is very convenient, since you don't need to adjust any code when a model is duplicated!
    -- So if the script's name (or rather the name of the object associated with this script) is:
    --
    -- 'someName', then the handle of 'sceneObjectName' is retrieved
    -- 'someName#0', then the handle of 'sceneObjectName#0' is retrieved
    -- 'someName#1', then the handle of 'sceneObjectName#1' is retrieved
    -- ...
    --
    -- If you always want to retrieve the same object's handle, no matter what, specify its full name, including a '#':
    --
    -- handle=simGetObjectHandle('sceneObjectName#') always retrieves the handle of object 'sceneObjectName'
    -- handle=simGetObjectHandle('sceneObjectName#0') always retrieves the handle of object 'sceneObjectName#0'
    -- handle=simGetObjectHandle('sceneObjectName#1') always retrieves the handle of object 'sceneObjectName#1'
    -- ...
    --
    -- Refer also to simGetCollisionhandle, simGetDistanceHandle, simGetIkGroupHandle, etc.
    --
    -- Following 2 instructions might also be useful: simGetNameSuffix and simSetNameSuffix

end


if (sim_call_type==sim_childscriptcall_actuation) then
    s=simGetObjectSizeFactor(finken_base_handle)
    pos=simGetObjectPosition(finken_base_handle,-1)
    if (fakeShadow) then
        itemData={pos[1],pos[2],0.002,0,0,1,0.2*s}
        simAddDrawingObjectItem(shadowCont,itemData)
    end


    myFinken.customRun()

    local particlesTargetVelocities = myFinken.step()

    -- Send the desired motor velocities to the 4 rotors:
    for i=1,4,1 do
        simSetScriptSimulationParameter(propellerScripts[i],'particleVelocity',particlesTargetVelocities[i])
    end

end


if (sim_call_type==sim_childscriptcall_sensing) then
    myFinken.customSense()
    local sensor_distances = myFinken.sense()

end


if (sim_call_type==sim_childscriptcall_cleanup) then
    simRemoveDrawingObject(shadowCont)
    simFloatingViewRemove(floorView)
    simFloatingViewRemove(frontView)
    myFinken.customClean()
end
