all: demo eventdemo1 eventdemo2

demo: demo.c
	gcc -g -O0 -o demo demo.c -I$(HOME)/include -L$(HOME)/lib -laquaterm -lobjc

eventdemo1: eventdemo1.c
	gcc -g -O0  -o eventdemo1 eventdemo1.c -I$(HOME)/include -L$(HOME)/lib -laquaterm -lobjc

eventdemo2: eventdemo2.c
	gcc -g -O0  -o eventdemo2 eventdemo2.c -I$(HOME)/include -L$(HOME)/lib -laquaterm -lobjc

clean:
	-rm demo eventdemo1 eventdemo2 *.o *~
