use 5.00503;
use ExtUtils::MakeMaker;

use lib qw( ./lib );

eval q| require Text::CSV |;

# B module can't install? I'm not careful for such a problem.
# Leave us alone today?
if ($@) {
    print "We try to look up lib/Text::CSV.pm, but in vain. B module can't install?\n";
    print "Set the environmental variable 'PERL_DL_NONLAZY' with 0.\n";
    print "And see to ExtUtils::MM_Unix.\n";
    print "perl says : $@";
    print "We do not make Makefile by requiring Perl version 7.0.\n";
    require 7.0000;
}

my $version     = Text::CSV->VERSION;
my $req_xs_ver  = Text::CSV->require_xs_version;
my $has_xs      = 0;
my $message;

eval q| require Text::CSV_XS |;

$has_xs = 1 unless ($@);

if ($has_xs) {
    my $xs_version = Text::CSV_XS->VERSION;
    if ($xs_version >= $req_xs_ver) {
        $message = "You have Text::CSV_XS (v.$xs_version), so Text::CSV can work very fast!!";
    }
    else {
        $message = "Your Text::CSV_XS version is $xs_version. If you install v.$req_xs_ver,\n"
                 . "Text::CSV will work faster.";
    }
}
else {
    $message = "If you install Text::CSV_XS v.$req_xs_ver, it makes Text::CSV faster.";
}
print <<EOF;
Welcome to Text::CSV (v.$version)
=============================
$message

EOF

sleep 3;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Text::CSV',
    'VERSION_FROM'	=> 'lib/Text/CSV.pm', # finds $VERSION
    'PREREQ_PM' => {
		      "IO::Handle"	=> 0,
		      "Test::More"	=> 0,
		      "Test::Harness"	=> 0,
    },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/Text/CSV.pm', # retrieve abstract from module
       AUTHOR     => 'Makamaka Hannyaharamitu, E<lt>makamaka[at]cpan.orgE<gt>') : ()),
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ('LICENSE' => 'perl', ) : () ),
);
