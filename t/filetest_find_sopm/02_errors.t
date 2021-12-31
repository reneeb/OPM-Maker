#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::LongString;
use Capture::Tiny qw(capture_stdout);

use File::Spec;
use File::Basename;
use File::Temp qw(tempdir);

use_ok 'OPM::Maker::Command::filetest';

my $dir  = File::Spec->catdir( dirname( __FILE__ ), qw/ .. invalid / );
chdir $dir;

my $args = [];


{
    my $error = 'Files listed in .sopm but not found on disk:
    - Kernel/Config/Files/TestSMTP.xml
    - Kernel/System/Email.pm
';

    my $exec_output = capture_stdout {
        OPM::Maker::Command::filetest::execute( undef, {}, $args );
    };

    #diag $exec_output;

    like_string $exec_output, qr/$error/;

    $error = 'Files found on disk but not listed in .sopm:
    - invalid.sopm
    - test.sopm
';

    like_string $exec_output, qr/$error/;
}

done_testing();