#include <log.h>

#include <iostream>

using namespace std;

ostream* Log::mOutStream=&cout;
ostream* Log::mErrStream=&cerr;
string   Log::mName="Unknown";
