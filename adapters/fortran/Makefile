##
## XLF
##
# fc=xlf
# FFLAGS=-U -qextname

##
## GNU g77
##
# fc=g77
# FFLAGS=-fcase-preserve

##
## Absoft f77
##
# fc=f77
# FFLAGS=-N15

all: fcsel demo eventdemo1 done

fcsel:
ifndef fc
	@echo ""
	@echo "***********************************************************"
	@echo "*"
	@echo "*  To compile these examples, uncomment a compiler option "
	@echo "*  in the Makefile (or add your own option). You can also "
	@echo "*  specify fc and FFLAGS on the make line, e.g. "
	@echo "*  make fc=g77 FFLAGS=-fcase-preserve "
	@echo "*"
	@echo "*  Note that $(HOME)/lib"
	@echo "*  and $(HOME)/include "
	@echo "*  are also searched if they exist."
	@echo "*"
	@echo "***********************************************************"
	@echo ""
	@exit 1;
endif

demo: demo.f f2aquaterm.o
	$(fc) -o demo $(FFLAGS) demo.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

eventdemo1: eventdemo1.f f2aquaterm.o
	$(fc) -o eventdemo1 $(FFLAGS) eventdemo1.f f2aquaterm.o -L$(HOME)/lib -laquaterm -lobjc

f2aquaterm.o: f2aquaterm.m
	gcc -c -I$(HOME)/include f2aquaterm.m 

done:
	@echo "Done."
	@echo ""
