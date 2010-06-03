#!/usr/bin/perl

# tests for bug report fixes or patches.

use strict;
$^W = 1;

use Test::More tests => 53;


BEGIN { $ENV{PERL_TEXT_CSV} = $ARGV[0] || 0; }

BEGIN {
    require_ok "Text::CSV";
    plan skip_all => "Cannot load Text::CSV" if $@;
}

#warn Text::CSV->backend;

my $csv = Text::CSV->new( { sep_char => "\t", blank_is_undef => 1, allow_whitespace => 1 } );

ok $csv->parse(qq|John\t\t"my notes"|);

is_deeply ([ $csv->fields ], [ "John", undef, "my notes" ], "Tab with allow_white_space");



# 2009-04-23 rt#45215

my $str = "this,is,some,csv,data\n";

$csv = Text::CSV->new;
$csv->parse($str);

is( $csv->string, $str );

#=pod

# 2009-05-16
# getline() handles having escaped null

my $opts = {
  'escape_char' => '"',
  'quote_char' => '"',
  'binary' => 1,
  'sep_char' => ','
};

my $eol  = "\r\n";
my $blob = ( join "", map { chr $_ } 0 .. 255 ) x 1;
#my $blob = ( join "", map { chr $_ } 0 .. 2 ) x 1;

$csv = Text::CSV->new( $opts );

open( FH, '>__test.csv' ) or die $!;
binmode FH;

# writting
ok( $csv->print( *FH, [ $blob ] ) );
close( FH );

# reading
open( FH, "__test.csv" ) or die $!;
binmode FH;

$opts->{eol} = $eol;
$csv = Text::CSV->new( $opts );

ok( my $colref = $csv->getline( *FH ) );

is( $colref->[0], $blob, "blob" );

close( FH );

#exit;
unlink( '__test.csv' );

#=cut

# 2009-07-30
# getline() handles a 0 staring multiline


# writting
open( FH, '>__test.csv' ) or die $!;
binmode FH;


ok( $csv->print( *FH, [ "00" ] ) );
ok( $csv->print( *FH, [ "\00" ] ) );
ok( $csv->print( *FH, [ "0\0" ] ) );
ok( $csv->print( *FH, [ "\0\0" ] ) );

ok( $csv->print( *FH, [ "0\n0" ] ) );
ok( $csv->print( *FH, [ "\0\n0" ] ) );
ok( $csv->print( *FH, [ "0\n\0" ] ) );
ok( $csv->print( *FH, [ "\0\n\0" ] ) );

ok( $csv->print( *FH, [ "\"0\n0" ] ) );
ok( $csv->print( *FH, [ "\"\0\n0" ] ) );
ok( $csv->print( *FH, [ "\"0\n\0" ] ) );
ok( $csv->print( *FH, [ "\"\0\n\0" ] ) );

ok( $csv->print( *FH, [ "\"0\n\"0" ] ) );
ok( $csv->print( *FH, [ "\"\0\n\"0" ] ) );
ok( $csv->print( *FH, [ "\"0\n\"\0" ] ) );
ok( $csv->print( *FH, [ "\"\0\n\"\0" ] ) );

ok( $csv->print( *FH, [ "0\n0", "0\n0" ] ) );
ok( $csv->print( *FH, [ "\0\n0", "\0\n0" ] ) );
ok( $csv->print( *FH, [ "0\n\0", "0\n\0" ] ) );
ok( $csv->print( *FH, [ "\0\n\0", "\0\n\0" ] ) );

$csv->always_quote(1);

ok( $csv->print( *FH, [ "", undef, "0\n", "", "\0\n0" ] ) );


close( FH );

# reading
open( FH, "__test.csv" ) or die $!;
binmode FH;

is( $csv->getline( *FH )->[0], "00",   '*00' ); # Test::More warns 00
is( $csv->getline( *FH )->[0], "\00",  '\00' );
is( $csv->getline( *FH )->[0], "0\0",  '0\0' );
is( $csv->getline( *FH )->[0], "\0\0", '\0\0' );

is( $csv->getline( *FH )->[0], "0\n0",   '*0\n0' ); # Test::More warns 00
is( $csv->getline( *FH )->[0], "\0\n0",  '\0\n0' );
is( $csv->getline( *FH )->[0], "0\n\0",  '0\n\0' );
is( $csv->getline( *FH )->[0], "\0\n\0", '\0\n\0' );

is( $csv->getline( *FH )->[0], "\"0\n0",   '\"0\n0' );
is( $csv->getline( *FH )->[0], "\"\0\n0",  '\"\0\n0' );
is( $csv->getline( *FH )->[0], "\"0\n\0",  '\"0\n\0' );
is( $csv->getline( *FH )->[0], "\"\0\n\0", '\"\0\n\0' );

is( $csv->getline( *FH )->[0], "\"0\n\"0",   '\"0\n\"0' );
is( $csv->getline( *FH )->[0], "\"\0\n\"0",  '\"\0\n\"0' );
is( $csv->getline( *FH )->[0], "\"0\n\"\0",  '\"0\n\"\0' );
is( $csv->getline( *FH )->[0], "\"\0\n\"\0", '\"\0\n\"\0' );

is( $csv->getline( *FH )->[1], "0\n0",   '*0\n0' ); # Test::More warns 00
is( $csv->getline( *FH )->[1], "\0\n0",  '\0\n0' );
is( $csv->getline( *FH )->[1], "0\n\0",  '0\n\0' );
is( $csv->getline( *FH )->[1], "\0\n\0", '\0\n\0' );

$csv->blank_is_undef(1);

my $col = $csv->getline( *FH );

is( $col->[0], "", '' );
is( $col->[1], undef, '' );
is( $col->[2], "0\n", '' );
is( $col->[3], "", '' );
is( $col->[4], "\0\n0", '' );

close( FH );

unlink( '__test.csv' );

