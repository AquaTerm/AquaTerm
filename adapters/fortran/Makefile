all: tiny demo eventdemo1

tiny: tiny.f f2aquaterm.o
	xlf -o tiny -U -qextname tiny.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

demo: demo.f f2aquaterm.o
	xlf -o demo -U -qextname demo.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

eventdemo1: eventdemo1.f f2aquaterm.o
	xlf -o eventdemo1 -U -qextname eventdemo1.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc



f2aquaterm.o: f2aquaterm.m
	gcc -c f2aquaterm.m -I$(HOME)/include
