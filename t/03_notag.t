use strict;
use warnings;
use Test::Base;
plan tests => 6 * blocks;

use Text::KyTea;

my $model_path = './model/test.mod';

my $kytea_notag1 = Text::KyTea->new(
    model => $model_path,
    notag => [1],
);

my $kytea_notag2 = Text::KyTea->new(
    model => $model_path,
    notag => [2],
);

my $kytea_notag12 = Text::KyTea->new(
    model => $model_path,
    notag => [1,2],
);

run
{
    my $block = shift;
    my $results_notag1  = $kytea_notag1->parse($block->input);
    my $results_notag2  = $kytea_notag2->parse($block->input);
    my $results_notag12 = $kytea_notag12->parse($block->input);

    my ($notag1_surface,  @notag1_features)  = split_results($results_notag1);
    my ($notag2_surface,  @notag2_features)  = split_results($results_notag2);
    my ($notag12_surface, @notag12_features) = split_results($results_notag12);

    is($notag1_surface,     $block->expected_notag1_surf);
    is($notag2_surface,     $block->expected_notag2_surf);
    is($notag12_surface,    $block->expected_notag12_surf);
    is("@notag1_features",  $block->expected_notag1_features);
    is("@notag2_features",  $block->expected_notag2_features);
    is("@notag12_features", $block->expected_notag12_features);
};


sub split_results
{
    my $results = shift;

    my ($surf, @features);

    for my $result (@{$results})
    {
        $surf .= $result->{surface};

        for my $tags (@{$result->{tags}})
        {
            if ($tags->[0])
            {
                push(@features, $tags->[0]{feature});
            }
        }
    }

    return ($surf, @features);
}


__DATA__
===
--- input:                     コーパスの文です。
--- expected_notag1_surf:      コーパスの文です。
--- expected_notag2_surf:      コーパスの文です。
--- expected_notag12_surf:     コーパスの文です。
--- expected_notag1_features:  こーぱす の ぶん で す 。
--- expected_notag2_features:  名詞 助詞 名詞 助動詞 語尾 補助記号
--- expected_notag12_features:

===
--- input:                     もうひとつの文です。
--- expected_notag1_surf:      もうひとつの文です。
--- expected_notag2_surf:      もうひとつの文です。
--- expected_notag12_surf:     もうひとつの文です。
--- expected_notag1_features:  もう ひと つ の ぶん で す 。
--- expected_notag2_features:  副詞 名詞 接尾辞 助詞 名詞 助動詞 語尾 補助記号
--- expected_notag12_features:
