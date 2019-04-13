#!/usr/bin/perl
use strict;

use POSIX;
# args
#   --freq=<weekly/monthly>
#   --rootdir=<src>
#   --outdir=<dest>

my $rootdir = "/home/mtvaught";
my $outdir = "/home/mtvaught";
my $subdir = "tmp";
my $TAR = "tar";
my $TAR_FLAGS = "cf";
my $TAR_EXT = "tar";

my $TAR_CMD = "$TAR $TAR_FLAGS";

my $timestamp = strftime "%Y-%m-%d_%H-%M-GMT", gmtime time;

my $cmd = "cd $rootdir/$subdir && $TAR_CMD $outdir/$subdir-$timestamp.$TAR_EXT .";
print $cmd . "\n";

print  . "\n";
