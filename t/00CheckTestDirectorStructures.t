
#########################

use strict;
use warnings;

use Test::More;
use Cwd;


diag "\n\nCheck that we have working Testing directories test-data and TV Shows\n";
my $sourceDir = getcwd . '/t/test-data/';

my $ShowDirectory = getcwd . '/t/TV Shows/';

my $filename = $sourceDir . ".testdir";

ok (-e $filename, 'Show Source Directory path is valid') or BAIL_OUT("test-dir is not valid.\n");

$filename = $ShowDirectory . ".testdir";

ok (-e $filename, 'TV Show Directory path is valid') or BAIL_OUT("TV Show is not valid.\n");

done_testing();
