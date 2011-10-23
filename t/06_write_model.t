use strict;
use warnings;
use Text::KyTea;
use Test::More;

my $kytea = Text::KyTea->new(model => './model/test.mod');
$kytea->write_model('./hoge.mod');

ok(-e './hoge.mod', 'exist');
ok(-s './hoge.mod', 'size');
unlink('./hoge.mod');

done_testing;
