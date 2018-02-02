#pragma once

#include <omnetpp.h>
#include <cnullenvir.h>
#include <cxmldoccache.h>
#include <cxmlelement.h>

#include "FinkenOmnetSim.h"

namespace oppVrep {

class FinkenOmnetSim; 

class VrepSimEnv : public cNullEnvir {
	public:
		VrepSimEnv();
		VrepSimEnv(int ac, char **av, cConfiguration *c);
		virtual ~VrepSimEnv() {}
		virtual void readParameter(cPar *par); 
		//@TODO log to vrep 
		virtual void sputn(const char *s, int n); 
		virtual cXMLElement *getXMLDocument(const char *filename, const char *xpath=NULL); 
    	virtual cXMLElement *getParsedXMLString(const char *content, const char *xpath=NULL); 
    	virtual void forgetXMLDocument(const char *filename); 
    	virtual void forgetParsedXMLString(const char *content); 
    	virtual void flushXMLDocumentCache();
    	virtual void flushXMLParsedContentCache();
    	void setSimulationMaster(FinkenOmnetSim *newSimulationMaster);
	protected:
		cXMLDocCache *xmlcache;
		cXMLElement *resolveXMLPath(cXMLElement *documentnode, const char *path);
	private:
		FinkenOmnetSim *masterSimulation;		
};
}
