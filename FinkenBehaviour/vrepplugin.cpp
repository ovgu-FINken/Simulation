#include <vrepplugin.h>
#include <iostream>

VREPPlugin& VREPPlugin::getInstance()
{
    if(!instance)
        std::cout << "No plugin registered!" << std::endl;
    return *instance;
}

VREPPlugin::VREPPlugin()
{
    instance=this;
}

VREPPlugin::~VREPPlugin()
{
    instance=NULL;
}

bool VREPPlugin::load()
{
    return true;
}

bool VREPPlugin::unload()
{
    return true;
}

void* VREPPlugin::refreshDialog(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::menuItemSelected(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::sceneContentChange(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::instancePass(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::instanceSwitch(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::mainScriptCall(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::simStart(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::simEnd(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::open(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::action(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::close(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::save(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::render(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::broadcast(int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

void* VREPPlugin::handleOtherMessage(int message, int* auxiliaryData,void* customData,int* replyData)
{
    return NULL;
}

VREPPlugin* VREPPlugin::instance;
