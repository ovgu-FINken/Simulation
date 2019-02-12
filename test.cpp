#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <algorithm>

using namespace std;

std::vector<bool> finkenDone;

std::vector<condition_variable*> finkenCV;

condition_variable cv;
mutex m;

bool running = true;

void run(int i) {
  while(running) {
    {
      unique_lock<mutex> lock(m);
      finkenDone[i]=true;
      cv.notify_all();
      while(finkenDone[i] && running)
        finkenCV[i]->wait(lock);
      if(!running) break;
    }
    cout << "Finken " << i << " running"  <<  endl;
  }
}

int main() {
  const unsigned int n=10;
  finkenDone.resize(n);
  for(unsigned int i=0; i<n;  i++) {
    finkenCV.emplace_back(new condition_variable());
    thread(&run, i).detach();
  }
  while(running) {
    {
    unique_lock<mutex> lock(m);
      for(unsigned int i=0; i<n; i++) {
        finkenDone[i]=false;
        finkenCV[i]->notify_all();
      }
      while(any_of(finkenDone.cbegin(), finkenDone.cend(), [](bool b){ return !b; }) && running)
        cv.wait(lock);
    }
    cout << "VREP running" << endl;
  }
  return 0;
}
