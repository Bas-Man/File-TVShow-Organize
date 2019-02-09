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

$obj = undef;
$obj = Video::File::TVShow::Import->new( { Exceptions => 'S.W.A.T.2017:S.W.A.T 2017|Test.2018:Test 2018' } );
ok(keys $obj->{_exceptionList}, "Global variable execptionList is defined");
ok($obj->{_exceptionList}{'S.W.A.T.2017'} =~ m/S.W.A.T 2017/, "S.W.A.T.2017 gives S.W.A.T 2017");
ok($obj->{_exceptionList}{'Test.2018'} =~ m/Test 2018/, "Test.2018 gives Test 2018");

};

$obj = undef;
$obj = Video::File::TVShow::Import->new();

subtest 'Testing if we should delete or rename processed files' => sub {
can_ok ($obj, 'delete');

is($obj->delete(), 0, "Delete is false (0). We should renamed files as we process them");
is($obj->delete(1), 1, "Delete is true (1). We should delete files as we process them");
is($obj->delete(),1 , "Delete is still true (1). We should delete files as we process them");
is($obj->delete(0), 0, "Delete is false (0) again. We should delete files as we process them");
is($obj->delete("A"), undef, "I was passed an invalid imput returning undef");
};

subtest "Testing verbose function." => sub {
is($obj->verbose(), 0, "verbose is false (0). provide minimum output");
is($obj->verbose(1), 1, "verbose is true (1). We should should provide more details on actions");
is($obj->verbose(),1 , "verbose is still true (1).");
is($obj->verbose(0), 0, "verbose is false (0) again.");
is($obj->verbose("A"), undef, "I was passed an invalid imput returning undef");

};

subtest "Testing recursion function." => sub {
is($obj->recursion(), 0, "verbose is false (0). Do not process recursively.");
is($obj->recursion(1), 1, "verbose is true (1). Process recursively");
is($obj->recursion(),1 , "verbose is still true (1).");
is($obj->recursion(0), 0, "verbose is false (0) again.");
is($obj->recursion("A"), undef, "I was passed an invalid imput returning undef");

};

subtest "Testing seasonFolder function." => sub {
can_ok($obj, 'seasonFolder');

is($obj->seasonFolder(),1, "The default is true. (1) We will create season folders under the parent folder.");
is($obj->seasonFolder(0),0 ,"SeasonFolder has been set to False. (0) Show files will not be put into seasons sub folders.");
is($obj->seasonFolder(), 0, "SeasonFolder is still set to False (0)");
is($obj->seasonFolder(1),1, "SeasonFolder has been set to true (1)");
is($obj->seasonFolder("A"), undef, "I was passed an invalid arugment. Returning undef")


};

done_testing();
