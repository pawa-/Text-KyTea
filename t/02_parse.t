use strict;
use warnings;
use Test::Base;
plan tests => 2 * blocks;

use Text::KyTea;

my $kytea = Text::KyTea->new(model_path => './model/test.mod');

run
{
    my $block = shift;
    my $results = $kytea->parse($block->input);

    my ($pron, $p_of_s) = pronounciation_and_part_of_speech($results);

    is($pron,   $block->expected_pron);
    is($p_of_s, $block->expected_p_of_s);
};


sub pronounciation_and_part_of_speech
{
    my $results = shift;

    my ($pron, $p_of_s);

    for my $result (@{$results})
    {
        my $p_of_s_tag = $result->{tags}[0];
        $p_of_s .= $p_of_s_tag->[0]{feature};
        $p_of_s .= ' ';

        my $pron_tag = $result->{tags}[1];
        $pron .= $pron_tag->[0]{feature};
    }

    $p_of_s =~ s/\s$//;

    return ($pron, $p_of_s);
}


__DATA__
===
--- input:           コーパスの文です。
--- expected_pron:   こーぱすのぶんです。
--- expected_p_of_s: 名詞 助詞 名詞 助動詞 語尾 補助記号

===
--- input:           もうひとつの文です。
--- expected_pron:   もうひとつのぶんです。
--- expected_p_of_s: 副詞 名詞 接尾辞 助詞 名詞 助動詞 語尾 補助記号
