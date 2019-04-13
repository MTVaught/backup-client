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

my @file_list;
GetFilesInDirectory(\@file_list, $ENV{'PWD'}."/test/weekly");

foreach my $file (@file_list)
{
    print $file . "\n";
}
# Get all files in directory:

sub GetFilesInDirectory
{
    my ($file_list, $path) = @_;
    my $success = 1;
    
    my $dir;
    opendir ($dir, $path) or $success = 0;
    if($success == 1)
    {
        @$file_list = readdir($dir);
        closedir($dir);
    }
    
    if($success)
    {
        my $index = 0;
        while($index < scalar(@$file_list))
        {
            my $file = $$file_list[$index];
            if($file eq "." || $file eq "..")
            {
                splice(@$file_list, $index, 1);
            }
            else
            {
                $index++;
            }
        }
    }
    return $success;
}
