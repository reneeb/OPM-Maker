package OTRS::OPM::Maker::Command::devlink;

# ABSTRACT: link the package files into you local OTRS instance

use strict;
use warnings;

use File::Basename;
use File::Find::Rule;
use Path::Class ();

use OTRS::OPM::Maker -command;

sub abstract {
    return "(sym)link the package files into you local OTRS instance";
}

sub usage_desc {
    return "opmbuild devlink <path_to_sopm> <path_to_otrs_instance>";
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    
    $self->usage_error( 'need path to .sopm' ) if
        !$args ||
        !$args->[0] ||
        !$args->[0] =~ /\.sopm\z/ ||
        !-f $args->[0];
    
    $self->usage_error( 'need path to otrs instance' ) if
        !$args->[1] ||
        !-d $args->[1] ||
        !-f $args->[1] . '/Kernel/Config.pm';
}

sub execute {
    my ($self, $opt, $args) = @_;
    
    my $sopm_file = $args->[0];
    my $sopm_path = Path::Class::File->new( $sopm_file );
    my $path      = $sopm_path->dir;
    my $path_str  = $path->stringify;
        
    my @files_in_fs = File::Find::Rule->file->in( $path_str );
    
    # do not install vcs files nor "hidden" files
    my @files =
        grep{ basename( $_ ) !~ /^\./ }
        grep{ $_ !~ /\.git|CVS|svn/ }@files_in_fs;

    my $otrs_dir = Path::Class::Dir->new( $args->[1] )->absolute;

    FILE:
    for my $file ( @files ) {
        (my $target = $file) =~ s{$path_str}{$otrs_dir};
        
        my $target_dir = dirname $target;
        
        if ( !-d $target_dir ) {
            my $dir_obj    = Path::Class::Dir->new( $target_dir );
            $dir_obj->mkdir;
        }
        
        if (-l $target) {
            # skip if already linked correctly
            if ( readlink $target eq $file) {
                print "NOTICE: link from $target is ok\n";
                next FILE;
            }

            # remove link to some different file
            unlink $target or die "ERROR: Can't unlink symlink: $target";
        }

        # backup target if it already exists as a file
        if (-f $target) {
            if ( rename $target, "$target.old" ) {
                print "NOTICE: created backup for original file: $target.old\n";
            }
            else {
                die "ERROR: Can't rename $target to $target.old: $!";
            }
        }

        # link source into target
        if ( !-e $file ) {
            die "ERROR: No such source file: $file";
        }
        elsif ( !symlink $file, $target ) {
            die "ERROR: Can't link $file to $target: $!";
        }
        else {
            print "NOTICE: Link: $file\n";
            print "NOTICE:    -> $target\n";
        }
    }
}

1;
