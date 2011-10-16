use strict;
use warnings;
use Test::LeakTrace;
use Test::More;

use Text::KyTea;

no_leaks_ok
{
    my $kytea = Text::KyTea->new(model_path => './model/test.mod');
    $kytea->parse("ほげほげ");
};

done_testing;
