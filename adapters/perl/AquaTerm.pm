package Graphics::AquaTerm;

use 5.008001;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Graphics::AquaTerm ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	AQT_EVENTBUF_SIZE
	aqtAddEdgeToVertex
	aqtAddFilledRect
	aqtAddImageWithBitmap
	aqtAddLabel
	aqtAddLineTo
	aqtAddPolygon
	aqtAddPolyline
	aqtAddTransformedImageWithBitmap
	aqtClearPlot
	aqtClosePlot
	aqtColormapSize
	aqtEraseRect
	aqtGetBackgroundColor
	aqtGetColor
	aqtGetColormapEntry
	aqtGetLastEvent
	aqtInit
	aqtMoveTo
	aqtMoveToVertex
	aqtOpenPlot
	aqtRenderPlot
	aqtResetImageTransform
	aqtSelectPlot
	aqtSetAcceptingEvents
	aqtSetBackgroundColor
	aqtSetClipRect
	aqtSetColor
	aqtSetColormapEntry
	aqtSetDefaultClipRect
	aqtSetEventHandler
	aqtSetFontname
	aqtSetFontsize
	aqtSetImageTransform
	aqtSetLineCapStyle
	aqtSetLinestylePattern
	aqtSetLinestyleSolid
	aqtSetLinewidth
	aqtSetPlotSize
	aqtSetPlotTitle
	aqtTakeBackgroundColorFromColormapEntry
	aqtTakeColorFromColormapEntry
	aqtTerminate
	aqtWaitNextEvent
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	AQT_EVENTBUF_SIZE
);

our $VERSION = '0.02';

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&Graphics::AquaTerm::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('Graphics::AquaTerm', $VERSION);

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

=head1 NAME

Graphics::AquaTerm - Perl extension to the Mac OS-X Graphics Program Aquaterm

=head1 SYNOPSIS

use Graphics::AquaTerm ':all';

  aqtInit();
  aqtOpenPlot(1);
  aqtSetPlotSize(400, 300);
  aqtSetPlotTitle("Graphics::Aquaterm");
  aqtSetColor(0.1, 0.5, 0.9);
  aqtSetBackgroundColor(1.0,1.0,0.5);
  aqtSetLinewidth(3.0);
  aqtMoveToVertex(100,100);
  aqtAddEdgeToVertex(200,120);
  aqtAddEdgeToVertex(180,200);
  aqtRenderPlot();

=head1 DESCRIPTION

This module allows you to interface directly to the AquaTerm Graphics Program
from Perl. Almost all of the sub-routines listed in aquaterm/aquaterm.h are
supported.

=head2 EXPORT

None by default.

=head2 Exportable constants

  AQT_EVENTBUF_SIZE

=head2 Exportable functions

  aqtAddEdgeToVertex($x, $y)
  aqtAddFilledRect($originX, $originY, $width, $height)
  aqtAddImageWithBitmap($bitmap, $pixWide, $pixHigh, $destX, $destY, $destWidth, $destHeight)
  aqtAddLabel($text, $x, $y, $angle, $align)
  aqtAddLineTo($x, $y)
  aqtAddPolygon(\@x, \@y)
  aqtAddPolyline(\@x, \@y)
  aqtAddTransformedImageWithBitmap($bitmap, $pixWide, $pixHigh, $clipX, $clipY, $clipWidth, $clipHeight)
  aqtClearPlot()
  aqtClosePlot()
  $map_size = aqtColormapSize()
  aqtEraseRect($originX, $originY, $width, $height)
  ($r, $g, $b) = aqtGetBackgroundColor()
  ($r, $g, $b) = aqtGetColor()
  ($r, $g, $b) = aqtGetColormapEntry($entryIndex)
  $event_string = aqtGetLastEvent()
  $did_init = aqtInit()
  aqtMoveTo($x, $y)
  aqtMoveToVertex($x, $y)
  aqtOpenPlot($refNum)
  aqtRenderPlot()
  aqtResetImageTransform()
  $did_select = aqtSelectPlot($refNum)
  aqtSetAcceptingEvents($flag)
  aqtSetBackgroundColor($r, $g, $b)
  aqtSetClipRect($originX, $originY, $width, $height)
  aqtSetColor($r, $g, $b)
  aqtSetColormapEntry($entryIndex, $r, $g, $b)
  aqtSetDefaultClipRect()
  aqtSetFontname($newFontname)
  aqtSetFontsize($newFontsize)
  aqtSetImageTransform($m11, $m12, $m21, $m22, $tX, $tY)
  aqtSetLineCapStyle($capStyle)
  aqtSetLinestylePattern(\@pattern, $phase)
  aqtSetLinestyleSolid();
  aqtSetLinewidth($newLinewidth)
  aqtSetPlotSize($width, $height)
  aqtSetPlotTitle($title)
  aqtTakeBackgroundColorFromColormapEntry($index)
  aqtTakeColorFromColormapEntry($index)
  aqtTerminate()
  $event_string = aqtWaitNextEvent()

  Exists, but not supported or functional :
    aqtSetEventHandler(void (*func)(int ref, const char *event))

