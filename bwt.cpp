//
// Created by enrico on 12/12/22.
//

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include "counts.h"

typedef unsigned char byte;

byte *rotlexcmp_buf = NULL;
int rottexcmp_bufsize = 0;

int rotlexcmp(const void *l, const void *r)
{
    int li = *(const int*)l, ri = *(const int*)r, ac=rottexcmp_bufsize;
    if(li == ri) return 0;
    while (rotlexcmp_buf[li] == rotlexcmp_buf[ri])
    {
        if (++li == rottexcmp_bufsize)
            li = 0;
        if (++ri == rottexcmp_bufsize)
            ri = 0;
        if (!--ac)
            return 0;
    }
    if (rotlexcmp_buf[li] > rotlexcmp_buf[ri])
        return 1;
    else
        return -1;
}

void bwt_encode(byte *buf_in, byte *buf_out, int size, int *primary_index)
{
    int indices[size];
    int i;

    for(i=0; i<size; i++)
        indices[i] = i;
    rotlexcmp_buf = buf_in;
    rottexcmp_bufsize = size;
    qsort (indices, size, sizeof(int), rotlexcmp);

    for (i=0; i<size; i++)
        buf_out[i] = buf_in[(indices[i]+size-1)%size];
    for (i=0; i<size; i++)
    {
        if (indices[i] == 1) {
            *primary_index = i;
            return;
        }
    }
    assert (0);
}

void bwt_decode(byte *buf_in, byte *buf_out, int size, int primary_index)
{
    byte F[size];
    int buckets[256];
    int i,j,k;
    int indices[size];

    for (i=0; i<256; i++)
        buckets[i] = 0;
    for (i=0; i<size; i++)
        buckets[buf_in[i]] ++;
    for (i=0,k=0; i<256; i++)
        for (j=0; j<buckets[i]; j++)
            F[k++] = i;
    assert (k==size);
    for (i=0,j=0; i<256; i++)
    {
        while (i>F[j] && j<size)
            j++;
        buckets[i] = j; // it will get fake values if there is no i in F, but
        // that won't bring us any problems
    }
    for(i=0; i<size; i++)
        indices[buckets[buf_in[i]]++] = i;
    for(i=0,j=primary_index; i<size; i++)
    {
        buf_out[i] = buf_in[j];
        j=indices[j];
    }
}

int main()
{
    //byte buf1[] = "Polska Wikipedia";
    byte buf1 = counts;
    //int size = strlen((const char*)buf1);
    int size = counts.size();
    byte buf2[size];
    byte buf3[size];
    int primary_index;

    bwt_encode (buf1, buf2, size, &primary_index);
    bwt_decode (buf2, buf3, size, primary_index);

    assert (!memcmp (buf1, buf3, size));
    printf("it works!");
    //printf ("Result is the same as input, that is: <%.*s>\n", size, buf3);
    // Print out encode/decode results:
    //printf ("Input: <%.*s>\n", size, buf1);
    //printf ("Output: <%.*s>\n", size, buf2);
    return 0;
}