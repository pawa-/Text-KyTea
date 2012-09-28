use inc::Module::Install;
use Module::Install::XSUtil;

my $INSTALL_DIR = prompt('Input the path to the install directory of KyTea', '/usr/local');
my $LIB_PATH    = "${INSTALL_DIR}/lib";
my $INC_PATH    = "${INSTALL_DIR}/include";
my $BIN_PATH    = "${INSTALL_DIR}/bin";

my $TEST_MODEL_DIR  = './model';
my $TEST_MODEL_FILE = "${TEST_MODEL_DIR}/test.txt";
my $TEST_MODEL      = "${TEST_MODEL_DIR}/test.mod";

name     'Text-KyTea';
all_from 'lib/Text/KyTea.pm';

requires       'Carp';
build_requires 'Devel::CheckLib' => 0.98;
test_requires  'Test::More'      => 0.88; # done_testing
test_requires  'Test::Base';
test_requires  'Test::Fatal';

requires_cplusplus;
cc_src_paths 'xs';
#cc_warnings;

cc_assert_lib(
    incpath => $INC_PATH,
    libpath => $LIB_PATH,
    #lib     => 'kytea',
);

cc_libs "-L$LIB_PATH -lkytea";
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
    unlink $TEST_MODEL;

    print "\n";
    print "Training kytea...\n";

    my $ret = system("$BIN_PATH/train-kytea -full $TEST_MODEL_FILE -model $TEST_MODEL");

    die "Is $INSTALL_DIR the correct path to the install directory of KyTea?" if $ret != 0;

    print "Training kytea done!\n";
    print "\n";
}
