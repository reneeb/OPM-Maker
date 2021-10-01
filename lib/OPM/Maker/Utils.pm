package OPM::Maker::Utils;

# ABSTRACT: Utility functions for OPM::Maker

use strict;
use warnings;

use Exporter 'import';

our @EXPORT_OK = qw(reformat_size);

sub reformat_size {
    my ($size) = @_;

    $size =~ m{\A(?<count>[0-9]+)(?<unit>[MmGgKk])?\z};

    return 0 if !$+{count};

    my $unit = lc( $+{unit} // 'b' );

    my $factor =
        $unit eq 'k' ? 1024 :
            $unit eq 'm' ? 1024 * 1024 :
                $unit eq 'g' ? 1024 * 1024 * 1024:
                1;
    ;

    return $+{count} * $factor;
}

1;

=head1 FUNCTIONS

=head2 reformat_size

reformat size

  15000 -> 15000
  15k   -> 15360        ( 15 * 1024 )
  15m   -> 15728640     ( 15 * 1024 * 1024 )
  15g   -> 16106127360  ( 15 * 1024 * 1024 * 1024)

