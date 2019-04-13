#!/usr/bin/perl
use strict;
use warnings;

## Includes
use POSIX;
use Getopt::Long;
# args
#   --freq=<weekly/monthly>
#   --rootdir=<src>
#   --outdir=<dest>

## Constants
use constant {
    TAR                     => "tar",
    TAR_FLAGS               => "cf",
    TAR_FLAGS_ENCRYPT       => "czf",
    TAR_EXTENSION           => "tar",
    TAR_EXTENSION_ENCRYPT   => "tar.gz",
    WEEKLY                  => "weekly",
    MONTHLY                 => "monthly",
};

my $frequency;
my $root_dir;
my $out_dir;

GetOptions (
    "freq=s"    => \$frequency,
    "rootdir=s" => \$root_dir,
    "outdir=s"  => \$out_dir
) or die ("Error in command line arguments\n");

unless( defined($frequency) && defined($root_dir) && defined($root_dir))
{
    die "ERROR: Not all options are defined\n";
}

if($frequency ne WEEKLY && $frequency ne MONTHLY)
{
    die "ERROR: Invalid frequency selection: \"$frequency\"";
}
unless ( -e $root_dir && -d $root_dir )
{
    die "ERROR: root directory \"$root_dir\" is not valid";
}
unless ( -e $out_dir && -d $out_dir )
{
    die "ERROR: out directory \"$out_dir\" is not valid";
}

my $success = 1;

# TODO: pull this from an ENV variable (and sanitize)
my $encryption = 0;

my $sub_dir = "tmp";
my $archive_path;
$success = CreateArchive(\$archive_path, $root_dir, $sub_dir, $out_dir, $encryption);
print "success = $success\n";


my @file_list;
GetFilesInDirectory(\@file_list, $ENV{'PWD'}."/test/weekly");

foreach my $file (@file_list)
{
    print $file . "\n";
}

if($success == 1)
{
    exit(0);
}
else
{
    exit(-1);
}

###################### End of main ###########################

sub GetFilesInDirectory
{
    my ($file_list, $path) = @_;
    my $success = 1;

    unless ( -e $path && -d $path )
    {
        print "ERROR: unable to list directory \"$path\", does not exist\n";
        $success = 0;
    }
    
    if( $success == 1 )
    {
        my $dir;
        opendir ($dir, $path) or $success = 0;
        if($success == 1)
        {
            @$file_list = readdir($dir);
            closedir($dir);
        }
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


    unless ( -e $out_dir && -d $out_dir )
    {
        print "ERROR: output directory \"$out_dir\" does not exist\n";
        $success = 0;
    }
    unless ( -e $root_dir && -d $root_dir )
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

    my $tar_cmd;
    my $tar_dest;
    if($success == 1)
    {
        my $timestamp = strftime "%Y-%m-%d_%H-%M-GMT", gmtime time;

        if($encryption == 1)
        {
            $tar_cmd = TAR . ' ' . TAR_FLAGS_ENCRYPT;
            $tar_dest = "$out_dir/$sub_dir-$timestamp." . TAR_EXTENSION_ENCRYPT;
        }
        else
        {
            $tar_cmd = TAR . ' ' . TAR_FLAGS;
            $tar_dest = "$out_dir/$sub_dir-$timestamp." . TAR_EXTENSION;
        }
    }

    if($success == 1)
    {
        if ( -e $tar_dest )
        {
            print "ERROR: destination archive \"$tar_dest\" already exists\n";
            $success = 0;
        }
    }

    if($success == 1)
    {
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
