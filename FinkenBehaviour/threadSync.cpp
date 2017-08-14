#include <iostream>
#include <atomic>
#include <condition_variable>
#include <thread>
#include <chrono>

#include <Eigen/Core>
 
std::condition_variable cv;
std::mutex cv_m, syncMutex;

struct Sync {
  private:
    Eigen::Matrix<bool, Eigen::Dynamic, 1> mData;

  public:
    size_t extend() { 
      std::unique_lock<std::mutex> lk(syncMutex); 
      size_t i = mData.rows(); 
      mData.resize(i+1, 1); 
      mData(i) = false; 
      return i;
    }
    void set(size_t i) { 
      std::unique_lock<std::mutex> lk(syncMutex);
      mData(i)=true;
    }
    operator bool() const { 
      std::unique_lock<std::mutex> lk(syncMutex);
      return mData.prod();
    }
    void clear() {
      std::unique_lock<std::mutex> lk(syncMutex);
      mData.resize(0,1);
    }
  friend std::ostream& operator<<(std::ostream& o, const Sync s);
} ready;

std::ostream& operator<<(std::ostream& o, const Sync s) {
  return o << s.mData;
}
 
void waits(int idx)
{
    std::unique_lock<std::mutex> lk(cv_m);
    if(cv.wait_for(lk, std::chrono::milliseconds(idx*idx*idx*100), [](){return ready;})) 
        std::cerr << "Thread " << idx << " finished waiting. i == " << ready << '\n';
    else
        std::cerr << "Thread " << idx << " timed out. i == " << ready << '\n';
}
 
void signals(int idx)
{
    size_t i = ready.extend();
    std::this_thread::sleep_for(std::chrono::milliseconds(idx*120));
    std::cerr << "Notifying... from " << idx <<  std::endl;
    cv.notify_all();
    std::this_thread::sleep_for(std::chrono::milliseconds(idx*100));
    ready.set(i);
    std::cerr << "Notifying again... from " << idx << std::endl;
    cv.notify_all();
}
 
int main()
{
    std::thread t1(waits, 1), t2(waits, 2), t3(waits, 3), t4(signals,1), t5(signals,2), t6(signals,3);
    t1.join(); t2.join(), t3.join(), t4.join(), t5.join(), t6.join();
}
