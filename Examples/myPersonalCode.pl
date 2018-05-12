#!/bin/perl

# This is used during development to confirm code works in my local environment.
# before I do a make install for the module.
#use lib "/Users/aspann/dev/BAS-TVShow-Import/lib/";

# Note I do not personally do any case testing as I have been using this code for some time and am very
# familiar with its operation.

use strict;
use warnings;

use Video::File::TVShow::Import;

our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

my $obj = Video::File::TVShow::Import->new();

$obj->newShowFolder("/Volumes/Drobo/completed");
$obj->showFolder("/Volumes/Drobo/TV Shows");

$obj->createShowHash();

$obj->processNewShows();

# if you wish to use the plex command here you will need to check what number matches your TV Library to trigger
# a reload of the correct items.
# See https://support.plex.tv/articles/201242707-plex-media-scanner-via-command-line/ for details.
my $plexCommand = "/Applications/Plex\\ Media\\ Server.app/Contents\\/MacOS\\/Plex\\ Media\\ Scanner -s -c 1 > /dev/null 2>&1";

system($plexCommand);

exit 0;