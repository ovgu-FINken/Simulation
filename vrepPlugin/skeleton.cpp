/**
 * @file skeleton.cpp
 * \brief provides the basic functionality for communication with the running vrep Simulation"
 */

#include <vrepplugin.h>
#include <v_repLib.h>
#include <scriptFunctionData.h>
#include <boost/filesystem.hpp>
#include <iostream>
#include <finken.h>

LIBRARY vrepLib;

#ifdef _WIN32
const char* libName="libv_rep.dll";
#else
const char* libName="libv_rep.so";
#endif

/**
 * \anchor simFinken
 * Vector for all available (e.g. present in the plugin) copters
 */
std::vector<std::unique_ptr<Finken>> simFinken;



#define LUA_REGISTER_COMMAND "simExtPaparazzi_register"

const int inArgs_REGISTER[]={
    //4 arguments: handle, aircraftID, rotor count, sonar count 
    4,
    sim_script_arg_int32,0,
    sim_script_arg_int32,0,
    sim_script_arg_int32,0,
    sim_script_arg_int32,0,

};
/**
 * Function to register any FINken present in the vrep scene with the plugin.
 * Every copter needs to call this in its child script to be accesible by the plugin.
 * Stores the handle, aricraftID, rotor and sonar counts in \ref simFinken
 *
 */
void LUA_REGISTER_CALLBACK(SScriptCallBack* cb)
{   CScriptFunctionData D;
    simAddStatusbarMessage("lua callback");
    std::cout << "finken registering" << '\n';
    bool success = false;
    if (D.readDataFromStack(cb->stackID,inArgs_REGISTER,inArgs_REGISTER[0],LUA_REGISTER_COMMAND))
    {   
        std::vector<CScriptFunctionDataItem>* inData=D.getInDataPtr();
        int handle = inData->at(0).int32Data[0];
        int AC_ID = inData->at(1).int32Data[0];
        int rotorCount = inData->at(2).int32Data[0];
	int sonarCount = inData->at(3).int32Data[0];
        simFinken.emplace_back(new Finken(handle, AC_ID, rotorCount, sonarCount));        
        success = true;
    }
    D.pushOutData(CScriptFunctionDataItem(success));
    D.writeDataToStack(cb->stackID);
    std::cout << "finken done registering" << '\n';

}


/**
* @name vrep entry points
* Required entry points for vrep plugin functions. Vrep Doc:
* http://www.coppeliarobotics.com/helpFiles/en/plugins.htm
* @{ */
extern "C" unsigned char v_repStart(void* reservedPointer,int reservedInt)
{
  VREPPlugin& plugin=VREPPlugin::getInstance();

    auto libPath=boost::filesystem::current_path();
    libPath/=libName;
    vrepLib=loadVrepLibrary(libPath.c_str());
    if (vrepLib==NULL)
    {
        std::cout << "Error, could not find or correctly load the V-REP library. Cannot start " << plugin.name() << std::endl;
        return(0);
    }
    if (getVrepProcAddresses(vrepLib)==0)
    {
        std::cout << "Error, could not find all required functions in the V-REP library. Cannot start " << plugin.name() << std::endl;
        unloadVrepLibrary(vrepLib);
        return(0);
    }
    int vrepVer;
    simGetIntegerParameter(sim_intparam_program_version,&vrepVer);
    if (vrepVer<20604)
    {
        std::cout << "Sorry, your V-REP copy is somewhat old. Cannot start " << plugin.name() << std::endl;
        unloadVrepLibrary(vrepLib);
        return(0);
    }


    std::string s = "simExtPaparazzi_register@" + plugin.name();
    const char* cs;
    cs = s.c_str();
    std::string t = "boolean result=simExtPaparazzi_register(number copterHandle, number AC_ID, number rotorCount, number sonarCount)";
    const char* ts;
    ts = t.c_str();
    simRegisterScriptCallbackFunction(cs, ts ,LUA_REGISTER_CALLBACK);

    simLockInterface(1);

  if(!plugin.load())
    std::cout << "Error loading " << plugin.name() << std::endl;

    simLockInterface(0);
    return plugin.version();
}

extern "C" void v_repEnd()
{
  VREPPlugin& plugin=VREPPlugin::getInstance();
  if(!plugin.unload())
    std::cout << "Error unloading " << plugin.name() << std::endl;
    unloadVrepLibrary(vrepLib);
}

extern "C" void* v_repMessage(int message,int* auxiliaryData,void* customData,int* replyData)
{
  simLockInterface(1);
    static bool refreshDlgFlag=true;
    int errorModeSaved;
    simGetIntegerParameter(sim_intparam_error_report_mode,&errorModeSaved);
    simSetIntegerParameter(sim_intparam_error_report_mode,sim_api_errormessage_ignore);
    void* retVal=NULL;

  VREPPlugin& plugin=VREPPlugin::getInstance();

  switch(message)
  {
    case(sim_message_eventcallback_refreshdialogs):
        refreshDlgFlag=true;
        retVal=plugin.refreshDialog(auxiliaryData, customData, replyData);
        break;
    case(sim_message_eventcallback_menuitemselected):
        retVal=plugin.menuItemSelected(auxiliaryData, customData, replyData);
        break;
    case(sim_message_eventcallback_instancepass):
    {
      int flags=auxiliaryData[0];
      bool sceneContentChanged=((flags&(1+2+4+8+16+32+64+256))!=0);

      if (sceneContentChanged)
      {
        refreshDlgFlag=true;
        retVal=plugin.sceneContentChange(auxiliaryData, customData, replyData);
        break;
      }

      retVal=plugin.instancePass(auxiliaryData, customData, replyData);
      break;
    }

    case(sim_message_eventcallback_mainscriptabouttobecalled):
      retVal=plugin.mainScriptCall(auxiliaryData, customData, replyData);
      break;
    case(sim_message_eventcallback_simulationabouttostart):
      retVal=plugin.simStart(auxiliaryData, customData, replyData);
      break;
    case(sim_message_eventcallback_simulationended):
      retVal=plugin.simEnd(auxiliaryData, customData, replyData);
      break;
    case(sim_message_eventcallback_moduleopen):
      if(!customData||plugin.name()==reinterpret_cast<const char*>(customData))
        retVal=plugin.open(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_modulehandle):
      if(!customData||plugin.name()==reinterpret_cast<const char*>(customData))
        retVal=plugin.action(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_moduleclose):
      if(!customData||plugin.name()==reinterpret_cast<const char*>(customData))
        retVal=plugin.close(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_instanceswitch):
      retVal=plugin.instanceSwitch(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_broadcast):
      retVal=plugin.broadcast(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_scenesave):
      retVal=plugin.save(auxiliaryData, customData, replyData);
      break;

    case(sim_message_eventcallback_sceneloaded):
      retVal=plugin.sceneLoad(auxiliaryData, customData, replyData);
      break;    

    case(sim_message_eventcallback_guipass):
      if(refreshDlgFlag)
      {
        refreshDlgFlag=false;
        retVal=plugin.render(auxiliaryData, customData, replyData);
      }
      break;
    default:
      retVal=plugin.handleOtherMessage(message, auxiliaryData, customData, replyData);
      break;
  }

    simSetIntegerParameter(sim_intparam_error_report_mode,errorModeSaved);
  simLockInterface(0);
    return(retVal);
}
/**  @} */

