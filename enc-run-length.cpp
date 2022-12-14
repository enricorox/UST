//
// Created by enrico on 19/11/22.
//

#include <iostream>
#include <fstream>
#include <vector>

#define SYMBOL_RUN_SEPARATOR "-"
#define BLOCK_SEPARATOR " "

using namespace std;

void read_counts(const string plain_file, vector<int> &symbols, vector<int> &runs){
    ifstream plain;
    plain.open(plain_file);

    int c=0;
    int curr;

    plain >> curr;
    int prev = curr;
    do{
        if(curr == prev)
            c++;
        else{
            symbols.push_back(prev);
            runs.push_back(c);
            // reset
            c = 1;
            prev = curr;
        }
    }while(plain >> curr);
    // save last run
    symbols.push_back(curr);
    runs.push_back(c);

    plain.close();
}

vector<int> delta_transform(vector<int> symbols){
    vector<int> deltas = {symbols[0]};
    for(int i = 1; i < symbols.size(); i++){
        if(deltas[i - 1] >= 0) {
            int delta = symbols[i] - symbols[i - 1];
            deltas.push_back(delta);
        }else
            deltas.push_back(symbols[i]);
    }
    return deltas;
}

void encode_in_pairs(const string encoded_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream encoded;
    encoded.open(encoded_file);
    if(!encoded.good()){
        cerr << "Can't open output file!" << endl;
        exit(EXIT_FAILURE);
    }

    encoded << symbols[0] << ":" << runs[0];
    for(int i = 1; i < symbols.size(); i++){
        encoded << "\n" << symbols[i] << ":" << runs[i];
    }
    encoded.close();
}

void encode_in_pairs_star(const string encoded_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream encoded;
    encoded.open(encoded_file);
    if(!encoded.good()){
        cerr << "Can't open output file!" << endl;
        exit(EXIT_FAILURE);
    }

    encoded << symbols[0];
    if(runs[0] != 1)
        encoded << SYMBOL_RUN_SEPARATOR << runs[0];

    for(int i = 1; i < symbols.size(); i++){
        encoded << BLOCK_SEPARATOR << symbols[i];
        if(runs[i] != 1)
            encoded << SYMBOL_RUN_SEPARATOR << runs[i];
    }
    encoded.close();
}

void encode_in_columns(const string encoded_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream encoded;
    encoded.open(encoded_file);
    if(!encoded.good()){
        cerr << "Can't open output file!" << endl;
        exit(EXIT_FAILURE);
    }
    for(int i = 0; i < symbols.size(); i++){
        encoded << symbols[i] << ":" ;
    }
    encoded << "\n";
    for(int i = 0; i < symbols.size(); i++){
        encoded << runs[i] << ":";
    }
    encoded.close();
}

void encode_vector(const string encoded_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream encoded;
    encoded.open(encoded_file);
    if(!encoded.good()){
        cerr << "Can't open output file!" << endl;
        exit(EXIT_FAILURE);
    }

    encoded << symbols[0] << " " << runs[0];
    for(int i = 1; i < symbols.size(); i++){
        encoded << " " << symbols[i] << " " << runs[i];
    }
    encoded.close();
}

void encode_vectors_binary(const string encoded_file, const vector<int> &symbols, const vector<int> &runs){
    ofstream encoded;
    encoded.open(encoded_file);
    for(auto symbol : symbols){
        encoded.write((char *) &symbol, 2);
    }
    for(auto run : runs){
        encoded.write((char *) &run, 2);
    }
    encoded.close();
}

int main(int argc, char **argv){
    if(argc < 3){
        cout << "Need a file containing counts and  a value in {1 2 3}!" << endl;
        exit(EXIT_FAILURE);
    }
    vector<int> symbols, runs;
    string filename_base(argv[1]);

    cout << "Reading input file..." << endl;
    read_counts(argv[1], symbols, runs);
    cout << "Done." << endl;

    for(int i = 2; i < argc; i++) {
        string filename = filename_base;
        switch (atoi(argv[i])) {
            case 1:
                filename += ".enc1";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_in_pairs(filename, symbols, runs);
                break;
            case 2:
                filename += ".enc2";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_vector(filename, symbols, runs);
                break;
            case 3:
                filename += ".enc3";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_in_pairs_star(filename, symbols, runs);
                break;
            case 4:
                filename += ".enc4";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_vectors_binary(filename, symbols, runs);
                break;
            case 5:
                filename += ".enc5";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_in_pairs_star(filename, delta_transform(symbols), runs);
                break;
            case 6:
                filename += ".enc6";
                cout << "Writing run-length encoded file " << filename << "..." << endl;
                encode_vectors_binary(filename, delta_transform(symbols), runs);
                break;
            default:
                cout << "Need to specify a value in {1 2 3}" << endl;
        }
    }
    cout << "Done." << endl;
}