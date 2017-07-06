//
// blocking_tcp_echo_server.cpp
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2017 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//
#include <cstring>
#include <cstdlib>
#include <iostream>
#include <thread>
#include <memory>
#include <utility>
#include <boost/asio.hpp>
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>

using boost::asio::ip::tcp;

void session(std::unique_ptr<tcp::iostream> sPtr){
  try  {
    std::cout << "client connected" << std::endl;
    for (;;)    {
      unsigned int seqNr;
      {
        boost::archive::text_iarchive in(*sPtr);
        in >> seqNr;
      }
      std::cout << "Query is: " << seqNr++ << std::endl;
      
      boost::archive::text_oarchive out(*sPtr);
      out << seqNr+100;

      std::cout << "Reply is: " << seqNr+100 << std::endl;

    }
  }
  catch (std::exception& e) {
    std::cerr << "Exception in thread: " << e.what() << "\n";
    std::cerr << "Error Message: " << sPtr->error().message() << std::endl;
  }
}

void server(boost::asio::io_service& io_service, unsigned short port){
  tcp::acceptor a(io_service, tcp::endpoint(tcp::v4(), port));
  for (;;)  {
    std::unique_ptr<tcp::iostream> sPtr;
    sPtr.reset(new tcp::iostream());
    a.accept(*sPtr->rdbuf());
    std::thread(session, std::move(sPtr)).detach();
  }
}

int main(int argc, char** argv){
  try{
    boost::asio::io_service io_service;
    server(io_service, 50013);
  }
  catch (std::exception& e) {
    std::cerr << "Exception: " << e.what() << "\n";
  }

  return 0;
}
