#pragma once

class finkenPID {
public:
	finkenPID();
	float p, i, d;
	float e;
	float e_prev, e_sum;
	void initPID(float newP, float newI, float newD);
	float step(float newE, float deltaT);
};
