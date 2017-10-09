/*************************************************************************
    > File Name: main.cpp
    > Author: Biying Xu
    > Mail: biying@utexas.edu
 ************************************************************************/

#include <ctime>
#include <chrono>
#include <iostream>
#include <string>
#include <memory> //std::shared_ptr
#include "netlist.h"

using std::cout;
using std::endl;
using std::string;

int main(int argc, char** argv)
{
	auto wcts_start = std::chrono::system_clock::now();
	std::clock_t start = std::clock();

	// 1st arg: circuit name
	// 2nd arg: input files path
	// 3rd arg: result path
	string ckt_name = argv[1];
	string files_path = argv[2];
	string results_path = argv[3];

	std::shared_ptr<Netlist> c = std::shared_ptr<Netlist>(new Netlist(ckt_name, files_path, results_path));
	c->read_netlist_files();

	c->place(); // placement main function

	c->write_result_to_file();
	
	auto wcts_end = std::chrono::system_clock::now();
	std::chrono::duration<double> wctduration = wcts_end - wcts_start;
	cout << "Placement finished in " << wctduration.count() << " seconds [Wall Clock]" << endl;
	std::clock_t end = std::clock();
	double duration = (end - start) / (double)CLOCKS_PER_SEC;
	cout << "Elapse time: " << duration << endl;

	return 0;
}
