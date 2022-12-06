//
// Created by enrico on 19/11/22.
//

#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>

using namespace std;

void write_counts(const string plain_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream plain;
    plain.open(plain_file);

    if(!plain.good()){
        cerr << "Can't open input file!" << endl;
        exit(EXIT_FAILURE);
    }

    for(int i = 0; i < symbols.size(); i++){
        for(int c = 0; c < runs[i]; c++)
            plain << symbols[i] << '\n';
    }

    plain.close();
}

void decode_in_pairs_star(const string encoded_file, vector<int> &symbols, vector<int> &runs){
    ifstream encoded;
    encoded.open(encoded_file);
    if(!encoded.good()){
        cerr << "Can't open input file!" << endl;
        exit(EXIT_FAILURE);
    }

    string line;
    while(getline(encoded, line)){
        int pos = line.find(':');
        if(pos == string::npos){ // no ":" in the line
            symbols.push_back(atoi(line.c_str()));
            runs.push_back(1);
        } else{
            line[pos] = '\0';
            symbols.push_back(atoi(line.c_str()));
            runs.push_back(atoi(line.c_str()+pos+1));
        }
    }
    encoded.close();
}

void decode_in_pairs(const string encoded_file, vector<int> &symbols, vector<int> &runs){
    decode_in_pairs_star(encoded_file, symbols, runs);
}

int main(int argc, char **argv){
    if(argc < 2){
        cout << "Need a file containing encoded counts!" << endl;
        exit(EXIT_FAILURE);
    }
    // auto-detect encoding
    int encoding = atoi(&argv[1][strlen(argv[1]) -1]);
    cout << "Autodetected encoding " << encoding << endl;
    vector<int> symbols, runs;
    string filename(argv[1]);
    argv[1][strlen(argv[1]) - 5] = '\0'; // remove .encX
    string dec_filename(argv[1]);

    cout << "Reading input file..." << endl;

    switch (encoding) {
        case 1:
            decode_in_pairs(filename, symbols, runs);
            break;
        case 2:
            cout << "Not implemented!" << endl;
            return EXIT_FAILURE;
        case 3:
            decode_in_pairs_star(filename, symbols, runs);
            break;
        default:
            cout << "Need to specify a value in {1 2 3}" << endl;
    }
    cout << "Done." << endl;
    cout << "Writing to file..." << endl;
    write_counts(dec_filename+".dec", symbols, runs);
    cout << "Done." << endl;
}