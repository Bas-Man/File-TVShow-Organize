# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Data::Dumper;

use Test::More; #tests => 6;
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

diag "\nCreate Testing Object BAS::Plex::Import";
my $obj = BAS::Plex::Import->new();
isa_ok($obj, 'BAS::Plex::Import');

diag "\nCheck default Countries value\n";
ok($obj->countries() =~ m/\(UK\|US\)/, "countries is (UK|US)");

diag "Change countries to new value";
ok($obj->countries("USA") =~ m/USA/, "countries is now equal to USA");

diag "Destroy and recreate test obj with default countries values for testing purposes\n";
$obj = undef;
$obj = BAS::Plex::Import->new();

diag "\nSet Source dir and invalid source dir as well as TV Show dir";
my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';

my $ShowDirectory = getcwd . '/t/TV Shows';

my $filename = $sourceDir . ".testdir";
diag "Test Data Directory is valid for testing\n";
ok (-e $filename, 'Show Source Directory path is valid');

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

can_ok ($obj, 'newDownloads');
is ($obj->newDownloads, undef, "New TV Show download folder is undefined as expected");
can_ok ($obj, 'newDownloads');

diag "Set Download folder to a valid path\n";
$obj->newDownloads($sourceDir);
ok($obj->newDownloads =~ m/$sourceDir/, "Download path is set and is valid");

my $invalidnewDownloads = BAS::Plex::Import->new();
$invalidnewDownloads->newDownloads($sourceDirInValid);
is($invalidnewDownloads->newDownloads, undef, "Passed invalid path should be undef");

can_ok($obj, 'createShowHash');

diag "Call createShowHash which loads folders found in in the TV Show Folder where shows live for Plex\n";
$obj->createShowHash();

diag "Long test to check that we can get the correct folder to store Shows in based on the filename\n";
can_ok($obj, 'showPath');

is ($obj->showPath("Agent X"), "Agent X US", "Agent X returns Agent X US");
is ($obj->showPath("Agent X US"), "Agent X US", "Agent X US returns Agent X US");
is ($obj->showPath("Agent X (US)"), "Agent X US", "Agent X (US) returns Agent X US");

is ($obj->showPath("Travelers"), "Travelers (2016)", "Travelers returns Travelers (2016)");
is ($obj->showPath("Travelers 2016"), "Travelers (2016)", "Travelers 2016 returns Travelers (2016)");
is ($obj->showPath("Travelers (2016)"), "Travelers (2016)", "Travelers (2016) returns Travelers (2016)");

is ($obj->showPath("Bull"), "Bull (2016)", "Bull returns Bull (2016)");
is ($obj->showPath("Bull 2016"), "Bull (2016)", "Bull 2016 returns Bull (2016)");
is ($obj->showPath("Bull (2016)"), "Bull (2016)", "Bull (2016) returns Bull (2016)");

is ($obj->showPath("Doctor Who"), "Doctor Who (2005)", "Doctor Who returns Doctor Who (2005)");
is ($obj->showPath("Doctor Who 2005"), "Doctor Who (2005)", "Doctor Who 2005 returns Doctor Who (2005)");
is ($obj->showPath("Doctor Who (2005)"), "Doctor Who (2005)", "Doctor Who (2005) returns Doctor Who (2005)" );

is ($obj->showPath("S.W.A.T"), "S.W.A.T 2017", "S.W.A.T returns S.W.A.T 2017");
is ($obj->showPath("S.W.A.T 2017"), "S.W.A.T 2017", "S.W.A.T 2017 returns S.W.A.T 2017");
is ($obj->showPath("S.W.A.T (2017)"), "S.W.A.T 2017", "S.W.A.T (2017)returns S.W.A.T 2017");

is ($obj->showPath("The Librarian"), "The Librarian", "The Librarian returns The Librarian");

is ($obj->showPath("The Librarians"), "The Librarians US", "The Libraran returns The Librarian US");
is ($obj->showPath("The Librarians US"), "The Librarians US", "The Librarians US returns The Librarian US");
is ($obj->showPath("The Librarians (US)"), "The Librarians US", "The Librarians (US) returns The Librarian US");

is ($obj->showPath("The Tomorrow People (1992) - The New Generation"), "The Tomorrow People (1992) - The New Generation", "The Tomorrow People (1992) - The New Generation");

is ($obj->showPath("The Tomorrow People"), "The Tomorrow People", "The Tomorrow Pople returns The Tomorrow People");

is ($obj->showPath("The Tomorrow People US"), "The Tomorrow People US", "The Tomorrow People US");
is ($obj->showPath("The Tomorrow People (US)"), "The Tomorrow People US", "The Tomorrow People (US)");
isnt ($obj->showPath("The Tomorrow People"), "The Tomorrow People US", "The Tomorrow Poeple doesnt return The Tomorrow People US");

is ($obj->showPath("bogus"), undef, "If a show Folder does not exist return undef");

can_ok($obj, 'processNewDownloads');

diag "Begin processing Download Folder. This loops through files in this folder.";
$obj->processNewDownloads();

can_ok($obj, 'importShow');

#diag explain $obj;

#my $d = Data::Dumper->new([$obj]);
#print $d->Dump;

done_testing();

