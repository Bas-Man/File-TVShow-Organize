use strict;
use warnings;

use Test::More;
use Cwd;
use File::chdir;

my $file;

diag "\n\nCheck The Flash 2014 Folder\n";
$file = getcwd . "/t/TV Shows/The Flash 2014/Season2/";
ok(-e $file . "the.flash.2014.S02E09.hdtv-lol-eng.srt", "the.flash.2014.S02E09.hdtv-lol-eng.srt found in " . "\"The Flash 2014/Season2\"");
ok(-e $file . "The.Flash.2014.S02E09.720p.HDTV.X264-DIMENSION[eztv].mkv", "The.Flash.2014.S02E09.720p.HDTV.X264-DIMENSION[eztv].mkv found in " . "\"The Flash 2014/Season2\"");
ok(-e $file . "the.flash.2014.S02E09.hdtv-lol.mp4", "the.flash.2014.S02E09.hdtv-lol.mp4 found in " . "\"The Flash 2014/Season2\"");
ok(-e $file . "the.flash.2014.S02E09.hdtv-por.srt", "the.flash.2014.S02E09.hdtv-por.srt found in " . "\"The Flash 2014/Season2\"");

done_testing();
