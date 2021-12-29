package OPM::Maker::Command::dbtest;

# ABSTRACT: Test db definitions in .sopm files

use strict;
use warnings;

use OPM::Maker -command;

use OPM::Maker::Utils qw(check_args_sopm);

sub abstract {
    return "Check if DatabaseInstall and DatabaseUninstall sections in the .sopm are correct";
}

sub usage_desc {
    return "opmbuild dbtest <path_to_sopm>";
}

sub validate_args {
    my ($self, $opt, $args) = @_;

    my $sopm = check_args_sopm( $args );

    $self->usage_error( 'need path to .sopm' ) if
        !$sopm;
}

sub execute {
    my ($self, $opt, $args) = @_;

    die "not implemented yet";
}

1;
