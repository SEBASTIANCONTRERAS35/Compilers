CC = gcc
FLEX = flex
BISON = bison

all: scanner

scanner: scanner.l
	$(FLEX) -o scanner.c scanner.l
	$(CC) scanner.c -o scanner.out

clean:
	rm -f scanner.c scanner.out