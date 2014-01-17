package OTRS::OPM::Maker::Command::remote_install;

# ABSTRACT: install OTRS packages on a remote OTRS instance

use strict;
use warnings;

use OTRS::OPM::Maker -command;

our $VERSION = 0.07;

sub abstract {
    return "install package in OTRS instance";
}

sub usage_desc {
    return "opmbuild remote_install --host <host> --token <token> --user <user> [--test [--format <format>]] <path_to_opm>";
}

sub opt_spec {
    return (
        [ "host=s", "hostname of remote OTRS instance" ],
        [ "token=s", "API token for remote OTRS instance" ],
        [ "user=s", "username for remote OTRS instance" ],
        [ "test", "run tests on remote OTRS instance" ],
        [ "format", "format of test output (TAP or JUnit)" ],
    );
}

sub validate_args {
    my ($self, $opt, $args) = @_;
    
    $self->usage_error( 'need path to .opm' ) if
        !$args ||
        !$args->[0] ||
        !$args->[0] =~ /\.opm\z/ ||
        !-f $args->[0];
}

sub execute {
}

1;
