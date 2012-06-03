use strict;
use warnings;
use Test::Base;
plan tests => 3 * blocks;

use Text::KyTea;

my $kytea = Text::KyTea->new(
    model  => './model/test.mod',
    deftag => '(´・ω・｀)',
);

run
{
    my $block   = shift;
    my $results = $kytea->parse($block->input);

    my ($surf, $pron, @p_of_s) = split_results($results);

    is($surf,     $block->expected_surf,   'surf');
    is($pron,     $block->expected_pron,   'pron');
    is("@p_of_s", $block->expected_p_of_s, 'pos');
};


sub split_results
{
    my $results = shift;

    my ($surf, $pron, @p_of_s);

    for my $result (@{$results})
    {
        $surf .= $result->{surface};

        my $p_of_s_tag = $result->{tags}[0];
        push(@p_of_s, $p_of_s_tag->[0]{feature});

        my $pron_tag = $result->{tags}[1];
        $pron .= $pron_tag->[0]{feature};
    }

    return ($surf, $pron, @p_of_s);
}


__DATA__
===
--- input:           コーパスの文です。
--- expected_surf:   コーパスの文です。
--- expected_pron:   こーぱすのぶんです。
--- expected_p_of_s: 名詞 助詞 名詞 助動詞 語尾 補助記号

===
--- input:           もうひとつの文です。
--- expected_surf:   もうひとつの文です。
--- expected_pron:   もうひとつのぶんです。
--- expected_p_of_s: 副詞 名詞 接尾辞 助詞 名詞 助動詞 語尾 補助記号

===
--- input:           XXYBA
--- expected_surf:   XXYBA
--- expected_pron:   (´・ω・｀)(´・ω・｀)(´・ω・｀)(´・ω・｀)(´・ω・｀)
--- expected_p_of_s: (´・ω・｀) (´・ω・｀) (´・ω・｀) (´・ω・｀) (´・ω・｀)
