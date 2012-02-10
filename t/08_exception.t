use strict;
use warnings;
use Text::KyTea;
use Test::More;
use Test::Exception;

throws_ok { Text::KyTea->new(model => "みっくみくのるっかるか") }
    qr/not found/, 'model not found';

throws_ok { Text::KyTea->new(miku => 39) }
    qr/Unknown/, 'unknown option';

done_testing;
