# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 05MainTestImport.t'

#########################

use strict;
use warnings;
use Data::Dumper;
use Test::More; #tests => 6;
use Test::Carp;
BEGIN { use_ok( 'Video::File::TVShow::Import' ) };
use Cwd;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $file;
my $outputPath;
my $inputPath = "t/test-data/";

our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

my $obj = Video::File::TVShow::Import->new();

# Setup folder paths.
my $sourceDir = getcwd . '/t/test-data/done_list/';
my $ShowDirectory = getcwd . '/t/TV Shows';

#load paths into obj
$obj->showFolder($ShowDirectory);
$obj->newShowFolder($sourceDir);


$obj->recursion(1);
$obj->createShowHash();

$obj->processNewShows();

subtest "Testing recursive processing with delete set as false" => sub {
$file = getcwd . "/t/test-data/done_list/test/";
ok(-e $file . "true.blood.S01E01.avi.done", "true.blood.S01E01.avi was processed. recursion enabled.")

};

# Now test Delete folder processing run
$obj->delete(1);

$obj->newShowFolder(getcwd . '/t/test-data/delete_list/');
$obj->processNewShows();

subtest "Testing recursive processing with delete set as true" => sub {
$file = getcwd . "/test-data/delete_list/test/";
ok(!-e $file . "true.blood.S02E01.avi", "true.blood.S02E01.avi was successfully deleted. Recursion enabled.")
};

done_testing();

