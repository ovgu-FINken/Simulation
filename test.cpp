#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <atomic>
#include <vector>

using namespace std;

struct Vrep;

struct Finken {
  mutex m;
  Vrep& vrep;
  thread t;

  Finken(Vrep& vrep);

};

struct Vrep {
  atomic<unsigned int> cnt;
  mutex m;
  condition_variable cv;
  vector<Finken*> finken;

  Vrep() :cnt(0) {}

  void  start() {
    while(1) {
      unique_lock<mutex> lock(m);
      while(cnt!=finken.size()) {
        cv.wait(lock);
      }
      cnt=0;
      cout << "Computing Simulation Step"  << endl;
      for(auto ptr : finken)
        ptr->m.unlock();
    }
  }
  void unlock() {
    unique_lock<mutex> lock(m);
    cnt++;
    cv.notify_all();
  }
};


void run(Finken* f) {
    while(true) {
      f->m.lock();
      cout << "Comuputing next command" <<  endl;
      f->vrep.unlock();
    }
  }

Finken::Finken(Vrep& vrep)  : vrep(vrep),t(&run, this) {
  vrep.finken.push_back(this);
}

int main() {
  Vrep vrep;
  std::vector<unique_ptr<Finken>> finken;
  for(unsigned int i=0;i<10;i++)
    finken.emplace_back(new Finken(vrep));
  vrep.start();
  return 0;
}
