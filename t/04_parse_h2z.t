use utf8;
use strict;
use warnings;
use Test::Base;
plan tests => 3 * blocks;

binmode Test::More->builder->$_ => ':utf8'
    for qw(output failure_output todo_output);

use Text::KyTea;

my $kytea = Text::KyTea->new(
    model => './model/test.mod',
    h2z   => 1,
);

run
{
    my $block   = shift;
    my $results = $kytea->parse($block->input);

    my ($surf, $pron, @p_of_s) = split_results($results);

    is($surf,     $block->expected_surf);
    is($pron,     $block->expected_pron);
    is("@p_of_s", $block->expected_p_of_s);
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
=== hankaku
--- input:           2012
--- expected_surf:   2012
--- expected_pron:   にせんじゅうに
--- expected_p_of_s: 名詞

=== zenkaku
--- input:           ２０１２
--- expected_surf:   ２０１２
--- expected_pron:   にせんじゅうに
--- expected_p_of_s: 名詞

=== hanzen
--- input:           ２01２
--- expected_surf:   ２01２
--- expected_pron:   にせんじゅうに
--- expected_p_of_s: 名詞
