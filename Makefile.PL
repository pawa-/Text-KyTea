use inc::Module::Install;
use Module::Install::XSUtil;

my $LIB_PATH = prompt("Path to lib directory of KyTea",     '/usr/local/lib');
my $INC_PATH = prompt("Path to include directory of KyTea", '/usr/local/include');
my $BIN_PATH = prompt("Path to bin directory of KyTea",     '/usr/local/bin');
my %config   = (LIBS => "-L$LIB_PATH -lkytea", INC => "-I$INC_PATH");
my $MODEL_FILE_PATH = './model/test.mod';

name     'Text-KyTea';
all_from 'lib/Text/KyTea.pm';

requires       'Carp';
#build_requires 'Devel::CheckLib';
test_requires  'Test::More' => 0.88; # done_testing
test_requires  'Test::Base';
test_requires  'Test::Fatal';

requires_cplusplus;
cc_src_paths 'xs';
cc_warnings;
#cc_assert_lib %config;
simple_check_lib($LIB_PATH, $INC_PATH);
cc_libs $config{LIBS};
cc_include_paths $INC_PATH;
train_kytea();
use_ppport 3.20;

tests        't/*.t';
author_tests 'xt';

readme_from 'lib/Text/KyTea.pm';

resources(
    license    => 'http://dev.perl.org/licenses',
    repository => 'https://github.com/pawa-/Text-KyTea',
    bugtracker => 'https://github.com/pawa-/Text-KyTea/issues',
);

WriteAll;


sub train_kytea
{
    unlink $MODEL_FILE_PATH;
    print "train kytea ...\n";

    qx($BIN_PATH/train-kytea -full ./model/test.txt -model $MODEL_FILE_PATH);

    if (-e $MODEL_FILE_PATH) { print "train-kytea ok\n"; }
    else                     { die   "train-kytea not ok\n"; }
}

sub simple_check_lib
{
    # If you change install directory of KyTea,
    # you have to set LD_LIBRARY_PATH of KyTea.
    # Otherwise, cc_assert_lib causes an error.
    # But you can use Text::KyTea without setting
    # LD_LIBRARY_PATH indeed.
    # Because of this, I wrote this simple subroutine.

    my ($lib_path, $inc_path) = @_;

    die "wrong lib directory of KyTea!"     unless grep { /libkytea\.so/ } contents_of($lib_path);
    die "wrong include directory of KyTea!" unless grep { /kytea/ }        contents_of($inc_path);
}

sub contents_of
{
    my $dir = shift;

    opendir(my $dh, $dir) or die "can't open $dir: $!";
    my @contents = readdir $dh;
    closedir($dh);

    return @contents;
}
