use strict;
use warnings;
use Test::LeakTrace;
use Test::More;

use Text::KyTea;

no_leaks_ok
{
    my $kytea = Text::KyTea->new(model => './model/test.mod');
} "new";

my $kytea = Text::KyTea->new(model => './model/test.mod');

no_leaks_ok
{
    $kytea->read_model('./model/test.mod');
} "read_model";

no_leaks_ok
{
    $kytea->parse("ほげほげ");
} "parse normal string";

=begin
no_leaks_ok
{
    $kytea->parse("");
} "parse empty string";
=end
=cut

done_testing;
