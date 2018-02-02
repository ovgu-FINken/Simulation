# V-REP Plugin for Wireless Communication

## Build
Like V-REP, this is a qt5 plugin, so please make sure to have a qt5 toolchain installed to build it

1. set VREP_PATH in the .pro file
2. run `qmake`
3. run `make`
4. copy the lib (depending on your OS) from /release to your V-REP installation folder or run `make install`

## Run

1. copy inet 2.6 to V-REP installation folder/communication/ to have access to inet models
2. copy the 802154OmnetFINken to the V-REP installation folder/communication/
2. copy the libinet- library into the V-REP installation folder
3. copy liboppsim(d), liboppnedxml(d), liboppcommon(d) libraries into the V-REP installation folder
3.1 Windows users: libiconv-2.dll, libxml2-2.dll and libexpat.dll probably also need to be copied into the V-REP installation folder. Some zlib1.dll have issues with missing methods, when loading the plugin dll fails, download a new one and put it into the V-REP installation folder. The gnuwin32 version from sourceforge worked for me.
