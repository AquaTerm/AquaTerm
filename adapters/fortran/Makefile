##
## XLF
##
FC=xlf
FFLAGS=-U -qextname

##
## GNU g77
##
# FC=g77
# FFLAGS=-fcase-preserve

all: msg tiny demo eventdemo1 done

tiny: tiny.f f2aquaterm.o
	$(FC) -o tiny $(FFLAGS) tiny.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

demo: demo.f f2aquaterm.o
	$(FC) -o demo $(FFLAGS) demo.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

eventdemo1: eventdemo1.f f2aquaterm.o
	$(FC) -o eventdemo1 $(FFLAGS) eventdemo1.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

f2aquaterm.o: f2aquaterm.m
	gcc -c -I$(HOME)/include f2aquaterm.m 

msg: 
	@echo ""
	@echo "***********************************************************"
	@echo "*"
	@echo "*  To compile these examples, uncomment a compiler option "
	@echo "*  in the Makefile (or add your own option). "
	@echo "*"
	@echo "*  Note that $(HOME)/lib"
	@echo "*  and $(HOME)/include "
	@echo "*  are also searched if they exist."
	@echo "*"
	@echo "***********************************************************"
	@echo ""

done:
	@echo "Done."
	@echo ""
