#!/bin/perl

  use strict;
  use warnings;

  use Video::File::TVShow::Import;

  our $excpetionList = "S.W.A.T.2017:S.W.A.T 2017";

  my $obj = Video::File::TVShow::Import->new();

  $obj->newShowsFolder("/tmp/");
  $obj->showsFolder("/absolute/path/to/TV Shows");

  if((!defined $obj->newShowFolder()) || (!defined $obj->showFolder())) {
    print "Verify your paths. Something in wrong\n";
    exit;
  }

  # Create a hash for matching file name to Folders
  $obj->createShowHash();

  # Delete files after processing. The default is to rename the files by appending ".done"
  $obj->delete(1);

  # Do not create sub folders under the the show's parent folder. All files should be dumped
  # into the parent folder. The default is to create season folders.
  $obj->seasonFolder(0);

  # Batch process a folder containing TV Show files
  $obj->processNewShows();

  # Report any file names which could not be handled automatically.
  $obj->wereThereErrors();

  #end of program
  