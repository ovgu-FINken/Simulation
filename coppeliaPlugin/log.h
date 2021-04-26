/** Basic logging class */

#pragma once

#include <ostream>
#include <string>

class Log {

    private:
        static std::ostream* mOutStream; ///< Normal outstream
        static std::ostream* mErrStream; ///< Error outstream
        static std::string mName;        ///< Name of the logging object to be shown in messages

    public:
        Log() = delete;

        static const std::ostream& outStream() {
          return *mOutStream;
        }

        static void outStream(std::ostream& stream) {
          mOutStream=&stream;
        }

        static const std::ostream& errStream() {
          return *mErrStream;
        }

        static void errStream(std::ostream& stream) {
          mErrStream=&stream;
        }

        static const std::string& name() {
          return mName;
        }

        /** Sets the name to be shown in log messages */
        static void name(const std::string& name) {
          mName = name;
        }

        static std::ostream& out(){
          return *mOutStream << "[" << name() << "] ";
        }

        static std::ostream& err(){
          return *mErrStream << "[" << name() << "] ";
        }
};
