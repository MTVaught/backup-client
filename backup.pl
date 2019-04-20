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
    TAR_FLAGS               => "cf",
    TAR_FLAGS_COMPRESS       => "czf",
    TAR_EXTENSION           => "tar",
    TAR_EXTENSION_COMPRESS   => "tar.gz",
    WEEKLY                  => "weekly",
    MONTHLY                 => "monthly",
    GPG                     => "gpg",
    GPG_ENCRYPT             => "--symmetric",
    GPG_BATCH               => "--batch",
    GPG_PASSPHRASE          => "--passphrase",
    GPG_OUT                 => "-o",
    GPG_EXTENSION           => "gpg",
};

my $root_dir;
my $out_dir;
my $dry_run = 0;
my $gpg_passphrase;
my $gpg_out_dir;

GetOptions (
    "rootdir=s" => \$root_dir,
    "outdir=s"  => \$out_dir,
    "dryrun"    => \$dry_run,
    "gpgoutdir=s"    => \$gpg_out_dir,
    "gpg_passphrase=s"    => \$gpg_passphrase
) or die ("Error in command line arguments\n");

unless( defined($root_dir) && defined($out_dir))
{
    die "ERROR: Not all options are defined\n";
}

unless ( -e $root_dir && -d $root_dir )
{
    die "ERROR: root directory \"$root_dir\" is not valid";
}
unless ( -e $out_dir && -d $out_dir )
{
    die "ERROR: out directory \"$out_dir\" is not valid";
}
if (defined($gpg_passphrase))
{
    if ($gpg_passphrase eq "")
    {
        die "ERROR: empty gpg passphrase specified\n";
    }
    unless (defined($gpg_out_dir))
    {
        die "ERROR: undefined value for gpgoutdir";
    }
    unless ( -e $gpg_out_dir && -d $gpg_out_dir )
    {
        die "ERROR: gpg out directory \"$gpg_out_dir\" is not valid";
    }
    print $gpg_passphrase . "\n";
}

if($dry_run == 1)
{
    print "$root_dir\n";
}

my $success = 1;

# TODO: pull this from an ENV variable (and sanitize)
my $compression = 0;

my @file_list;
if($success == 1)
{
    $success = GetFilesInDirectory(\@file_list, $root_dir);
    unless($success == 1)
    {
        print "ERROR: Directory parse failed\n";
    }
}

if($dry_run == 1)
{
    foreach my $file (@file_list)
    {
        print "\t$file\n";
    }
}

my @archive_list;
if($success == 1 && $dry_run != 1)
{
    # Archive creation is best-effort. If one fails, keep trying the others.
    foreach my $sub_dir (@file_list)
    {
        my $archive_path;
        my $local_success = CreateArchive(\$archive_path, $root_dir, $sub_dir, $out_dir, $compression);

        if($local_success == 1)
        {
            my $encrypted_path;
            $success = EncryptFile(\$encrypted_path, $archive_path, $root_dir, $sub_dir, $gpg_out_dir, $gpg_passphrase);
            
            push(@archive_list, $archive_path);
            print "Created Archive: \"$archive_path\"\n";
        }
        else
        {
            $success = 0;
            print "ERROR: failed to archive \"$root_dir/$sub_dir\"\n";
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
    my ($archive_path, $root_dir, $sub_dir, $out_dir, $compression) = @_;
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

    my $dest_dir;
    if( $success == 1)
    {
        $dest_dir = "$out_dir/$sub_dir";
        my $mkdir_cmd = "mkdir -p $dest_dir";
        system($mkdir_cmd);

        unless ( -e $dest_dir && -d $dest_dir )
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
            $tar_dest = "$dest_dir/$sub_dir-$timestamp." . TAR_EXTENSION_COMPRESS;
        }
        else
        {
            $tar_cmd = TAR . ' ' . TAR_FLAGS;
            $tar_dest = "$dest_dir/$sub_dir-$timestamp." . TAR_EXTENSION;
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

    if($success == 1)
    {
        # TODO: change uid of file
    }

    if($success == 1)
    {
        # TODO: change gid of file
    }

    if($success == 1)
    {
        # TODO: change permissions of file
    }

    return $success;
}

sub EncryptFile
{
    my ($encrypted_path, $src_file, $root_dir, $sub_dir, $out_dir, $gpg_passphrase) = @_;
    my $success = 1;


    unless ( -e $out_dir && -d $out_dir )
    {
        print "ERROR: output directory \"$out_dir\" does not exist\n";
        $success = 0;
    }
    unless ( -e $src_file )
    {
        print "ERROR: source file \"$src_file\" does not exist\n";
        $success = 0;
    }

    my $dest_dir;
    if( $success == 1)
    {
        $dest_dir = "$out_dir/$sub_dir";
        my $mkdir_cmd = "mkdir -p $dest_dir";
        system($mkdir_cmd);

        unless ( -e $dest_dir && -d $dest_dir )
        {
            print "ERROR: output directory \"$dest_dir\" does not exist\n";
            $success = 0;
        }
    }

    my $gpg_cmd;
    my $gpg_dest;
    if($success == 1)
    {
        $src_file =~ m/[^\/]+$/;
        my $file_name = $&;
        $gpg_cmd = GPG 
                    . ' ' . GPG_BATCH
                    .' '. GPG_PASSPHRASE .' '. $gpg_passphrase
                    ;
        $gpg_dest = "$dest_dir/$file_name." . GPG_EXTENSION;
    }

    if($success == 1)
    {
        if ( -e $gpg_dest )
        {
            print "ERROR: destination archive \"$gpg_dest\" already exists\n";
            $success = 0;
        }
    }

    if($success == 1)
    {
        my $run_gpg_cmd = "$gpg_cmd " . GPG_OUT . " $gpg_dest"
                              .' '. GPG_ENCRYPT . " $src_file";
        
        print $run_gpg_cmd . "\n";

        my $output = `$run_gpg_cmd`;

        unless ($? == 0)
        {
            $success = 0;
            print "ERROR: gpg command failed:\n$output\n";
        }
    }

    if($success == 1)
    {
        $$encrypted_path = $gpg_dest;
    }

    if($success == 1)
    {
        # TODO: change uid of file
    }

    if($success == 1)
    {
        # TODO: change gid of file
    }

    if($success == 1)
    {
        # TODO: change permissions of file
    }

    return $success;
}

