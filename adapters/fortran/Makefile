##
## GNU Fortran (GCC)
##
# fc=gfortran
# FFLAGS=
## (in case of MacPorts it could be called 'gfortran-mp-4.6' or alike)

##
## GNU g77
##
# fc=g77
# FFLAGS=

##
## GNU g95
##
# fc=g95
# FFLAGS=-Wl,-macosx_version_min -Wl,10.6

##
## XLF
##
# fc=xlf
# FFLAGS=-U -qextname

##
## Absoft f77
##
# fc=f77
# FFLAGS=-N15

# If you frameworks are somewhere else than under /Library/Frameworks:
# FRAMEWORKS_DIR=/opt/local/Library/Frameworks
ifneq ($(strip $(FRAMEWORKS_DIR)),)
	FRAMEWORK_FLAGS=-F$(FRAMEWORKS_DIR)
endif

all: fcsel demo eventdemo1 done

fcsel:
ifndef fc
	@echo ""
	@echo "************************************************************"
	@echo "*"
	@echo "*  To compile these examples, uncomment a compiler option   "
	@echo "*  in the Makefile (or add your own option). You can also   "
	@echo "*  specify fc and FFLAGS on the make line, e.g.             "
	@echo "*"
	@echo "*  make fc=g95 FFLAGS=                                      "
	@echo "*"
	@echo "*  If AquaTerm.framework is not in /Library/Frameworks, you "
	@echo "*  might also want to set FRAMEWORKS_DIR=/path/to/Frameworks"
	@echo "*"
	@echo "************************************************************"
	@echo ""
	@exit 1;
endif

demo: demo.f f2aquaterm.o
	$(fc) -o demo $(FFLAGS) demo.f f2aquaterm.o $(FRAMEWORK_FLAGS) -framework AquaTerm

eventdemo1: eventdemo1.f f2aquaterm.o
	$(fc) -o eventdemo1 $(FFLAGS) eventdemo1.f f2aquaterm.o $(FRAMEWORK_FLAGS) -framework AquaTerm

f2aquaterm.o: f2aquaterm.m
	$(CC) -c f2aquaterm.m $(CFLAGS) $(FRAMEWORK_FLAGS)

done:
	@echo "Done."
	@echo ""

clean:
	$(RM) demo eventdemo1 *.o
