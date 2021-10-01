package OPM::Maker::Command::sopmtest;

# ABSTRACT: Check if sopm is valid

use strict;
use warnings;

use Path::Class ();
use OPM::Validate;

use OPM::Maker -command;

sub abstract {
    return "check .sopm if it is valid";
}

sub usage_desc {
    return "opmbuild sopmtest <path_to_sopm>";
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
    
    my $file = $args->[0];

    if ( !defined $file ) {
        print "No file given!";
        return;
    }
    
    if ( !-f $file ) {
        print "$file does not exist";
        return;
    }

    eval {
        my $content = do{ local (@ARGV, $/) = $file; <> };
        OPM::Validate->validate( $content, 1 );
        1;
    } or do {
        print ".sopm is not valid: $@\n";
        return;
    };
    
    return 1;
}

1;

