package OTRS::OPM::Maker::Command::devunlink;

# ABSTRACT: unlink the package files into you local OTRS instance

use strict;
use warnings;

use File::Basename;
use File::Find::Rule;
use Path::Class ();

use OTRS::OPM::Maker -command;

sub abstract {
    return "(sym)unlink the package files into you local OTRS instance";
}

sub usage_desc {
    return "opmbuild devunlink <path_to_sopm> <path_to_otrs_instance>";
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
    my $path_str  = $path->absolute;
        
    my @files_in_fs = File::Find::Rule->file->in( $path_str );
    
    # do not install vcs files nor "hidden" files
    my @files =
        grep{ basename( $_ ) !~ /^\./ }
        grep{ $_ !~ /\.git|CVS|svn/ }@files_in_fs;

    my $otrs_dir = Path::Class::Dir->new( $args->[1] )->absolute;

    FILE:
    for my $file ( @files ) {
        (my $target = $file) =~ s{\Q$path_str}{$otrs_dir};
        
        if ( -l $target ) {
            
            # remove link only if it points to our current source
            if ( readlink $target eq $file ) {
                unlink $target or die "ERROR: Can't unlink symlink: $target";
                print "NOTICE: link from $target removed\n";
            }

            # restore target if there is a backup
            if ( -f "$target.old" ) {
                if ( rename "$target.old", $target ) {
                    print "NOTICE: Restored original file: $target\n";
                }
                else {
                    die "ERROR: Can't rename $target.old to $target: $!";
                }
            }
        }
    }
}

1;
