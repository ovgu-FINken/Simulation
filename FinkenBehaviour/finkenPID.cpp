#include "finkenPID.h"

finkenPID::finkenPID() {
  p = 0;
  i = 0;
  d = 0;
  e = 0;
  e_prev = 0;
  e_sum = 0;
}

int sign(float x) {
  return (x<0) ? -1 : 1;
}

void finkenPID::initPID(float newP, float newI, float newD){
  p = newP;
  i = newI;
  d = newD;
  e = 0;
  e_prev = 0;
  e_sum = 0;
}

float finkenPID::step(float newE, float deltaT){
  e_prev = e;
  e = newE;
  if (sign(newE) == sign(e_prev)){
    e_sum = e_sum + newE * deltaT;
  }
  else {
    e_sum = 0;
  }
  return (p*e + d*((e-e_prev)/deltaT) + i*e_sum);
}

int main(){
	return 0;
}
