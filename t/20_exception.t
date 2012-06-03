use strict;
use warnings;
use Text::KyTea;
use Test::More;
use Test::Fatal;

my $exception = exception { Text::KyTea->new(h2z => 1) };
like($exception, qr/Unknown/, 'unknown option');

$exception = exception { Text::KyTea->new(model => "みっくみくのるっかるか") };
like($exception, qr/not found/, 'model file is not found');

done_testing;
