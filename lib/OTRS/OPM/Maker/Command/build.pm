package OTRS::OPM::Maker::Command::build;

use strict;
use warnings;

use MIME::Base64 ();
use Sys::Hostname;
use Path::Class ();
use XML::LibXML;

use OTRS::OPM::Maker -command;

sub abstract {
    return "build package files for OTRS";
}

sub usage_desc {
    return "opmbuild build <path_to_sopm>";
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
    
    my $hostname  = hostname;
    my @time      = localtime;
    my $timestamp = sprintf "%04d-%02d-%02d %02d:%02d:%02d", 
        $time[5]+1900, $time[4]+1, $time[3], 
        $time[2], $time[1], $time[0];
    
    my $parser = XML::LibXML->new;
    my $tree   = $parser->parse_file( $file );
    
    my $sopm_path = Path::Class::File->new( $file );
    my $path      = $sopm_path->dir;
    
    my $root_elem = $tree->getDocumentElement;
    
    # retrieve file information
    my @files = $root_elem->findnodes( 'Filelist/File' );
    
    FILE:
    for my $file ( @files ) {
        my $name         = $file->findvalue( '@Location' );
        my $file_path    = Path::Class::File->new( $path, $name );
        my $file_content = $file_path->slurp;
        my $base64       = MIME::Base64::encode( $file_content );
        
        $file->setAttribute( 'Encode', 'Base64' );
        $file->appendText( $base64 );
    }
    
    my $build_date = XML::LibXML::Element->new( 'BuildHost' );
    $build_date->appendText( $timestamp );
    
    my $build_host = XML::LibXML::Element->new( 'BuildHost' );
    $build_host->appendText( $hostname );
    
    $root_elem->addChild( $build_date );
    $root_elem->addChild( $build_host );
    
    my $version      = $root_elem->findvalue( 'Version' );
    my $package_name = $root_elem->findvalue( 'Name' );
    my $file_name    = sprintf "%s-%s.opm", $package_name, $version;
    
    my $opm_path = Path::Class::File->new( $path, $file_name );
    my $fh       = $opm_path->openw;
    $fh->print( $tree->toString );
}

1;