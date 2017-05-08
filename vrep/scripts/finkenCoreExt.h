
#include <string>
#include "v_repLib.h"
#include <cmath>
#include <stdlib.h>
#include "scriptFunctionData.h"
#include "finkenPID.h"
#include <array>

static const int FINKEN_SENSOR_COUNT = 4;
static const std::string SENSOR_ORIENTATION[FINKEN_SENSOR_COUNT]  = {"FRONT", "LEFT", "BACK", "RIGHT"};
