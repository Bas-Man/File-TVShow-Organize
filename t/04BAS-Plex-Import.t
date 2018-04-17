# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More; #tests => 6;
use Test::Carp;
use BAS::Plex::Import;
BEGIN { use_ok('File::Path')};
BEGIN { use_ok('File::Copy')};
BEGIN { use_ok('Cwd')};

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017|S.W.A.T.2018:S.W.A.T 2018";
our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

my $obj = BAS::Plex::Import->new();

my $sourceDir = getcwd . '/t/test-data/';
my $sourceDirInValid = $sourceDir . 't/invalid';

my $ShowDirectory = getcwd . '/t/TV Shows';

my $filename = $sourceDir . ".testdir";

$obj->showFolder($ShowDirectory);

$obj->newShowFolder($sourceDir);

$obj->createShowHash();

can_ok($obj, 'wereThereErrors');
is($obj->{UnhandledFileNames}, undef, "No UnhandedFiles have been found"); 

can_ok($obj, 'processNewShows');

diag "\n\nBegin processing New Shows Folder. This loops through files in this folder.";
$obj->processNewShows();

can_ok($obj, 'importShow');

$obj->wereThereErrors();
ok($obj->{UnhandledFileNames} =~ /HASH/, "Unhandled files were found");
#diag explain $obj;

#my $d = Data::Dumper->new([$obj]);
#print $d->Dump;

done_testing();

