use utf8;
use strict;
use warnings;
use Text::KyTea;
use Test::More;

my $kytea = Text::KyTea->new(model => './model/test.mod');
isa_ok($kytea, 'Text::KyTea');

can_ok('Text::KyTea', qw/parse read_model/);

$kytea->read_model('./model/test.mod');

my $results = $kytea->parse("コーパスの文です。");
parse_test($results);


# Ver.0.3.2: PASS.
# Ver.0.4.0: FAIL (std::bad_alloc).
=begin
$results = $kytea->parse("");
is(scalar @{$results}, 0);
parse_test($results);
=end
=cut


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
