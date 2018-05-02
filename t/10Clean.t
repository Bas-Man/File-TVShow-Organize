use strict;
use warnings;

use Test::More tests => 2;
use Cwd;
use File::chdir;
use File::Path 'remove_tree';

diag "\n\nRemove TV Show Folder after competing tests\n";
{
  local $CWD = getcwd() . "/t/";
  remove_tree("TV Shows");
  ok(!-e $CWD . "TV Shows");
  remove_tree("test-data");
  ok(!-e $CWD . "test-data");
}
