#
# Makefile for the simple demonstration functions in c2aqt.h.
# See http://aquaterm.sf.net for details.
#
# To use:
#	Do "make octave" to make the octave binary.
#	
PERL	  = perl
TOP	  = /usr/local
CP    = cp
MV	  = mv
MATWRAP = $(PERL) -w $(TOP)/bin/matwrap
#

all::
	@echo 'Type "make octave" to make the octave example.'
	@false


########################################################################
#
# Instructions for making the octave modules:
#
MKOCTFILE = mkoctfile
AQTINCL = -I../../aquaterm

octave:: aqt2_octave.oct

aqt2_octave.oct: c2aqt.h c2aqt.o
	$(MATWRAP) -language octave c2aqt.h \
		-o aqt2_octave.cc -stub aqt_stub.m
	$(MKOCTFILE) aqt2_octave.cc c2aqt.o

c2aqt.o: ; 
	$(CP) ../c/c2aqt.m c2aqt.mm 
	$(CXX) -c c2aqt.mm $(AQTINCL)

c2aqt.h: ; 
	$(CP) ../c/c2aqt.h .
########################################################################
#
#
clean::
	$(RM) -rf  *.o  *_octave.cc *.oct *_stub.m  octave-core
