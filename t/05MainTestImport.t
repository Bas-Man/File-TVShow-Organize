# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 05MainTestImport.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More; #tests => 6;
use Test::Carp;
use Video::File::TVShow::Import;
use Cwd;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017|S.W.A.T.2018:S.W.A.T 2018";
our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

my $obj = Video::File::TVShow::Import->new();

my $sourceDir = getcwd . '/t/test-data/done_list/';

my $ShowDirectory = getcwd . '/t/TV Shows';

$obj->showFolder($ShowDirectory);

$obj->newShowFolder($sourceDir);

$obj->createShowHash();

can_ok($obj, 'verbose');

subtest "About to process done_list Folder." => sub {
can_ok($obj, 'wereThereErrors');
is($obj->{UnhandledFileNames}, undef, "No UnhandedFiles have been found"); 

can_ok($obj, 'processNewShows');
$obj->processNewShows();
can_ok($obj, 'importShow');

};

$obj->delete(1);

$obj->newShowFolder(getcwd . '/t/test-data/delete_list/');
$obj->processNewShows();


subtest "Check if there were errors" => sub {
$obj->wereThereErrors();
ok($obj->{UnhandledFileNames} =~ /HASH/, "Unhandled files were found");
};

#diag explain $obj;

#my $d = Data::Dumper->new([$obj]);
#print $d->Dump;

done_testing();

