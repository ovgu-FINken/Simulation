#ifndef ROTOR_H
#define ROTOR_H
#include <vector>

class Rotor
{
public:
    Rotor(int rHandle);
    int handle;
    void set(const std::vector<float> &force, const std::vector<float> &torque);
};

#endif // ROTOR_H
