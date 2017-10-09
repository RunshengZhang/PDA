/*************************************************************************
    > File Name: netlist.h
    > Author: Biying Xu
    > Mail: biying@utexas.edu
 ************************************************************************/

#ifndef __NETLIST_H_INCLUDED__
#define __NETLIST_H_INCLUDED__

#include <iostream>
#include <vector>
#include <set>
#include <map>
#include <tuple>
#include <string>
#include <utility>

using std::cout;
using std::endl;
using std::vector;
using std::set;
using std::map;
using std::pair;
using std::tuple;
using std::string;

/* 
 * Each analog placement device is represented by a vertex
 */
class Vertex {
public:
	Vertex(size_t i, string n) : index(i), name(n) {}

	void add_dimension(size_t w, size_t h) {
		dimension = std::make_pair(w, h);
	}

	size_t index; // vertex id in the vector
	string name;
	pair<size_t, size_t> dimension; // width, height
};

/*
 * Analog circuit netlist
 */
class Netlist {
public:
	Netlist() {}
	Netlist(string const& ckt, string const& files, string const& results) : ckt_name(ckt), files_path(files), results_path(results) {}
	~Netlist() {}

	typedef pair<size_t, size_t> symmetric_pair_t; // stores vertex id
	typedef set<symmetric_pair_t> symmetric_pairs_t;
	typedef set<size_t> self_symmetric_t; // stores vertex id
	typedef pair<symmetric_pairs_t, self_symmetric_t> symmetric_group_t;

	void read_netlist_files();
	void place();
	void write_result_to_file();

	map<string, size_t> m_vertexname_id; // map vertex name to id 
	vector<Vertex> vtcs; // vector of placement devices
	map<string, set<size_t> > m_netname_vids; // net name and id 
	vector<symmetric_group_t> symmetric_groups;

	/* 
	 * Please store your final placement results in the following data structure 
	 * (x location, y location, 
	 * real width after rotation, real height after rotation)
	 */
	typedef map<size_t, tuple<int, int, size_t, size_t> > vid_loc_t;
	vid_loc_t m_vid_loc; // vertex id and final location and dimension
	
private:
	void init_file_names(); // initialize input file names
	void read_block_file();
	void read_net_file();
	void read_symmetry_file();
	void get_tot_hpwl(); // gets hpwl from m_vid_loc
	void get_tot_area(); // gets area from m_vid_loc
	string results_path = "./results/";
	string files_path = "./files/";
	string ckt_name;
	string in_block_file_name;
	string in_net_file_name;
	string in_symmetry_file_name;
	/* 
	 * Following are the metric to evaluate.
	 * You don't need to set them in your code. 
	 */
	size_t tot_width;
	size_t tot_height;
	double tot_hpwl;
};

#endif
