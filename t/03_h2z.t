use utf8;
use strict;
use warnings;
use Text::KyTea;
use Test::More;

binmode Test::More->builder->$_ => ':utf8'
    for qw(output failure_output todo_output);

my $text = '39３９mikuｍｉｋｕみくミクﾐｸ!！#＃/／&＆?？|｜-ー';

is(Text::KyTea::_h2z($text), '３９３９ｍｉｋｕｍｉｋｕみくミクミク！！＃＃／／＆＆？？｜｜－ー');

done_testing;
