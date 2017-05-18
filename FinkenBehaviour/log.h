#pragma once

#include <ostream>
#include <string>

class Log
{
    private:
        static std::ostream* mOutStream;
        static std::ostream* mErrStream;
        static std::string mName;
    public:
        Log() = delete;
        static const std::ostream& outStream() {return *mOutStream;}
        static void outStream(std::ostream& stream){mOutStream=&stream;}
        static const std::ostream& errStream() {return *mErrStream;}
        static void errStream(std::ostream& stream){mErrStream=&stream;}
        static const std::string& name() {return mName;}
        static void name(const std::string& name) {mName=name;}
        static std::ostream& out(){
          return *mOutStream << "[" << name() << "] ";
        }
        static std::ostream& err(){
          return *mErrStream << "[" << name() << "] ";
        }
};
