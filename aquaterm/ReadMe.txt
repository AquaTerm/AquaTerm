***** IMPORTANT *****
This is an early release for testing purposes. Please provide feedback and feature requests!
*********************

* How to use AquaTerm:
AquaTerm is a graphics terminal that can be used to easily add aqua graphics to (primarily scientific) legacy applications written in C, FORTRAN or any other language that can send remote messages.

AquaTerm register with the system and responds to a (small) set of remote messages, listed and explained in AQTBaseMethods.h, AQTExtendedMethods.h (AQTProtocol.h). 

* Documentation

All documentation is available at http://aquaterm.sourceforge.net

* AquaTerm changes
------------------
AquaTerm 0.3.2
  Bugfix: Help is now working
  Window size settable from client
  Resize respects window width/height ratio
  Handles attributed strings
  Splitting AQTProtocol, separating Foundation and AppKit dependencies. 
    AQTProtocol.h provides backwards compatibility
  Source included in distro, use 
	pbxbuild -target AquaTerm clean
	pbxbuild -target AquaTerm -buildstyle Deployment
    to build the executable from the command line or use PB. 
    To build the (somewhat outdated) docs you need autodoc.

AquaTerm 0.3.1
  Bugfix: Save as EPS/PDF (#605454)
  Bugfix: Copy PDF & EPS to clipboard
  Added icon

AquaTerm 0.3.0
  Save as EPS/PDF
  Copy PDF & EPS to clipboard
  Support for setting window title
  Help menu links to homepage

* Adapter changes
-----------------
AquaTerm 0.3.2
  PLPLOT
    Added driver for PLPLOT contributed by Mark Franz
  PGPLOT
    Window size controlled from PGPLOT

AquaTerm 0.3.1
  Gnuplot
    Bugfix: Crash when using multiplot in octave/gnuplot (#558799)
    Improved buffering
    Implemented plotstyle 'dots' (#512628)

  PGPLOT
    Improved buffering
    Bugfix: Restoring default colors (#593895)

  C/FORTRAN
    Minor fixes

  Matwrap
    Added makefile that uses matwrap to create an adapter for octave from the C example
    
AquaTerm 0.3.0
  Gnuplot
    New syntax: set term aqua [<n> [title "windowtitle"]]

  PGPLOT
    Initial support for PGPLOT

  C/FORTRAN
    Updated drivers for C and FORTRAN

* How to get the latest source for AquaTerm:

The source for AquaTerm is available in the CVS repository at http://sourceforge.net/projects/aquaterm
The source corresponding to this release is tagged: release-0_3_2

From the terminal use (press return when prompted for password):
cvs -d:pserver:anonymous@cvs.aquaterm.sourceforge.net:/cvsroot/aquaterm login
cvs -z3 -d:pserver:anonymous@cvs.aquaterm.sourceforge.net:/cvsroot/aquaterm co aquaterm 
cvs -z3 -d:pserver:anonymous@cvs.aquaterm.sourceforge.net:/cvsroot/aquaterm co adapters 

* About the source:
The classes with prefix GPT (Graph Plotting Terminal) are about to be replaced with new and improved classes prefixed AQT (AQuaTerm). See attic in the CVS for removed GPT classes. Feel free to contribute to the project!

* Future ToDo's:
- Refactor code: Separate AppKit/Foundation, move code common to all adapters to libaquaterm
- Add user settings for such things as default font etc.
- Save colormaps
- Add adapters for more legacy apps…

* Legalities

Copyright (c) 2001-2002, Per Persson, AquaTerm project
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
