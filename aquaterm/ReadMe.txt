***** IMPORTANT *****
This is an early release for testing purposes. Please provide feedback and feature requests!
*********************

* How to use AquaTerm:
AquaTerm is a graphics viewer that can be used to easily add aqua graphics to (primarily scientific) legacy applications written in C, FORTRAN or any other language that can call C or Objective-C library functions.

AquaTerm.app register with the system and responds to a (small) set of remote messages. The connection between the client and the server (AquaTerm.app) is handled by a shared lib (libaquaterm.dylib). The library exposes small and simple C and Objective-C interfaces (use either according to taste) which is tailored to suit procedural code. See AQTAdapter.h and aquaterm.h for details.     

* Documentation

The API is detailed in AQTAdapter.html which is generated from AQTAdapter.h using AutoDoc.
Full documentation is available at http://aquaterm.sourceforge.net

The following environment variables may be of interest:
AquaTerm.app (Must be set in ~/.MacOSX/environment.plist See http://developer.apple.com/qa/qa2001/qa1067.html )
------------
AQUATERM_REPORT_TIMING	set this to anything to log drawing time

Clients
-------
AQUATERM_LOGLEVEL	set this in the range 1-4 to have increasing levels of logging. 
AQUATERM_PATH		set this to point to any non-standard location of AquaTerm.app e.g. /Users/you/source/build/AquaTerm.app
GNUTERM			set this to "aqua" to make AquaTerm default output in Gnuplot
PGPLOT_DEV		set this to "/AQT" to make AquaTerm default output in PGPLOT

* AquaTerm changes
------------------
AquaTerm 1.0a1
  Complete rewrite with better possibilities for future optimization.
  Supports mouse and key events (events in general actually) (#538268, #586499)
  *** Not backwards compatible with old adapters *** (It could be fixed, but I don't have the time to do it...)
  Respects window size when updating (#650938)
  Make window front when updated (#651911)  
  Added debug menu including "Refresh view", a test view and feedback options.

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
AquaTerm 1.0a1
  General
    Moved all common code into libaquaterm.dylib, all adapters link with this.
    Complete rewrite of common code, no reliance on AppKit (#605549)
  Gnuplot
    Increased resolution (#783895)
  PGPLOT
    Mouse/keyboard support

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

* Future ToDo's:
- Add user settings for such things as default font etc.
- Add adapters for more legacy apps…

* Legalities

Copyright (c) 2001-2003, The AquaTerm project
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of the author nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
