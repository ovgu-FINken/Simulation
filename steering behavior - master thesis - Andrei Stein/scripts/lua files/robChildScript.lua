-- Check if the required plugin is there:
moduleName=0
moduleVersion=0
index=0
bubbleRobModuleNotFound=true
while moduleName do
    moduleName,moduleVersion=simGetModuleName(index)
    if (moduleName=='BubbleRob') then
        bubbleRobModuleNotFound=false
    end
    index=index+1
end
if (bubbleRobModuleNotFound) then
    simDisplayDialog('Error','BubbleRob plugin was not found. (v_repExtBubbleRob.dll)&&nSimulation will not run properly',sim_dlgstyle_ok,true,nil,{0.8,0,0,0,0,0},{0.5,0,0,1,1,1})
else
    local jointHandles={simGetObjectHandle('leftMotor'),simGetObjectHandle('rightMotor')}
    local sensorHandle=simGetObjectHandle('sensingNose')
    local robHandle=simExtBubble_create(jointHandles,sensorHandle,{0.5,0.25})
    if robHandle>=0 then
        simExtBubble_start(robHandle,20) -- control happens here
        simExtBubble_stop(robHandle)
        simExtBubble_destroy(robHandle)
    end
end
