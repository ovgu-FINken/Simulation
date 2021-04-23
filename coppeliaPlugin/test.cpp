#include <Eigen/Core>
#include <boost/serialization/serialization.hpp>
#include <boost/serialization/split_free.hpp>
#include <boost/archive/text_iarchive.hpp>
#include <boost/archive/text_oarchive.hpp>

#include <fstream>
#include <iostream>

using Matrix = Eigen::MatrixXf;
using Vector = Eigen::VectorXf;



namespace boost { namespace serialization {

template<typename T, int rows, int cols, class Archive>
inline void save(Archive& ar, const ::Eigen::Matrix<T, rows, cols>&  m, unsigned int v) {
  ar << m.cols();
  ar << m.rows();
  for(unsigned int i=0;i<m.cols()*m.rows();i++)
    ar << m.data()[i];
}

template<typename T, int R, int C, class Archive>
inline void load(Archive& ar, ::Eigen::Matrix<T, R, C>&  m,  unsigned int v) {
  unsigned int rows, cols;
  ar >> cols;
  ar >> rows;
  m.resize(rows, cols);
  for(unsigned int i=0;i<cols*rows;i++)
    ar >>  m.data()[i];
}

template<typename T, int rows, int cols, class Archive>
inline void serialize(Archive& ar, ::Eigen::Matrix<T, rows, cols>&  m,  unsigned int file_version) {
  split_free(ar, m, file_version); 
}

}}

int main() {
  Matrix a(3,3), b;
  Vector c(3), d;
  a  <<  1,2,3,4,5,6,7,8,9;
  c << 1,2,3;
  std::fstream fout("test.txt", std::ios_base::out);
  std::fstream fin("test.txt", std::ios_base::in);
  {
  boost::archive::text_oarchive out(fout);
  out << a << c;
  }{
  boost::archive::text_iarchive in(fin);
  in >> b >> d;
  }
  std::cout << a << std::endl  << std::endl;
  std::cout << b <<  std::endl << std::endl;
  std::cout << c << std::endl << std::endl;
  std::cout << d <<  std::endl << std::endl;
  return 0;
}
