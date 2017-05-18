#include <vrepplugin.h>
#include <log.h>
#include "finken.h"
#include "v_repLib.h"
#include <unistd.h>
#include <iostream>
#include <positionsensor.h>

class FinkenPlugin: public VREPPlugin {
  public:
    Finken finken;
    FinkenPlugin() {}
    FinkenPlugin& operator=(const FinkenPlugin&) = delete;
    FinkenPlugin(const FinkenPlugin&) = delete;
    virtual ~FinkenPlugin() {}
    virtual unsigned char version() const { return 1; }
    virtual bool load() {
      Log::name(name());
      Log::out() << "loadeda" << std::endl;
      return true;
    }
    virtual bool unload() {

      Log::out() << "unloaded" << std::endl;
      return true;
    }
    virtual const std::string name() const {
      return "Finken Plugin";
    }

    void* simStart(int* auxiliaryData,void* customData,int* replyData)
    {

        simAddStatusbarMessage("finken in creation");
        buildFinken(finken);
        simAddStatusbarMessage("finken finished");



        return NULL;
    }

    void* action(int* auxiliaryData,void* customData,int* replyData)
    {
        std::vector<float> f = {1,2,3,4};
        std::vector<float> ff = {1,2,3};
        int i =0;
        PositionSensor ps = PositionSensor(finken.handle);
        ps.get(f);
        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << '\n';

        finken.getSensors().at(0)->get(f, i, ff);
        finken.getSensors().at(1)->get(f, i, ff);
        finken.getSensors().at(2)->get(f, i, ff);
        finken.getSensors().at(3)->get(f, i, ff);

        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << f.at(3) << '\n';
        std::cout << i << '\n';
        std::cout << simGetObjectName(i) <<'\n';
        /*
        std::cout << ff.at(0) << "   " << ff.at(1) << '\n';
        std::cout << i <<'\n';
        finken.getSensors().at(1)->get(f, i, ff);
        std::cout << f.at(0) << "   " << f.at(1) << '\n';
        std::cout << ff.at(0) << "   " << ff.at(1) << '\n';
        std::cout << i <<'\n';
        */
        return NULL;
    }

} plugin;
