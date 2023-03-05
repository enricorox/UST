//
// Created by enrico on 07/11/22.
//

#include <iostream>
#include <stdlib.h>
#include <string.h>

using namespace std;

int main(int argc, char **argv){
    if(argc < 2){
        cout << "Need a file as argument!" << endl;
        exit(EXIT_FAILURE);
    }

    bool count_stripped_header = false;
    if(argc > 2 && strcmp(argv[2], "-h=1") == 0){
        count_stripped_header = true;
        //cout << "Counting stripped headers" << endl;
    }

    FILE * f = fopen(argv[1], "r");
    if(f == NULL){
        cout << "File " << argv[1] << " may not exist" << endl;
        exit(EXIT_FAILURE);
    }

    // reading buffer
    size_t max = 10000;
    char * buf = (char *) malloc(max);

    // compute cumulative length
    unsigned long len = 0;
    while (true) {
        int c = getline(&buf, &max, f);

        // break if we cannot read anymore
        if(c <= 0)
            break;

        // skip deflines
        if(buf[0] == '>') {
            if (count_stripped_header)
                len++;
            continue;
        }

        // count nucleotides in the buffer
        for(int i = 0; i < c; i++)
            switch(buf[i]){
            case 'A':
            case 'C':
            case 'G':
            case 'T':
                len++;
        }
    }
    fclose(f);

    printf("%u\n", len);

    return EXIT_SUCCESS;
}