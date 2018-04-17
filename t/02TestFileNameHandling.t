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

diag "\nCreate Testing Object BAS::Plex::Import";
my $obj = BAS::Plex::Import->new();
isa_ok($obj, 'BAS::Plex::Import');

diag "\nSet Source dir and invalid source dir as well as TV Show dir";
my $sourceDir = getcwd . '/t/test-data/';

$obj->newShowFolder($sourceDir);

$obj->_handleExceptionsDatedFileNames("S.W.A.T.2017");
$obj->_handleExceptionsDatedFileNames("The Flash 2014");

done_testing();

