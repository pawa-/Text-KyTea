use strict;
use warnings;
use Test::LeakTrace;
use Test::More;

use Text::KyTea;

no_leaks_ok
{
    my $kytea = Text::KyTea->new(model_path => './model/test.mod');
} "new";

my $kytea = Text::KyTea->new(model_path => './model/test.mod');

no_leaks_ok
{
    $kytea->read_model('./model/test.mod');
} "read_model";

no_leaks_ok
{
    $kytea->parse("ほげほげ");
} "parse normal string";

no_leaks_ok
{
    $kytea->parse("");
} "parse empty string";

done_testing;
