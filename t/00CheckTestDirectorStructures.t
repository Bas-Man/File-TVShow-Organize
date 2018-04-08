
#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Cwd;


my $sourceDir = getcwd . '/t/test-data/';

my $ShowDirectory = getcwd . '/t/TV Shows/';

my $filename = $sourceDir . ".testdir";
diag "\nTest Data Directory is valid for testing\n";
ok (-e $filename, 'Show Source Directory path is valid');

$filename = $ShowDirectory . ".testdir";
diag "\nTest TV Show Directory is valid for testing\n";
ok (-e $filename, 'Show Source Directory path is valid');

done_testing();
