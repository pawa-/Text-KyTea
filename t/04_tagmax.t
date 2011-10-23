use strict;
use warnings;
use Text::KyTea;
use Test::More;

my $kytea = Text::KyTea->new(
    model  => './model/test.mod',
    tagmax => 1,
);

tagmax_test( $kytea->parse("コーパスの文です。") );
tagmax_test( $kytea->parse("もうひとつの文です。") );


done_testing;


sub tagmax_test
{
    my $results = shift;

    for my $result (@{$results})
    {
        my $p_of_s_tag = $result->{tags}[0];
        is(scalar @{$p_of_s_tag}, 1);

        my $pron = $result->{tags}[1];
        is(scalar @{$pron}, 1);
    }
}
