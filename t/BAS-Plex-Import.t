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

my $countries = "(US|UK)";

my $obj = BAS::Plex::Import->new();
isa_ok($obj, 'BAS::Plex::Import');

my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';
my $ShowDirectory = getcwd . '/t/TV Shows';

my $filename = $sourceDir . ".testdir";
ok (-e $filename, 'Show Source Directory path is valid');

can_ok ($obj, 'showFolder');
is ($obj->showFolder, undef, "Show Destination Directory is undefined as expected");
can_ok ($obj, 'set_showFolder');

$obj->set_showFolder($ShowDirectory);
ok($obj->showFolder =~ m/$ShowDirectory/, "Destination directory as be set as expected and is valid");

my $invalidshowFolder = BAS::Plex::Import->new();
$invalidshowFolder->set_showFolder($sourceDirInValid);
is($invalidshowFolder->showFolder, undef, "Passed invalid path should be undef");

can_ok ($obj, 'newDownloads');
is ($obj->newDownloads, undef, "Show Source Directory is undefined as expected");
can_ok ($obj, 'set_newDownloads');

$obj->set_newDownloads($sourceDir);
ok($obj->newDownloads =~ m/$sourceDir/, "Source directory as be set as expected");

my $invalidnewDownloads = BAS::Plex::Import->new();
$invalidnewDownloads->set_newDownloads($sourceDirInValid);
is($invalidnewDownloads->newDownloads, undef, "Passed invalid path should be undef");

can_ok($obj, 'createShowHash');

$obj->createShowHash();


can_ok($obj, 'getShowPath');

is ($obj->getShowPath("Agent X"), "Agent X US", "Got Agent X US");
is ($obj->getShowPath("Agent X US"), "Agent X US", "Got Agent X US");
is ($obj->getShowPath("Agent X (US)"), "Agent X US", "Got Agent X US");


is ($obj->getShowPath("Travelers"), "Travelers (2016)", "Travelers");
is ($obj->getShowPath("Travelers 2016"), "Travelers (2016)", "Travelers 2016");
is ($obj->getShowPath("Travelers (2016)"), "Travelers (2016)", "Travelers (2016)");

is ($obj->getShowPath("Bull"), "Bull (2016)", "Bull");
is ($obj->getShowPath("Bull 2016"), "Bull (2016)", "Bull 2016");
is ($obj->getShowPath("Bull (2016)"), "Bull (2016)", "Bull (2016)");

is ($obj->getShowPath("Doctor Who"), "Doctor Who (2005)", "Doctor Who");
is ($obj->getShowPath("Doctor Who 2005"), "Doctor Who (2005)", "Doctor Who 2005");
is ($obj->getShowPath("Doctor Who (2005)"), "Doctor Who (2005)", "Doctor Who (205)");

is ($obj->getShowPath("Hawaii Five-0"), "Hawaii Five-0 2010", "Hawaii Five-0");
is ($obj->getShowPath("Hawaii Five-0 2010"), "Hawaii Five-0 2010", "Hawaii Five-0");
is ($obj->getShowPath("Hawaii Five-0 (2010)"), "Hawaii Five-0 2010", "Hawaii Five-0");

is ($obj->getShowPath("S.W.A.T"), "S.W.A.T 2017", "SWAT");
is ($obj->getShowPath("S.W.A.T 2017"), "S.W.A.T 2017", "SWAT");
is ($obj->getShowPath("S.W.A.T (2017)"), "S.W.A.T 2017", "SWAT");

is ($obj->getShowPath("The Librarian"), "The Librarian", "The Librarian");

is ($obj->getShowPath("The Librarians"), "The Librarians US", "The Librarian US");
is ($obj->getShowPath("The Librarians US"), "The Librarians US", "The Librarian US");
is ($obj->getShowPath("The Librarians (US)"), "The Librarians US", "The Librarian US");

is ($obj->getShowPath("The Tomorrow People (1992) - The New Generation"), "The Tomorrow People (1992) - The New Generation", "The Tomorrow People (1992) - The New Generation");

is ($obj->getShowPath("The Tomorrow People"), "The Tomorrow People", "The Tomorrow People");

is ($obj->getShowPath("The Tomorrow People US"), "The Tomorrow People US", "The Tomorrow People US");
is ($obj->getShowPath("The Tomorrow People (US)"), "The Tomorrow People US", "The Tomorrow People (US)");
isnt ($obj->getShowPath("The Tomorrow People"), "The Tomorrow People US", "Isnt The Tomorrow People");

is ($obj->getShowPath("bogus"), undef, "Get undef result");

can_ok($obj, 'processNewDownloads');

$obj->processNewDownloads();

## I need to remove SeasonFolders for future testing and cleaning up structure.

#my $d = Data::Dumper->new([$obj]);
#print $d->Dump;
done_testing();