=cut

#
# To make some of the aquaterm functions easier to use in Perl
# I've written some intermediary functions, these are below
#

## create a polygon from a series of x,y points

sub aqtAddPolygon{
	my ($x_Arr, $y_Arr) = @_;
	my $x_packedArr = pack("f*",@$x_Arr);
	my $y_packedArr = pack("f*",@$y_Arr);
	c_aqtAddPolygon($x_packedArr, $y_packedArr, 0+@$x_Arr);
}

## connects a series of x,y points by lines

sub aqtAddPolyline{
	my ($x_Arr, $y_Arr) = @_;
	my $x_packedArr = pack("f*",@$x_Arr);
	my $y_packedArr = pack("f*",@$y_Arr);
	c_aqtAddPolyline($x_packedArr, $y_packedArr, 0+@$x_Arr);
}

## get the last user event from AquaTerm
#
# FIXME: memory allocation is quick & dirty, is there a better way???

sub aqtGetLastEvent{
	my $event = '_' x 40;	# Q&D allocation
	my $ret = c_aqtGetLastEvent($event);
	if($ret){
		print ">> aqtGetLastEvent failed\n";
		$event = "";
	} else {
		$event =~ s![_]+$!!;
	}
	return $event;
}

## get the next user event from AquaTerm

sub aqtWaitNextEvent{
	my $event = '_' x 40; # Q&D allocation
	my $ret = c_aqtWaitNextEvent($event);
	if($ret){
		print ">> aqtWaitNextEvent failed\n";
		$event = "";
	} else {
		$event =~ s![_]+$!!;
	}
	return $event;
}

## pass a bitmap to AquaTerm
#
# FIXME: a string can't be the best format for a bitmap... convenient though...

sub aqtAddImageWithBitmap{
	my ($bitmap, $pixWide, $pixHigh, $destX, $destY, $destWidth, $destHeight) = @_;
	if((3 * $pixWide * $pixHigh) > length($bitmap)){
		print ">> aqtAddImageWithBitmap: bitmap is smaller then stated size\n";
		return;
	}
	c_aqtAddImageWithBitmap($bitmap, $pixWide, $pixHigh, $destX, $destY, $destWidth, $destHeight)
}

## pass a bitmap, to be transformed, to AquaTerm
#
# FIXME: a string can't be the best format for a bitmap... convenient though...

sub aqtAddTransformedImageWithBitmap{
	my ($bitmap, $pixWide, $pixHigh, $clipX, $clipY, $clipWidth, $clipHeight) = @_;
	if((3 * $pixWide * $pixHigh) > length($bitmap)){
		print ">> aqtAddTransformedImageWithBitmap: bitmap is smaller then stated size\n";
		return;
	}
	c_aqtAddTransformedImageWithBitmap($bitmap, $pixWide, $pixHigh, $clipX, $clipY, $clipWidth, $clipHeight);
}

sub aqtSetLinestylePattern{
	my ($pattern, $phase) = @_;
	my $pattern_packedArr = pack("f*",@$pattern);
	c_aqtSetLinestylePattern($pattern_packedArr, 0+@$pattern, $phase);
}

#
# end of Perl <-> C translation section
#

#
# warning messages for functions that are not currently implemented
#

sub aqtSetEventHandler{
	print ">> aqtSetEventHandler is not currently implemented\n";
}

=head1 A NOTE ON DISPLAYING BITMAPS

The bitmap display routines convert character strings into color intensities, following the ASCII standard for what character corresponds to what value (or so I believe). Bitmaps are RGB true color, i.e. the string "rgb" would be displayed as a single point with color values [r,g,b]. While convenient for me to implement, this may not be that convenient to use, so suggestions for a better approach are welcome.

=head1 KNOWN ISSUES

You should get the latest version of AquaTerm from CVS, or at least a version more recent then March 1, 2005, as not all the above functions existed in previous versions. Alternatively, you can of course just comment out the offending function in this file & in the .xs file.

=head1 BUGS

No known bugs yet.

=head1 SEE ALSO

AquaTerm, your friendly plotting front-end

http://aquaterm.sourceforge.net/

=head1 AUTHOR

Hazen Babcock, hbabcockos1 at mac.com

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Hazen Babcock

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut

__END__
1;
