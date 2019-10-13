#!/usr/bin/perl
use strict;
use warnings;

## Includes
use POSIX;
use Getopt::Long;
# args
#   --rootdir=<src>
#   --outdir=<dest>

## Constants
use constant {
    TAR                     => "tar",
    TAR_FLAGS               => "cWf",
    TAR_FLAGS_COMPRESS       => "czWf",
    TAR_EXTENSION           => "tar",
    TAR_EXTENSION_COMPRESS   => "tar.gz",
};

my $in_dir;
my $subdir_in_dir;
my $out_dir;
my $dry_run = 0;

GetOptions (
    "indir=s" => \$in_dir,
    "insubdir=s" => \$subdir_in_dir,
    "outdir=s"  => \$out_dir,
    "dryrun"    => \$dry_run
) or die ("Error in command line arguments\n");

unless( defined($in_dir) && defined($out_dir) && defined($subdir_in_dir))
{
    die "ERROR: Not all options are defined\n";
}

unless ( IsDir($in_dir) )
{
    die "ERROR: root directory \"$in_dir\" is not valid";
}
unless ( IsDir($subdir_in_dir) )
{
    die "ERROR: root directory \"$subdir_in_dir\" is not valid";
}
unless ( IsDir($out_dir) )
{
    die "ERROR: out directory \"$out_dir\" is not valid";
}

my $success = 1;


my @file_list;
if($success == 1)
{
    my @in_file_list;
    $success = GetFilesInDirectory(\@in_file_list, $in_dir);
    unless($success == 1)
    {
        print "ERROR: Directory parse failed\n";
    }

    foreach my $file (@in_file_list)
    {
        my %hash;
        $hash{'root'} = $in_dir;
        # $hash{'subdir'} = NULL;
        $hash{'file'} = $file;
        push(@file_list, \%hash);
    }
}

# Parse the subdir folder. Directory structure is:
# subdir_in/mounted volume/dir_to_tar
# If mounted volume is not a dir, skip it
if($success == 1)
{
    my @root_file_list;
    $success = GetFilesInDirectory(\@root_file_list, $subdir_in_dir);
    if($success == 1)
    {
        foreach my $subdir (@root_file_list)
        {
            my $path_to_subdir = "${subdir_in_dir}/${subdir}";
            if (IsDir($path_to_subdir))
            {
                my @subdir_list;
                my $local_success = GetFilesInDirectory(\@subdir_list, $path_to_subdir);
                if($local_success == 1)
                {
                    foreach my $file (@subdir_list)
                    {
                        my %hash;
                        $hash{'root'} = $subdir_in_dir;
                        $hash{'subdir'} = $subdir;
                        $hash{'file'} = $file;
                        push(@file_list, \%hash);
                    }
                }
                else
                {
                    print "ERROR: unable to list file in $path_to_subdir\n";
                }
            }
            else
            {
                print "ERROR: ${path_to_subdir} is not a directory, skipping.\n";
            }
        }
    }
    else
    {
        print "ERROR: Root subdir parse failed\n";
    }
}

if($dry_run == 1)
{
    print "files to archive:\n";
    foreach my $file_hash (@file_list)
    {
        my $root_path = $file_hash->{'root'};
        my $subdir = ".";
        my $file = $file_hash->{'file'};
        if(defined($file_hash->{'subdir'}))
        {
            $subdir = $file_hash->{'subdir'};
        }
        print "\t${root_path}/${subdir}/${file}\n";
    }
}

my @archive_list;
if($success == 1 && $dry_run != 1)
{
    # Archive creation is best-effort. If one fails, keep trying the others.
    foreach my $in_src_hash (@file_list)
    {
        my $root_path = $in_src_hash->{'root'};
        my $subdir = ".";
        my $file = $in_src_hash->{'file'};

        my $archive_name = $file;

        if(defined($in_src_hash->{'subdir'}))
        {
            $subdir = $in_src_hash->{'subdir'};
            $archive_name = "${subdir}.${file}";
        }

        my $archive_in_dir = "${root_path}/${subdir}";
        my $archive_in_file = $file;
        my $compression = 0;
        my $archive_path;
        my $local_success = CreateArchive(\$archive_path, $archive_in_dir, $archive_in_file, $out_dir, $archive_name, $compression);

        if($local_success == 1)
        {
            push(@archive_list, $archive_path);
            print "Created Archive: \"$archive_path\"\n";
        }
        else
        {
            $success = 0;
            print "ERROR: failed to archive \"${archive_in_dir}/${archive_in_file}\"\n";
        }
    }
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

sub IsDir
{
    my ($dir) = @_;
    return ( -e $dir && -d $dir );
}

sub GetFilesInDirectory
{
    my ($file_list, $path) = @_;
    my $success = 1;

    unless ( IsDir($path) )
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
    my ($archive_path, $in_dir, $in_file, $out_dir, $archive_name, $compression) = @_;
    my $success = 1;

    unless ( IsDir($in_dir))
    {
        print "ERROR: input directory \"$in_dir\" does not exist\n";
        $success = 0;
    }
    unless ( -e "$in_dir/$in_file" )
    {
        print "ERROR: source file \"$in_file\" does not exist\n";
        $success = 0;
    }
    unless ( IsDir($out_dir) )
    {
        print "ERROR: output directory \"$out_dir\" does not exist\n";
        $success = 0;
    }

    my $dest_dir;
    if( $success == 1)
    {
        $dest_dir = "$out_dir/$archive_name";
        my $mkdir_cmd = "mkdir -p \"$dest_dir\"";
        system($mkdir_cmd);

        unless ( IsDir($dest_dir) )
        {
            print "ERROR: output directory \"$dest_dir\" does not exist\n";
            $success = 0;
        }
    }

    my $tar_cmd;
    my $tar_dest;
    if($success == 1)
    {
        my $timestamp = strftime "%Y-%m-%d_%H-%M-GMT", gmtime time;

        if($compression == 1)
        {
            $tar_cmd = TAR . ' ' . TAR_FLAGS_COMPRESS;
            $tar_dest = "$dest_dir/$archive_name-$timestamp." . TAR_EXTENSION_COMPRESS;
        }
        else
        {
            $tar_cmd = TAR . ' ' . TAR_FLAGS;
            $tar_dest = "$dest_dir/$archive_name-$timestamp." . TAR_EXTENSION;
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
        my $run_cd_cmd = "cd \"$in_dir\"";
        my $run_tar_cmd = "$tar_cmd \"$tar_dest\" \"$in_file\"";
        
        my $run_cmd = "$run_cd_cmd && $run_tar_cmd";
        print $run_cmd . "\n";

        my $output = `$run_cmd`;
        print "$output\n";

        unless ($? == 0)
        {
            $success = 0;
            print "ERROR: tar command failed:\n$output\n";
        }
    }

    if($success == 1)
    {
        $$archive_path = $tar_dest;
    }

    return $success;
}


