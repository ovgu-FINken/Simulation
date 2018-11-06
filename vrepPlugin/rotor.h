/** 
 * @file rotor.cpp 
 * \class Rotor
 * \brief Implementation of a force sensor as a rotor
 */


#pragma once
#include <vector>

class Rotor
{
public:
    /** Basic constructor.
     * @param rHandle the handle of the sensor in V-REP 
     */
    Rotor(int rHandle);


    int handle; ///< Handle to access the sensor in V-REP

    /**
     * Function to set the force and torque fvalues or the rotor.
     * 
     * @param force The force to be applied.
     * @param torque The torque to be applied.
     * 
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simAddForceAndTorque.htm">V-REP API</a> for more info. 
     */
    void set(const std::vector<float> &force, const std::vector<float> &torque);
};

