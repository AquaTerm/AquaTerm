How To install gnuplot with AquaTerm support on MacOS X.

1.  Get the gnuplot 3.8h (or later) tarball from
ftp://ftp.gnuplot.vt.edu/pub/gnuplot/testing/
or
get the latest sources from cvs
From the terminal (press return when prompted for password):
cvs -d:pserver:anonymous@cvs.gnuplot.sourceforge.net:/cvsroot/gnuplot login
cvs -z3 -d:pserver:anonymous@cvs.gnuplot.sourceforge.net:/cvsroot/gnuplot co gnuplot

2.  Edit the entry for MacOS X Server in src/term.h to read:
/* Apple Mac OS X */
#if defined(__APPLE__) && defined(__MACH__)
# include "aquaTerm.trm"
#endif

3.  Place the adapter aquaTerm.trm in gnuplot/term/

4.  configure and make gnuplot

5.  Put AquaTerm in /Applications or ~/Applications or add the following line to your .cshrc file:
setenv GNUTERMAPP /path/to/my/AquaTerm.app 

6.  If you want it to be the default terminal, also add
setenv GNUTERM aqua 
to the .cshrc file.

7.  start gnuplot

8.  the syntax for controlling aquaterm in gnuplot is:
"set term aqua [<n> [title "windowtitle"]]" where n is an optional (numeric) argument that set subsequent drawing to plot window [n] with optional title "windowtitle". 

