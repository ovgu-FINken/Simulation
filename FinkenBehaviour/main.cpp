#include <iostream>
#include <heightSensor.h>
#include <sensor.h>
#include <positionsensor.h>
#include <attitudeSensor.h>


heightSensor hs = heightSensor(-1);
positionSensor ps = positionSensor(-2);
attitudeSensor as = attitudeSensor(-3);

int main(int argc, char *argv[])
{

   std::vector<float> dVector = {-1,-1,-1};
   std::vector<float> dSurface ={-1,-1,-1};
   std::vector<float> dPosition ={-1,-1,-1};
   std::vector<float> dAngles ={-1,-1,-1};
   int dHandle = -1;

   dHandle = hs.getHandle();


   hs.get(dVector, dHandle, dSurface);
   std::cout << dHandle << '\n';
   std::cout << dVector[0] << "  " << dVector[1] << "  " << dVector[2] << '\n';
   std::cout << dSurface[0] << "  " << dSurface[1] << "  " << dSurface[2] << '\n';


   ps.get(dPosition);
   std::cout << dPosition[0] << "  " << dPosition[1] << "   " << dPosition[2] << '\n';

   as.get(dAngles);
   std::cout << dAngles[0] << "  " << dAngles[1] << "   " << dAngles[2] << '\n';
}
