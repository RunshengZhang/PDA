/*************************************************************************
    > File Name: netlist.cpp
    > Author: Biying Xu
    > Mail: biying@utexas.edu
 ************************************************************************/

#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <set>
#include <map>
#include <vector>
#include <utility>
#include "netlist.h"

using std::cout;
using std::endl;
using std::set;
using std::map;
using std::pair;
using std::vector;
using std::ifstream;

void Netlist::init_file_names()
{
	in_block_file_name = files_path+"/"+ckt_name+"/"+ckt_name+".block";
	in_net_file_name = files_path+"/"+ckt_name+"/"+ckt_name+".net";
	in_symmetry_file_name = files_path+"/"+ckt_name+"/"+ckt_name+".sym";
}

void Netlist::read_netlist_files()
{
	init_file_names();

	read_block_file();
	read_net_file();
	read_symmetry_file();

	cout<<"finish reading all netlist files."<<endl;
}

void Netlist::read_block_file()
{
	ifstream in_block_file;
	in_block_file.open(in_block_file_name);

	string module_name;
	size_t a, b;
	while(in_block_file >> module_name >> a >> b) {
		size_t vidx = vtcs.size();
		m_vertexname_id[module_name] = vidx;
		vtcs.push_back(Vertex(vidx, module_name));
		vtcs.at(vidx).add_dimension(a, b);
	}

	in_block_file.close();
	cout<<"Finish reading block file."<<endl;
}

void Netlist::read_net_file()
{
	ifstream in_net_file;
	in_net_file.open(in_net_file_name);

	std::string line;
	while(std::getline(in_net_file, line)) {
	    std::istringstream iss(line);
	    string net_name;
		iss >> net_name;

		set<size_t> vids_in_net;
		string module_name;
		int pin_pos_x, pin_pos_y;
	    while(iss >> module_name >> pin_pos_x >> pin_pos_y) {
			vids_in_net.insert(m_vertexname_id[module_name]);
		}
		// NOTE: if a net connects only one component, ignore
		if(vids_in_net.size() > 1) {
			m_netname_vids[net_name] = vids_in_net;
		}
	}

	in_net_file.close();
	cout<<"Finish reading net file."<<endl;
}

void Netlist::read_symmetry_file()
{
	ifstream in_symmetry_file;
	in_symmetry_file.open(in_symmetry_file_name);

	symmetric_pairs_t sym_pairs;
	self_symmetric_t self_sym;
	std::string line;
	while(std::getline(in_symmetry_file, line)) {
	    std::istringstream iss(line);
		string a, b;
		if(iss >> a) {
			if(iss >> b) {
				// symmetric pair
				sym_pairs.insert(pair<size_t, size_t>(m_vertexname_id[a], m_vertexname_id[b]));
			}
			else {
				// self-symmetric
				self_sym.insert(m_vertexname_id[a]);
			}
		}
		else {
			if(!(sym_pairs.empty() && self_sym.empty())) {
				symmetric_group_t sym_group = symmetric_group_t(sym_pairs, self_sym);
				symmetric_groups.push_back(sym_group);
				sym_pairs.clear();
				self_sym.clear();
			}
		}
	}
	if(!(sym_pairs.empty() && self_sym.empty())) {
		symmetric_group_t sym_group = symmetric_group_t(sym_pairs, self_sym);
		symmetric_groups.push_back(sym_group);
	}

	in_symmetry_file.close();
	cout<<"Finish reading symmetry file."<<endl;
}

void Netlist::get_tot_hpwl()
{
	tot_hpwl = 0;
	ifstream in_net_file;
	in_net_file.open(in_net_file_name);

	std::string line;
	while(std::getline(in_net_file, line)) {
	    std::istringstream iss(line);
	    string net_name;
		iss >> net_name;
		vector<tuple<string, int, int> > modules_in_net;
		string module_name;
		int pin_pos_x, pin_pos_y;
	    while(iss >> module_name >> pin_pos_x >> pin_pos_y) {
			modules_in_net.push_back(std::make_tuple(module_name, pin_pos_x, pin_pos_y));
		}
		if(module_name.compare("")==0) {
			continue;
		}
		// half perimeter wire length
		tuple<int, int, size_t, size_t> first_module = m_vid_loc[m_vertexname_id[std::get<0>(modules_in_net[0])]];
		int first_x = std::get<0>(first_module); 
		int first_y = std::get<1>(first_module); 
		size_t first_w = std::get<2>(first_module); 
		size_t first_h = std::get<3>(first_module); 
		double min_x = first_x + first_w / 2.0;
		double max_x = first_x + first_w / 2.0;
		double min_y = first_y + first_h / 2.0;
		double max_y = first_y + first_h / 2.0;
		for(size_t i=0; i<modules_in_net.size(); ++i) {
			tuple<int, int, size_t, size_t> mod = m_vid_loc[m_vertexname_id[std::get<0>(modules_in_net[i])]];
			double center_x = std::get<0>(mod) + std::get<2>(mod) / 2.0;
			double center_y = std::get<1>(mod) + std::get<3>(mod) / 2.0;
			if(center_x < min_x) { min_x = center_x; }
			else if(center_x > max_x) { max_x = center_x; }
			if(center_y < min_y) { min_y = center_y; }
			else if(center_y > max_y) { max_y = center_y; }
		}
		tot_hpwl += (max_x - min_x + max_y - min_y);
	}

	in_net_file.close();
	cout << "Finish calculating HPWL: " << tot_hpwl << endl;
}

void Netlist::get_tot_area() {
	tot_width = 0;
	tot_height = 0;
	for(vid_loc_t::iterator it=m_vid_loc.begin(); it!=m_vid_loc.end(); ++it) {
		int x = std::get<0>(it->second);
		int y = std::get<1>(it->second);
		size_t w = std::get<2>(it->second);
		size_t h = std::get<3>(it->second);
		if ( (size_t)x + w > tot_width ) { tot_width = (size_t)x + w; }
		if ( (size_t)y + h > tot_height ) { tot_height = (size_t)y + h; }
	}
	cout << "Finish calculating area: (" << tot_width << ", " << tot_height << ")" << endl;
}

void Netlist::write_result_to_file() {
	get_tot_area();
	get_tot_hpwl();

	string out_file_name = results_path+"/result_"+ckt_name+".txt"; 
	std::ofstream out_file;
	out_file.open(out_file_name);
	out_file<<"Total width: "<<tot_width<<", total height: "<<tot_height<<", total hpwl: "<<tot_hpwl<<"\n";
	// result file format: name x y w h
	for(vid_loc_t::iterator it=m_vid_loc.begin(); it!=m_vid_loc.end(); ++it) {
		out_file<<vtcs[it->first].name<<" ";
		out_file<<std::get<0>(it->second)<<" ";
		out_file<<std::get<1>(it->second)<<" ";
		out_file<<std::get<2>(it->second)<<" ";
		out_file<<std::get<3>(it->second)<<"\n";
	}
	out_file.close();
	cout << "Finish writing result to file: " << out_file_name << endl;
}

void Netlist::place() {
	/* implement your placement algorithm here */
}

