#!/usr/bin/perl
use strict;

use POSIX;
# args
#   --freq=<weekly/monthly>
#   --rootdir=<src>
#   --outdir=<dest>

my $TAR = "tar";
my $TAR_FLAGS = "cf";
my $TAR_FLAGS_ENCRYPT = "czf";
my $TAR_EXT = "tar";
my $TAR_EXT_ENCRYPT = "tar.gz";

my $rootdir = "/home/mtvaught";
my $outdir = "/home/mtvaught";
my $subdir = "tmp";

my $encryption = 0;
my $archive_path;
my $success = CreateArchive(\$archive_path, $rootdir, $subdir, $outdir, $encryption);
print "success = $success\n";


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

sub CreateArchive
{
    my ($archive_path, $root_dir, $sub_dir, $out_dir, $encryption) = @_;
    my $success = 1;

    my $tar_cmd;
    my $tar_dest;

    unless ( -e $out_dir )
    {
        print "ERROR: output directory \"$out_dir\" does not exist\n";
        $success = 0;
    }
    unless ( -e $root_dir )
    {
        print "ERROR: source directory \"$root_dir\" does not exist\n";
        $success = 0;
    }
    unless ( -e $root_dir )
    {
        print "ERROR: source directory \"$root_dir\" does not exist\n";
        $success = 0;
    }
    if( $success == 1 )
    {
        my $source_file = "$root_dir/$sub_dir";
        unless ( -e $source_file )
        {
            print "ERROR: source file \"$source_file\" does not exist\n";
            $success = 0;
        }
    }

    if($success == 1)
    {
        my $timestamp = strftime "%Y-%m-%d_%H-%M-GMT", gmtime time;

        if($encryption == 1)
        {
            $tar_cmd = "$TAR $TAR_FLAGS_ENCRYPT";
            $tar_dest = "$out_dir/$sub_dir-$timestamp.$TAR_EXT_ENCRYPT";
        }
        else
        {
            $tar_cmd = "$TAR $TAR_FLAGS";
            $tar_dest = "$out_dir/$sub_dir-$timestamp.$TAR_EXT";
        }

        my $run_cd_cmd = "cd $root_dir";
        my $run_tar_cmd = "$tar_cmd $tar_dest $sub_dir";
        
        my $run_cmd = "$run_cd_cmd && $run_tar_cmd";
        print $run_cmd . "\n";
        my $output = `$run_cmd`;

        system($run_cmd);

        unless ($? == 0)
        {
            $success = 0;
            print "ERROR: tar command failed:\n$output\n";
        }
    }
    return $success;
}
