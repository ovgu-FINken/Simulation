cplusplus {{
	#include <Coord.h>

}};

class noncobject Coord;
// only (x,y,z) position is supported 

message vrepCoords {
	Coord position;
}
