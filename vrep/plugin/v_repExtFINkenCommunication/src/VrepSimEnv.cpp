#include "VrepSimEnv.h"

#include <assert.h>
#include <appreg.h>
#include <envir/sectionbasedconfig.h>
namespace oppVrep {



VrepSimEnv::VrepSimEnv(int ac, char **av, cConfiguration *c) : cNullEnvir(ac, av, c){
	//argc=ac; 
	//argv=av; 
	//cfg=c; 
	//rng=new cMersenneTwister(); 
	//lastnum=0;
	xmlcache = new cXMLDocCache();
}

void VrepSimEnv::readParameter(cPar *par) {
	ASSERT(!par->isSet()); 
	
	std::string moduleFullPath = par->getOwner()->getFullPath();
	const char *str = getConfigEx()->getParameterValue(moduleFullPath.c_str(), par->getName(), par->containsValue());
	

	if (opp_strcmp(str, "default") == 0){
		ASSERT(par->containsValue());
		par->acceptDefault();
	}
	else if (!(opp_strcmp(str,"") == 0)){
		par->parse(str);
	}
	else {
		if (par->containsValue())
			par->acceptDefault();
		else
			throw cRuntimeError("no value for %s", par->getFullPath().c_str());
	}
	ASSERT(par->isSet());
}

cXMLElement *VrepSimEnv::getXMLDocument(const char *filename, const char *path){
	cXMLElement *documentnode = xmlcache->getDocument(filename);
    return resolveXMLPath(documentnode, path);	
} 
cXMLElement *VrepSimEnv::getParsedXMLString(const char *content, const char *path){ 
	cXMLElement *documentnode = xmlcache->getParsed(content);
	return resolveXMLPath(documentnode, path);
}

cXMLElement *VrepSimEnv::resolveXMLPath(cXMLElement *documentnode, const char *path)
{
    assert(documentnode);
    if (path)
    {
        ModNameParamResolver resolver(simulation.getContextModule()); // resolves $MODULE_NAME etc in XPath expr.
        return cXMLElement::getDocumentElementByPath(documentnode, path, &resolver);
    }
    else
    {
        // returns the root element (child of the document node)
        return documentnode->getFirstChild();
    }
}

void VrepSimEnv::forgetXMLDocument(const char *filename){
	xmlcache->forgetDocument(filename);
}

void VrepSimEnv::forgetParsedXMLString(const char *content){
	xmlcache->forgetParsed(content);
}
void VrepSimEnv::flushXMLDocumentCache(){
	xmlcache->flushDocumentCache();
}
void VrepSimEnv::flushXMLParsedContentCache(){
	xmlcache->flushParsedContentCache();
}

void VrepSimEnv::setSimulationMaster(FinkenOmnetSim *newSimulationMaster){
	masterSimulation = newSimulationMaster;	
}

void VrepSimEnv::sputn(const char *s, int n) {
	(void) ::fwrite(s,1,n,stdout);
}
}
