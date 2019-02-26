/** 
 * @file rotor.cpp 
 * \class Rotor
 * \brief Implementation of a force sensor as a rotor
 */


#pragma once
#include <vector>
#include <memory>
#include <iostream>
class Rotor
{
public:
    /** Basic constructor.
     * @param rHandle the handle of the sensor in V-REP 
     */
    Rotor(int rHandle, std::string position);


    int handle; ///< Handle to access the sensor in V-REP
    std::string position; ///< position (NE, NW, SE, SW) of the rotor
    /**
     * Function to set the force and torque fvalues or the rotor.
     * 
     * @param force The force to be applied.
     * @param torque The torque to be applied.
     * 
     * See the <a href="http://www.coppeliarobotics.com/helpFiles/en/regularApi/simAddForceAndTorque.htm">V-REP API</a> for more info. 
     */
    void set(const std::vector<float> &force, const std::vector<float> &torque);

    bool operator<(const Rotor& rhs) {
    if(this == std::addressof(rhs)) {
        std::cout << "comparing the same rotor with itself, something wrent wrong!" << std::endl;
        return false;   
    }
    else if(this->position == rhs.position){
        throw std::runtime_error("Two rotor objects at the same position!");
    }
    else if (this->position == "NE" || rhs.position == "NW"){
        return true;
    }
    else if (rhs.position == "NE" || this->position == "NW"){
        return false;
    }
    else if (this->position == "SE"){
        return true;
    }
    else {
        return false;
    }
}
};

