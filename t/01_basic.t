use strict;
use warnings;
use Text::KyTea;
use Test::More;

my $kytea = Text::KyTea->new(model => './model/test.mod');
isa_ok($kytea, 'Text::KyTea');

$kytea = Text::KyTea->new({ model => './model/test.mod' });

can_ok('Text::KyTea', qw/parse read_model/);

$kytea->read_model('./model/test.mod');

my $results = $kytea->parse("コーパスの文です。");
parse_test($results);


$results = $kytea->parse("");
is(scalar @{$results}, 0, 'empty input');
parse_test($results);


done_testing;


sub parse_test
{
    my $results = shift;

    for my $result (@{$results})
    {
        unlike($result->{surface}, qr/[0-9\.\-]/);

        for my $tags (@{$result->{tags}})
        {
            for my $tag (@{$tags})
            {
                unlike($tag->{feature}, qr/[0-9\.\-]/);
                like($tag->{score}, qr/[0-9\.\-]/);
            }
        }
    }
}
