# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

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

my $obj = BAS::Plex::Import->new();

my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';

my $ShowDirectory = getcwd . '/t/TV Shows';

my $filename = $sourceDir . ".testdir";

$obj->showFolder($ShowDirectory);

$obj->newShowFolder($sourceDir);

$obj->createShowHash();

can_ok($obj, 'processNewShows');

diag "Begin processing New Shows Folder. This loops through files in this folder.";
$obj->processNewShows();

can_ok($obj, 'importShow');

#diag explain $obj;

#my $d = Data::Dumper->new([$obj]);
#print $d->Dump;

done_testing();

