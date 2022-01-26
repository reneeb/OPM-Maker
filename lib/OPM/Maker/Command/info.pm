package OPM::Maker::Command::info;


use strict;
use warnings;

# ABSTRACT: show version info about opmbuild commands

use Carp qw(croak);
use OPM::Maker -command;
use HTTP::Tiny;
use JSON::PP;

sub abstract {
    return "show version info about opmbuild commands";
}

sub opt_spec {
    return (
        [ 'no-cpan-info', 'Do not get information about the distribution that ships a command' ],
    );
}


sub usage_desc {
    return "opmbuild info [--no-cpan-info]";
}

sub execute {
    my ($self, $opt, $args) = @_;

    my $app = $self->app;
    my $ua  = HTTP::Tiny->new;

    my %commands = map {
        my ($short) = (split /::/, $_)[-1];
        $short => $_;
    } grep {
        $_ =~ m{\AOPM::Maker::Command};
    } $app->command_plugins;

    CMD:
    for my $cmd ( sort keys %commands ) {
        my $module = $commands{$cmd};

        print sprintf "%s:\n  version: %s\n  module: %s\n", $cmd, $module->VERSION(), $module;

        if ( !$opt->{no_cpan_info} ) {
            my $json     = _json( $module, $module->VERSION() );
            my $response = $ua->post(
                'https://fastapi.metacpan.org/v1/file/_search', {
                    content => $json,
                }
            );

            next CMD if !$response->{success};

            my ($dist, $version) = _from_json( $response->{content} );

            next CMD if !$dist;

            print sprintf "  dist: %s\n  dist-version: %s\n", $dist, $version;
        }
    }
}

sub _from_json {
    my ($json) = @_;

    my $data   = JSON::PP->new->utf8(1)->decode( $json );
    my $fields = $data->{hits}->{hits}->[0]->{fields} || {};

    return @{ $fields }{qw/distribution version/};
}

sub _json {
    my ($module, $version) = @_;

    my $dots = $version =~ tr/././;

    $version = 'v' . $version if $dots > 1;
    return JSON::PP->new->utf8(1)->encode({
        "query" => {
            "filtered" => {
                "query" => {
                    "match_all" => {},
                },
                "filter" => {
                    "and" => [
                        {
                            "term" => {
                                "module.name" => $module,
                            },
                        },
                        {
                            "term" => {
                                "module.version" => $version,
                            },
                        },
                    ],
                },
            },
        },
        "fields" => ["release","distribution","version"],
    });
}

1;

__END__

=head1 DESCRIPTION

This command will show some information about opmbuild and its commands.
If I<--no-cpan-info> is omitted, it will show the name of the distribution
that ships the command.
