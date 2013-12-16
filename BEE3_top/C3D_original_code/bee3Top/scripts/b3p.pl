#!/usr/bin/perl

# This script generates the necessary commnd line batch file
# for iMPACT for programming the bee3 boards
# Saar Drimer, 2009-01-06

use strict;

# source Xilinx tools on "jowissa"
system('source /local/scratch/comparch/Xilinx/ISE10.1/ISE/settings64.sh');

my $numArgs = $#ARGV + 1;

# usb ports of bee3 boards in order (must be lowercase)
my @usbports = ('usb21', 'usb22', 'usb23');

# check for number of arguments
if (($numArgs != 2) and ($numArgs != 5)) {
    die "Wrong number of arguments";
}

my @boards = split(//, $ARGV[0]);
my @bitstream;

$bitstream[0] = $ARGV[1];

# assign bitstream names to variables
if ($ARGV[2] ne '') {
  $bitstream[1] = $ARGV[2];
} else {
  $bitstream[1] = $ARGV[1];
}
if ($ARGV[3] ne '') {
  $bitstream[2] = $ARGV[3];
} else {
  $bitstream[2] = $ARGV[1];
}
if ($ARGV[4] ne '') {
  $bitstream[3] = $ARGV[4];
} else {
  $bitstream[3] = $ARGV[1];
}

my $i = 0;
print "Programming boards: ";

foreach my $tmp (@boards) {
  $i++;
  if ($tmp ne '0') {
    print "$i ";
  }
}

print "\n";

$i = 1;

# create command file for batch mode
open (CMD, ">impactbatch.cmd");

foreach (@boards) {
  if ($_ ne '0') {
    print CMD "setMode -bscan\n";
    print CMD "setCable -p $usbports[$i-1]\n";
    print CMD "identify\n";

    my $j = 1;

    # assign bitstream to each device
    foreach my $tmp (@bitstream) {
      $j++;
      if (($tmp ne 0) and ($tmp ne '')) {
        print CMD "assignFile -p $j -file $tmp.bit\n";
      }
    }

    $j = 1;

    # program devices 
    foreach my $tmp (@bitstream) {
      $j++;
      if (($tmp ne 0) and ($tmp ne '')) {
        print CMD "program -p $j\n";
        #print CMD "program -v -p $i\n"; # use this to add verification (takes longer)
      }
    }

    print CMD "closeCable\n\n";
  }

  $i++;

}

  #saveCDF -file impactbatch.cdf

print CMD "quit\n";
  
close(CMD);

# call iMPACT to execute command file
system("impact -batch impactbatch.cmd");

exit 0;
