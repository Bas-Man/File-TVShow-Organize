use strict;
use warnings;

use Test::More;
use Cwd;
use File::chdir;

my $file;
my $outputPath;
my $inputPath = "t/test-data/";

diag "\n\nCheck Folders Verify import of files to their correct destintations\n";
$outputPath = "t/TV Shows/The Flash 2014/Season2/";
$file = getcwd . "/" . $outputPath;
ok(-e $file . "the.flash.2014.S02E09.hdtv-lol-eng.srt", "the.flash.2014.S02E09.hdtv-lol-eng.srt found in $outputPath");
ok(-e $file . "The.Flash.2014.S02E09.720p.HDTV.X264-DIMENSION[eztv].mkv", "The.Flash.2014.S02E09.720p.HDTV.X264-DIMENSION[eztv].mkv found in $outputPath");
ok(-e $file . "the.flash.2014.S02E09.hdtv-lol.mp4", "the.flash.2014.S02E09.hdtv-lol.mp4 found in $outputPath");
ok(-e $file . "the.flash.2014.S02E09.hdtv-por.srt", "the.flash.2014.S02E09.hdtv-por.srt found in $outputPath");

$outputPath = "t/TV Shows/Doctor Who (2005)/Specials/";
$file = getcwd . "/" . $outputPath;

ok(-e $file . "Doctor.Who.2005.S00E01.avi", "Doctor.Who.2005.S00E01.avi found in $outputPath");
ok(!-e $file . "Doctor.Who.2005.2014.Christmas.Special.Last.Christmas.720p.HDTV.x264-FoV.mkv", "Doctor.Who.2005.2014.Christmas.Special.Last.Christmas.720p.HDTV.x264-FoV.mkv was not processed");

$outputPath = "t/TV Shows/Luther/Specials/";
$file = getcwd . "/" . $outputPath;

ok(-e $file . "Luther-S00E06-The.Journey.So.Far.mp4", "Luther-S00E06-The.Journey.So.Far.mp4 found in $outputPath");
ok(-e $file . "Luther-S00E06-The.Journey.So.Far.srt", "Luther-S00E06-The.Journey.So.Far.srt found in $outputPath");

$outputPath = "t/TV Shows/S.W.A.T 2017/Season1/";
$file = getcwd . "/" . $outputPath;
ok(-e $file . "S.W.A.T.2017.S01E01.avi", "S.W.A.T.2017.S01E01.avi found in $outputPath");


done_testing();
