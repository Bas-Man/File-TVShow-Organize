# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use BAS::Plex::Import;

use Test::More; #tests => 6;
BEGIN { use_ok('BAS::Plex::Import') };
BEGIN { use_ok('Video::Filename') };
BEGIN { use_ok('File::Path')};
BEGIN { use_ok('File::Copy')};
BEGIN { use_ok('Cwd')};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $obj = BAS::Plex::Import->new();
isa_ok($obj, 'BAS::Plex::Import');

my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';
my $filename = $sourceDir . ".testdir";
ok (-e $filename, 'Show Source Directory path is valid');

can_ok ($obj, 'showDest');
is ($obj->showDest, undef, "Show Destination Directory is undefined as expected");
can_ok ($obj, 'set_showDest');

$obj->set_showDest($sourceDir);
ok($obj->showDest =~ m/$sourceDir/, "Destination directory as be set as expected and is valid");

my $invalidshowDest = BAS::Plex::Import->new();
$invalidshowDest->set_showDest($sourceDirInValid);
is($invalidshowDest->showDest, undef, "Passed invalid path should be undef");

can_ok ($obj, 'newDownloads');
is ($obj->newDownloads, undef, "Show Source Directory is undefined as expected");
can_ok ($obj, 'set_newDownloads');

$obj->set_newDownloads($sourceDir);
ok($obj->newDownloads =~ m/$sourceDir/, "Source directory as be set as expected");

my $invalidnewDownloads = BAS::Plex::Import->new();
$invalidnewDownloads->set_newDownloads($sourceDirInValid);
is($invalidnewDownloads->newDownloads, undef, "Passed invalid path should be undef");

done_testing();
