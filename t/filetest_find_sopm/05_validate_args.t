#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use File::Basename;
use File::Spec;

use OPM::Maker;
use OPM::Maker::Command::filetest;

my $filetest = OPM::Maker::Command::filetest->new({
    app => OPM::Maker->new
});

my $dir = File::Spec->catfile( dirname(__FILE__), '..', 'valid', 'TestSMTP');
chdir $dir;

my $args = [];

{
    my $error;
    eval { $filetest->validate_args(); 1;} or $error = $@;
    is $error, undef;
}

{
    my $error;
    eval { $filetest->validate_args( undef, undef ); 1;} or $error = $@;
    is $error, undef;
}

{
    my $error;
    eval { $filetest->validate_args( undef, {} ); 1;} or $error = $@;
    like $error, qr/Error: need path to .sopm/;
}

{
    my $error;
    eval { $filetest->validate_args( undef, [] ); 1;} or $error = $@;
    is $error, undef;
}

{
    my $error;
    eval { $filetest->validate_args( undef, [undef] ); 1;} or $error = $@;
    is $error, undef;
}

{
    my $error;
    eval { $filetest->validate_args( undef, ['test.txt'] ); 1;} or $error = $@;
    like $error, qr/Error: need path to .sopm/;
}

{
    my $error;
    eval { $filetest->validate_args( undef, ['o_o_m_c_b_does_not_exist.sopm'] ); 1;} or $error = $@;
    like $error, qr/Error: need path to .sopm/;
}

{
    my $file   = File::Spec->catfile( dirname(__FILE__), '..', 'valid', 'TestSMTP', 'TestSMTP.sopm' );
    my $error;
    eval { $filetest->validate_args( undef, [$file] ); 1;} or $error = $@;;
    like $error, qr/Error: need path to .sopm/;
}

done_testing;
