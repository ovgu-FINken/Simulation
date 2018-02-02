//
// Generated file, do not edit! Created by nedtool 4.6 from util/vrepCoords.msg.
//

#ifndef _VREPCOORDS_M_H_
#define _VREPCOORDS_M_H_

#include <omnetpp.h>

// nedtool version check
#define MSGC_VERSION 0x0406
#if (MSGC_VERSION!=OMNETPP_VERSION)
#    error Version mismatch! Probably this file was generated by an earlier version of nedtool: 'make clean' should help.
#endif



// cplusplus {{
	#include <Coord.h>
// }}

/**
 * Class generated from <tt>util/vrepCoords.msg:9</tt> by nedtool.
 * <pre>
 * message vrepCoords
 * {
 *     Coord position;
 * }
 * </pre>
 */
class vrepCoords : public ::cMessage
{
  protected:
    Coord position_var;

  private:
    void copy(const vrepCoords& other);

  protected:
    // protected and unimplemented operator==(), to prevent accidental usage
    bool operator==(const vrepCoords&);

  public:
    vrepCoords(const char *name=NULL, int kind=0);
    vrepCoords(const vrepCoords& other);
    virtual ~vrepCoords();
    vrepCoords& operator=(const vrepCoords& other);
    virtual vrepCoords *dup() const {return new vrepCoords(*this);}
    virtual void parsimPack(cCommBuffer *b);
    virtual void parsimUnpack(cCommBuffer *b);

    // field getter/setter methods
    virtual Coord& getPosition();
    virtual const Coord& getPosition() const {return const_cast<vrepCoords*>(this)->getPosition();}
    virtual void setPosition(const Coord& position);
};

inline void doPacking(cCommBuffer *b, vrepCoords& obj) {obj.parsimPack(b);}
inline void doUnpacking(cCommBuffer *b, vrepCoords& obj) {obj.parsimUnpack(b);}


#endif // ifndef _VREPCOORDS_M_H_

