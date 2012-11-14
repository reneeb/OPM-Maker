package OTRS::OPM::Maker::Command::filetest;

# ABSTRACT: check if filelist in .sopm includes the files on your disk

use strict;
use warnings;

use File::Find::Rule;
use Path::Class ();
use XML::LibXML;

use OTRS::OPM::Maker -command;

sub abstract {
    return "Check if filelist in .sopm includes the files on your disk";
}

sub usage_desc {
    return "opmbuild filetest <path_to_sopm>";
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    
    $self->usage_error( 'need path to .sopm' ) if
        !$args ||
        !$args->[0] ||
        !$args->[0] =~ /\.sopm\z/ ||
        !-f $args->[0];
}

sub execute {
    my ($self, $opt, $args) = @_;
    
    my $file = $args->[0];
    my $parser = XML::LibXML->new;
    my $tree   = $parser->parse_file( $file );
    
    my $sopm_path = Path::Class::File->new( $file );
    my $path      = $sopm_path->dir;
    
    my $path_str     = $path->stringify;
    my $ignore_files = File::Find::Rule->file->name(".*");    
    my @files_in_fs  = File::Find::Rule->file
        ->not( $ignore_files )
        ->in ( $path_str );
    
    my %fs = map{ $_ =~ s{$path_str/?}{}; $_ => 1 }
        grep{ $_ !~ /\.git|CVS|svn/ }@files_in_fs;
        
    delete $fs{ $sopm_path->basename };
    
    my $root_elem = $tree->getDocumentElement;
    
    # retrieve file information
    my @files = $root_elem->findnodes( 'Filelist/File' );
    
    my @not_found;
    
    FILE:
    for my $file ( @files ) {
        my $name         = $file->findvalue( '@Location' );
        
        push @not_found, $name if !delete $fs{$name};
    }
    
    if ( @not_found ) {
        print "Files listed in .sopm but not found on disk:\n",
            map{ "    - $_\n" }@not_found;
    }
    
    if ( %fs ) {
        print "Files found on disk but not listed in .sopm:\n",
            map{ "    - $_\n" }keys %fs;
    }
}

1;
