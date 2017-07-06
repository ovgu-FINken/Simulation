CC=gcc
CXX=g++
RM=rm -f
CXXFLAGS += -I/${HOME}/Software/boost_1_64_0/boost
LDFLAGS += -lboost_system -lboost_filesystem -lpthread

SOURCES_SERVER=server.cpp
SOURCES_CLIENT=client.cpp
OBJECTS_SERVER=$(subst .cpp,.o,$(SOURCES_SERVER))
OBJECTS_CLIENT=$(subst .cpp,.o,$(SOURCES_CLIENT))


%.o: %.c
	$(CXX) -c $@ $< $(CXXFLAGS)

server: $(OBJECTS_SERVER)
	$(CXX) ${CXXFLAGS} -L/home/dom/Software/boost_1_64_0/stage/lib -lboost_system -lpthread -o server

client: $(OBJECTS_CLIENT)
	$(CXX) -o client $(OBJECTS_CLIENT)

example: $(OBJECTS)
	$(CXX) -o example $(OBJECTS)

example.o: example.cpp

server.o: server.cpp

client.o: client.cpp
