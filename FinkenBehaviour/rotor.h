#ifndef ROTOR_H
#define ROTOR_H
#include <vector>

class Rotor
{
public:
    Rotor(int rHandle);
    int handle;
    void set(std::vector<float> &force, std::vector<float> &torque);
};

#endif // ROTOR_H
