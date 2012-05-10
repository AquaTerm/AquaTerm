# you can define the path to AquaTerm.framework with the FRAMEWORKS_DIR
# FRAMEWORKS_DIR = /Library/Frameworks

# CFLAGS = -g -O0
CFLAGS =

ifneq ($(strip $(FRAMEWORKS_DIR)),)
	FRAMEWORK_FLAG = -F$(FRAMEWORKS_DIR)
endif

all: demo eventdemo1 eventdemo2

demo: demo.c
	gcc $(CFLAGS) demo.c       -o demo       $(FRAMEWORK_FLAG) -framework AquaTerm

eventdemo1: eventdemo1.c
	gcc $(CFLAGS) eventdemo1.c -o eventdemo1 $(FRAMEWORK_FLAG) -framework AquaTerm

eventdemo2: eventdemo2.c
	gcc $(CFLAGS) eventdemo2.c -o eventdemo2 $(FRAMEWORK_FLAG) -framework AquaTerm

clean:
	-rm demo eventdemo1 eventdemo2 *.o *~
	-rm -rf *.dSYM
