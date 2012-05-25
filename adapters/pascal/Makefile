PC=fpc
PFLAGS=

all: demo eventdemo1 eventdemo2

demo: demo.pp aquaterm.o
	$(PC) $(PFLAGS) demo.pp

eventdemo1: eventdemo1.pp aquaterm.o
	$(PC) $(PFLAGS) eventdemo1.pp

eventdemo2: eventdemo2.pp aquaterm.o
	$(PC) $(PFLAGS) eventdemo2.pp

aquaterm.o: aquaterm.pp
	$(PC) $(PFLAGS) aquaterm.pp

clean:
	rm demo eventdemo1 eventdemo2 aquaterm.ppu *.o
