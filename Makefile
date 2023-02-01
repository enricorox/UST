CC=g++
CFLAGS=-c -Wall -std=c++11 -O0 -g -ggdb

SOURCES=ust.cpp
OBJECTS=$(SOURCES:.cpp=.o)
EXECUTABLE=ust

BCALMFILE=examples/k31.a1.unitigs.fa
K=31

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f *.o ust *.ust.fa *.stats.txt *.ust.counts

test:
	./ust -i  $(BCALMFILE) -k $(K) -a 1
