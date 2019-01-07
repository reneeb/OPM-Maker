package OTRS::OPM::Maker::Command::dbtest;

# ABSTRACT: Test db definitions in .sopm files

use strict;
use warnings;

use OTRS::OPM::Maker -command;

our $VERSION = '0.14';

sub abstract {
    return "Check if DatabaseInstall and DatabaseUninstall sections in the .sopm are correct";
}

sub usage_desc {
    return "opmbuild dbtest <path_to_sopm>";
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    $self->usage_error( 'need path to .sopm' ) if
        !$args or
        'ARRAY' ne ref $args or
        !defined $args->[0] or
        $args->[0] !~ /\.sopm\z/ or
        !-f $args->[0];
}

sub execute {
    my ($self, $opt, $args) = @_;
}

1;
