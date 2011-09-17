use inc::Module::Install;
use Module::Install::XSUtil;

name     'Text-KyTea';
all_from 'lib/Text/KyTea.pm';

requires 'Carp';
build_requires 'Devel::CheckLib';
test_requires  'Test::More' => 0.88; # done_testing

cc_warnings;
cc_assert_lib 'kytea';
cc_libs 'kytea';
use_ppport 3.19;
put_model_path();

tests 't/*.t';
author_tests 'xt';

use_test_base;
auto_include;

readme_from 'lib/Text/KyTea.pm';

resources(
    license    => 'http://dev.perl.org/licenses',
    repository => 'https://github.com/pawa-/Text-KyTea',
    bugtracker => 'https://github.com/pawa-/Text-KyTea/issues',
);

WriteMakefile(
    CC       => 'g++',
    LD       => 'g++',
    XSOPT    => '-C++',
    TYPEMAPS => ['perlobject.map'],
);


sub put_model_path
{
    chomp(my $lib_path = `which kytea`);

    if ($lib_path !~ m|bin/kytea|)
    {
        chomp($lib_path = `whereis -b kytea`);
    }

    my $model_path;

    if ($lib_path =~ m|(/.*)bin/kytea|)
    {
        $model_path = "${1}share/kytea/model.bin";
    }
    else
    {
        die "kytea command is not available.\n" .
            "if you changed install directory of KyTea,\n" .
            "please add KyTea's path to PATH environment variable\n";
    }

    open(my $fh, '>', './model_path') or die "failed to put model path";
    print {$fh} $model_path;
    close($fh);
}
