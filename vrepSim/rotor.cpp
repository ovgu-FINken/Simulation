#include "rotor.h"
#include "v_repLib.h"

Rotor::Rotor(int rHandle) : handle(rHandle){}


void Rotor::set(const std::vector<float> &force, const std::vector<float> &torque) {
    simAddForceAndTorque(this->handle, &force[0], &torque[0]);

}
