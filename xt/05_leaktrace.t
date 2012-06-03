use strict;
use warnings;
use Test::LeakTrace;
use Test::More;

use Text::KyTea;

my $kytea;

no_leaks_ok
{
    $kytea = Text::KyTea->new(model => './model/test.mod');
} "new";

no_leaks_ok
{
    $kytea->parse("ほげほげ");
} "parse normal string";

no_leaks_ok
{
    $kytea->read_model('./model/test.mod');
} "read_model";

no_leaks_ok
{
    $kytea->parse("");
} "parse empty string";

no_leaks_ok
{
    $kytea->parse("ｈｕｇａ＃！＠＜＞\t\n");
} "parse abnormal string";

done_testing;
