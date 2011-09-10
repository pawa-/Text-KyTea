use strict;
use warnings;
use Test::More;

ok( open(my $fh, '<', './model_path') );
my $model_path = <$fh>;
close($fh);

use_ok('Text::KyTea');

my $kytea = Text::KyTea->new(model_path => $model_path);
isa_ok($kytea, 'Text::KyTea');
can_ok('Text::KyTea', qw/parse/);

my $results = $kytea->parse("同情するなら金をくれ");
parse_test($results);

$results = $kytea->parse("今日はいい天気です。");
parse_test($results);

$results = $kytea->parse("「かたなし」じゃなくて小鳥遊です！");
parse_test($results);

$results = $kytea->parse("長野県から来ました長野久義です。");
parse_test($results);

$results = $kytea->parse("");
is(scalar @{$results}, 0);
parse_test($results);


sub parse_test
{
    my $results = shift;

    for my $result (@{$results})
    {
        unlike($result->{surface},     qr/[0-9.]/);
        unlike($result->{feature},     qr/[0-9.]/);
        unlike($result->{pron},        qr/[0-9.]/);
        like($result->{feature_score}, qr/[0-9.]/);
        like($result->{pron_score},    qr/[0-9.]/);
    }
}

done_testing;
