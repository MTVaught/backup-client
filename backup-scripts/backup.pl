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
    TAR_CREATE              => "tar --create",
    TAR_OUT_FILE            => "--file",
    TAR_SNAPSHOT_FILE       => "--listed-incremental",
    TAR_EXTENSION           => "tar",
    SNAPSHOT_EXTENSION      => "snar",
};

my $quarterly_level_0_dir = "";
my $monthly_level_0_dir = "";
my $weekly_level_0_dir = "";

my $in_dir;
my $subdir_in_dir;
my $out_dir;
my $timeframe;
my $dry_run = 0;

GetOptions (
    "indir=s"     => \$in_dir,
    "insubdir=s"  => \$subdir_in_dir,
    "outdir=s"    => \$out_dir,
    "timeframe=s" => \$timeframe,
    "dryrun"      => \$dry_run
) or die ("Error in command line arguments\n");

my $zero_idx_month = `date +%m` - 1;
my $quarter = int($zero_idx_month / 3) + 1;

$quarterly_level_0_dir = `date +%Y_Q`;
chomp($quarterly_level_0_dir);
$quarterly_level_0_dir .= $quarter;

$monthly_level_0_dir = `date +%Y_%m`;
chomp($monthly_level_0_dir);

$weekly_level_0_dir = `date +%Y_W%U`;
chomp($weekly_level_0_dir);

unless( $quarterly_level_0_dir =~ /\d{4}_Q[1-4]{1}/)
{
    die "Unexpected pattern for quarterly dir: \"$quarterly_level_0_dir\"\n";
}

unless( $monthly_level_0_dir =~ /\d{4}_[0-1]\d/)
{
    die "Unexpected pattern for monthly dir: \"$monthly_level_0_dir\"\n";
}

unless( $weekly_level_0_dir =~ /\d{4}_W[0-5]\d/)
{
    die "Unexpected pattern for weekly dir: \"$weekly_level_0_dir\"\n";
}

unless( defined($in_dir))
{
    die "ERROR: indir not defined\n";
}

unless(defined($out_dir))
{
    die "ERROR: outdir not defined\n";
}


unless(defined($subdir_in_dir))
{
    die "ERROR: subdir not defined\n";
}

unless(defined($timeframe))
{
    die "ERROR: timeframe not defined\n";
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

$timeframe = lc($timeframe);

my $output_dated_subdir;
if($timeframe eq "quarter")
{
    $output_dated_subdir = $quarterly_level_0_dir;
}
elsif($timeframe eq "month")
{
    $output_dated_subdir = $monthly_level_0_dir;
}
elsif($timeframe eq "week")
{
    $output_dated_subdir = $weekly_level_0_dir;
}
else
{
    die("ERROR: unsupported timeframe \"$timeframe\". Must be either \"quarter\", \"month\", or \"week\".");
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
        my $local_success = CreateArchive(\$archive_path, $archive_in_dir, $archive_in_file, $out_dir, $archive_name, $output_dated_subdir);

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
    my ($archive_path, $in_dir, $in_file, $out_dir, $archive_name, $output_dated_subdir) = @_;
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
        $dest_dir = "$out_dir/$archive_name/$output_dated_subdir";
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

        $tar_dest = "$dest_dir/$archive_name-$output_dated_subdir-$timestamp.".TAR_EXTENSION;
        my $tar_snapshot = "$dest_dir/$archive_name-$output_dated_subdir.".SNAPSHOT_EXTENSION;
        $tar_cmd = TAR_CREATE.' '
                    .TAR_OUT_FILE."=\"$tar_dest\" "
                    .TAR_SNAPSHOT_FILE."=\"$tar_snapshot\"";

        if ( -e $tar_dest )
        {
            print "ERROR: destination archive \"$tar_dest\" already exists\n";
            $success = 0;
        }

    }

    if($success == 1)
    {
        my $run_cd_cmd = "cd \"$in_dir\"";
        my $run_tar_cmd = "$tar_cmd \"$in_file\"";
        
        my $run_cmd = "$run_cd_cmd && $run_tar_cmd";
        print $run_cmd . "\n";

        my $output = `$run_cmd`;
        my $rc = $?;
        print "$output\n";

        unless ($rc == 0)
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


