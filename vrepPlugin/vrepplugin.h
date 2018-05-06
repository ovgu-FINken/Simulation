#pragma once

#include <string>
#include <vector>

/** Vector storing copter handles. @ref simCopters */
 
extern std::vector<std::pair<int,int>> simCopters;

/**
 * Base vrepplugin class. Finkenplugin inherits from this class
 */
class VREPPlugin
{
    private:
        static VREPPlugin* instance;

    public:
        static VREPPlugin& getInstance();
        VREPPlugin();
        virtual ~VREPPlugin();
        VREPPlugin& operator=(const VREPPlugin&) = delete;
        VREPPlugin(const VREPPlugin&) = delete;
        virtual unsigned char version() const=0;
        virtual const std::string name() const=0;
        virtual bool load();
        virtual bool unload();
        virtual void* refreshDialog(int* auxiliaryData,void* customData,int* replyData);
        virtual void* menuItemSelected(int* auxiliaryData,void* customData,int* replyData);
        virtual void* sceneContentChange(int* auxiliaryData,void* customData,int* replyData);
        virtual void* instancePass(int* auxiliaryData,void* customData,int* replyData);
        virtual void* instanceSwitch(int* auxiliaryData,void* customData,int* replyData);
        virtual void* mainScriptCall(int* auxiliaryData,void* customData,int* replyData);
        virtual void* simStart(int* auxiliaryData,void* customData,int* replyData);
        virtual void* simEnd(int* auxiliaryData,void* customData,int* replyData);
        virtual void* sceneLoad(int* auxiliaryData,void* customData,int* replyData);
        virtual void* open(int* auxiliaryData,void* customData,int* replyData);
        virtual void* action(int* auxiliaryData,void* customData,int* replyData);
        virtual void* close(int* auxiliaryData,void* customData,int* replyData);
        virtual void* save(int* auxiliaryData,void* customData,int* replyData);
        virtual void* render(int* auxiliaryData,void* customData,int* replyData);
        virtual void* broadcast(int* auxiliaryData,void* customData,int* replyData);
        virtual void* handleOtherMessage(int message, int* auxiliaryData,void* customData,int* replyData);
};
