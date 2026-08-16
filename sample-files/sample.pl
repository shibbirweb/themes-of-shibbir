#!/usr/bin/env perl
#
# Perl sample: sigils, regex, hashes, references, heredocs, POD.

use strict;
use warnings;
use feature qw(say signatures);
no warnings 'experimental::signatures';

use Data::Dumper;
use List::Util qw(first reduce sum0);

our $VERSION = '1.0.0';

use constant {
    DEFAULT_HEX => '#EEFFFF',
    MAX_DEPTH   => 8,
};

my $hex_pattern = qr/^#(?:[0-9a-fA-F]{3}){1,2}$/;

my %palette = (
    background => '#263238',
    foreground => '#EEFFFF',
    keyword    => '#C792EA',
    string     => '#C3E88D',
);

my @ordered = sort keys %palette;
my $count   = scalar @ordered;

sub luminance ($hex) {
    my ($red, $green, $blue) = $hex =~ /^#(..)(..)(..)$/
        or return -1;

    return (0.2126 * hex($red) + 0.7152 * hex($green) + 0.0722 * hex($blue)) / 255;
}

sub describe ($label, $hex = DEFAULT_HEX) {
    die "Invalid hex value: $hex\n" unless $hex =~ $hex_pattern;

    return sprintf('%-12s => %s', $label, $hex);
}

sub build_registry (%args) {
    my $name    = delete $args{name}   // 'unnamed';
    my $strict  = delete $args{strict} // 0;

    return {
        name     => $name,
        strict   => $strict,
        swatches => { %args },
    };
}

my $registry = build_registry(name => 'Themes of Shibbir', strict => 1, %palette);

foreach my $label (@ordered) {
    my $hex = $palette{$label};

    eval {
        say describe($label, $hex), sprintf('  luminance=%.4f', luminance($hex));
        1;
    } or do {
        warn "skipped $label: $@";
    };
}

my @dark = grep { luminance($palette{$_}) < 0.5 } @ordered;
my $first_light = first { luminance($palette{$_}) >= 0.5 } @ordered;
my $total = sum0(map { length $_ } @ordered);

(my $slug = lc $registry->{name}) =~ s/[^a-z0-9]+/-/g;
$slug =~ s/^-|-$//g;

print <<"SUMMARY";
Registry: $registry->{name}
Slug:     $slug
Swatches: $count
Dark:     @{[ scalar @dark ]}
Light:    ${\ ($first_light // 'none') }
Depth:    @{[ MAX_DEPTH ]}
SUMMARY

print <<'LITERAL';
Single-quoted heredoc: $registry is not interpolated here.
LITERAL

local $Data::Dumper::Indent = 1;
print Dumper($registry->{swatches}) if $ENV{DEBUG};

__END__

=head1 NAME

sample.pl - a Perl fixture for previewing the theme

=head1 DESCRIPTION

POD blocks use their own scopes, so this section should render differently
from the code above it.

=cut
