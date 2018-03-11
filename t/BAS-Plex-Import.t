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
my $filename = $sourceDir . ".testdir";
ok (-e $filename, 'Show Source Directory path is valid');

can_ok ($obj, 'showDir');
is ($obj->showDir, undef, "Show destination Directory is undefined as expected");
can_ok ($obj, 'set_showDir');

$obj->set_showDir($sourceDir);
ok($obj->showDir =~ m/$sourceDir/, "Destination directory as be set as expected");

can_ok ($obj, 'newDownloads');
is ($obj->newDownloads, undef, "Show Source Directory is undefined as expected");
can_ok ($obj, 'set_newDownloads');

$obj->set_newDownloads($sourceDir);
ok($obj->newDownloads =~ m/$sourceDir/, "Source directory as be set as expected");


done_testing();
