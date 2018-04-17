# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Carp;
use BAS::Plex::Import;
BEGIN { use_ok('BAS::Plex::Import') };
BEGIN { use_ok('Video::Filename') };
BEGIN { use_ok('File::Path')};
BEGIN { use_ok('File::Copy')};
BEGIN { use_ok('Cwd')};
BEGIN { use_ok('Carp')};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

diag "\nCreate Testing Object BAS::Plex::Import without exception list";
my $obj = BAS::Plex::Import->new();
isa_ok($obj, 'BAS::Plex::Import');

subtest 'Test Default Countries value' => sub {
diag "\nCheck default Countries value\n";
ok($obj->countries() =~ m/\(UK\|US\)/, "countries is (UK|US)");

diag "Change countries to new value";
ok($obj->countries("USA") =~ m/USA/, "countries is now equal to USA");

};

subtest "Test Exception List case\n" => sub {
ok(!defined $obj->{_exceptionList}, "Global variable: exceptionList is not defined\n");

diag "\nTest new() function with exception list being defined\n";
our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017|Test.2018:Test 2018";

$obj = undef;
$obj = BAS::Plex::Import->new();
ok(keys $obj->{_exceptionList}, "Global variable execptionList is defined\n");
ok($obj->{_exceptionList}{'S.W.A.T.2017'} =~ m/S.W.A.T 2017/, "S.W.A.T.2017 gives S.W.A.T 2017\n");
ok($obj->{_exceptionList}{'Test.2018'} =~ m/Test 2018/, "Test.2018 gives Test 2018\n");

};

diag "Destroy and recreate test obj with default countries values for testing purposes\n";
$obj = undef;
$obj = BAS::Plex::Import->new();

subtest "Test Source and Destintaiton Directory handling" => sub {
diag "\nSet Source dir and invalid source dir as well as TV Show dir";
my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';

my $ShowDirectory = getcwd . '/t/TV Shows';

diag "Obj knows showFolder path\n";
can_ok ($obj, 'showFolder');
diag "Obj Show Folder is undefined\n";
is ($obj->showFolder, undef, "TV Show Directory is undefined as expected");
diag "Set showFolder path\n";
$obj->showFolder($ShowDirectory);
ok($obj->showFolder =~ m/$ShowDirectory/, "Destination directory as be set as expected and is valid");

diag "Check that we can handle an invalid path for TV Shows folder and returns undef\n";
my $invalidshowFolder = BAS::Plex::Import->new();
$invalidshowFolder->showFolder($sourceDirInValid);
is($invalidshowFolder->showFolder, undef, "Passed invalid path should be undef");

can_ok ($obj, 'newShowFolder');
is ($obj->newShowFolder, undef, "New TV Show download folder is undefined as expected");

diag "Set Download folder to a valid path\n";
$obj->newShowFolder($sourceDir);
ok($obj->newShowFolder =~ m/$sourceDir/, "Download path is set and is valid");

my $invalidnewDownloads = BAS::Plex::Import->new();
$invalidnewDownloads->newShowFolder($sourceDirInValid);
is($invalidnewDownloads->newShowFolder, undef, "Passed invalid path should be undef");
};

diag "\n\nTest that we can set and check the value of delete() to determine if 'file' should be deleted or just renamed\n";

subtest 'Testing if we should delete or rename processed files' => sub {
can_ok ($obj, 'delete');

is($obj->delete(), undef, "Delete is not defined. We should renamed files as we process them");

is($obj->delete(1), defined, "Delete is defined. We should delete files as we process them");

is($obj->delete(), defined, "Delete was defined. We should delete files as we process them");

is($obj->delete(0), undef, "Delete is not defined again. We should delete files as we process them");

};

done_testing();

