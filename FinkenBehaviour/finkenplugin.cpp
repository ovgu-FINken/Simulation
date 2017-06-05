#include <vrepplugin.h>
#include <log.h>
#include "finken.h"
#include "v_repLib.h"
#include <unistd.h>
#include <iostream>
#include <positionsensor.h>
#include "finkencontrol.h"

extern float execution_step_size;
static std::vector<std::unique_ptr<Finken>> allFinken;
class FinkenPlugin: public VREPPlugin {
  public:

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
        allFinken.push_back(std::move(buildFinken()));

        simAddStatusbarMessage("finken finished");


        return NULL;
    }

    void* action(int* auxiliaryData,void* customData,int* replyData)
    {   /*simple test code, ignore for now
        std::vector<float> f = {1,2,3,4};
        std::vector<float> ff = {1,2,3};
        std::vector<float> vforce = {0,0,1.5};

        int i =0;
        PositionSensor ps = PositionSensor(allFinken.at(0)->handle);
        ps.get(f);
        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << '\n';

        allFinken.at(0)->getSensors().at(0)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(1)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(2)->get(f, i, ff);
        allFinken.at(0)->getSensors().at(3)->get(f, i, ff);

        std::cout << f.at(0) << "   " << f.at(1) << f.at(2) << f.at(3) << '\n';
        std::cout << i << '\n';
        std::cout << simGetObjectName(i) <<'\n';
        std::cout << '\n';

        for(int i=0; i<4; i++){
            allFinken.at(0)->getRotors().at(i)->set(vforce, vtorque);
        }
        */
        execution_step_size = simGetSimulationTimeStep();
        std::vector<float> vtorque = {0,0,0};
        std::vector<float> vforce = {0,0,0};
        float* buffer = steps(allFinken.at(0).get());
        for (int i = 0; i<4; i++) {
            vforce[2] = buffer[i];
            allFinken.at(0)->getRotors().at(i)->set(vforce, vtorque);

        }
        return NULL;
    }

} plugin;
