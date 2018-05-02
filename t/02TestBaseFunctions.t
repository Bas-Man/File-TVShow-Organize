# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 02TestBaseFunctions.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Carp;
BEGIN { use_ok('Video::File::TVShow::Import') };
BEGIN { use_ok('Video::Filename') };
BEGIN { use_ok('File::Path')};
BEGIN { use_ok('File::Copy')};
BEGIN { use_ok('Cwd')};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $obj = Video::File::TVShow::Import->new();
isa_ok($obj, 'Video::File::TVShow::Import');

subtest 'Test Default Countries value' => sub {

ok($obj->countries() =~ m/\(UK\|US\)/, "countries is (UK|US)");
ok($obj->countries("USA") =~ m/USA/, "countries is now equal to USA");

};

subtest "Test Exception List case" => sub {

ok(!defined $obj->{_exceptionList}, "Global variable: exceptionList is not defined");
our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017|Test.2018:Test 2018";

$obj = undef;
$obj = Video::File::TVShow::Import->new();
ok(keys $obj->{_exceptionList}, "Global variable execptionList is defined");
ok($obj->{_exceptionList}{'S.W.A.T.2017'} =~ m/S.W.A.T 2017/, "S.W.A.T.2017 gives S.W.A.T 2017");
ok($obj->{_exceptionList}{'Test.2018'} =~ m/Test 2018/, "Test.2018 gives Test 2018");

};

$obj = undef;
$obj = Video::File::TVShow::Import->new();

subtest "Test Destintaiton Directory handling" => sub {
can_ok ($obj, 'showFolder');

subtest "Call showFolder with it never being set" => sub {
is ($obj->showFolder, undef, "showFolder was never set and returns undef as required");
};

subtest "Pass an invalid path" => sub {
is($obj->showFolder(getcwd . '/TV Shows'), undef, "Passed an invalid path");
};

subtest "Pass a valid path" => sub {
ok($obj->showFolder(getcwd . '/t/TV Shows') =~ m/.*\/TV Shows\/$/,  "Passed a valid Path without ending \/ character \/ was appended by funtion");
};

subtest "Pass an invalid path again to showfolder()" => sub {
is($obj->showFolder(getcwd . 't/TV Shows'), undef, "t/TV Shows is not a valid path missing leading /");
};

subtest "Test newShowFolder method" => sub {
can_ok ($obj, 'newShowFolder');
is ($obj->newShowFolder, undef, "New TV Show download folder is undefined as expected");

subtest "Pass invalid path to newShowFolder()" => sub {
is($obj->newShowFolder(getcwd . 'test-data'), undef, "Passed an invalid path");
};

ok($obj->newShowFolder(getcwd . '/t/test-data') =~ m/.*\/$/, "newShowFolder was passed a valid path not ending with \/. but returned path ending in \/");
};

subtest "Pass an invalid path again to newShowFolder" => sub {
is($obj->newShowFolder(getcwd . 't/test-data'), undef, "t/test-data is not a valid path missing leading /");
};

};

subtest 'Testing if we should delete or rename processed files' => sub {
can_ok ($obj, 'delete');

is($obj->delete(), 0, "Delete is false (0). We should renamed files as we process them");
is($obj->delete(1), 1, "Delete is true (1). We should delete files as we process them");
is($obj->delete(),1 , "Delete is still true (1). We should delete files as we process them");
is($obj->delete(0), 0, "Delete is false (0) again. We should delete files as we process them");
is($obj->delete("A"), undef, "I was passed an invalid imput returning undef");
};

subtest "Testing verbose function." => sub {
is($obj->verbose(), 0, "Delete is false (0). We should renamed files as we process them");
is($obj->verbose(1), 1, "Delete is true (1). We should delete files as we process them");
is($obj->verbose(),1 , "Delete is still true (1). We should delete files as we process them");
is($obj->verbose(0), 0, "Delete is false (0) again. We should delete files as we process them");
is($obj->verbose("A"), undef, "I was passed an invalid imput returning undef");

};

done_testing();
