use inc::Module::Install;
use Module::Install::XSUtil;

name     'Text-KyTea';
all_from 'lib/Text/KyTea.pm';

requires 'Carp';
build_requires 'Devel::CheckLib';
test_requires  'Test::More' => 0.88; # done_testing
test_requires  'Test::Base';

requires_cplusplus;
cc_src_paths 'xs';
cc_warnings;
cc_assert_lib lib => 'kytea';
cc_libs 'kytea';
use_ppport 3.20;

tests 't/*.t';
author_tests 'xt';

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
);
