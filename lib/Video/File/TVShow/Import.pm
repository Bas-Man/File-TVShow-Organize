package Video::File::TVShow::Import;

use 5.012004;
use strict;
use warnings;
use Carp;

use File::Path qw(make_path);
use File::Copy;
use Video::Filename;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Video::File::TVShow::Import ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.20';

# Preloaded methods go here.

sub new
{
  my $class = shift;
  my $self = {
        #default data and states. Other data is created and stored during program execution
        countries => "(UK|US)",
        delete => 0,
        verbose => 0,
        seasonFolder => 1,
             };

  bless $self, $class;

  ## Additional constructor code goes here.
  ## $::exception is a gobal variable which may or may not exist in the calling perl script that loads this module.
  if (!defined $::exceptionList) {
  ## Do nothing
  } else {
    # create an array of pairs seperated by | character
    my @list1 = split /\|/, $::exceptionList;
    # now split each item in the array with by the : character use the first value as the key and the second as value
    foreach my $item(@list1) {
      my ($key, $value) = split(/:/, $item);
      $self->{_exceptionList}{$key} = $value;
    }
  }
  return $self;
}

sub countries {

  # Set and get countries in case you want to change or add to the defaults use | as your separator
  my ($self, $countries) = @_;
  $self->{countries} = $countries if defined $countries;
  return $self->{countries};
}

sub showFolder {
  # Set and get path for where new shows are to be stored in the file system
  my ($self, $path) = @_;
  if (defined $path) {
    if ((-e $path) and (-d $path)) {
      $self->{_showFolder} = $path;
      # Append / if missing from path
      if ($self->{_showFolder} !~ m/.*\/$/) {
        $self->{_showFolder} = $self->{_showFolder} . '/';
      }
    } else {
      $self->{_showFolder} = undef;
    }
  }
  return $self->{_showFolder};
}

sub newShowFolder {
  # Set and get path to find new files to be imported from live 
  my ($self, $path) = @_;
  if (defined $path) {
    if ((-e $path) and (-d $path)) {
      $self->{_newShowFolder} = $path;
      # Append / if missing from path
      if ($self->{_newShowFolder} !~ m/.*\/$/) {
        $self->{_newShowFolder} = $self->{_newShowFolder} . '/';
      }
    } else {
      $self->{_newShowFolder} = undef;
    }
  }
  return $self->{_newShowFolder};
}

sub createShowHash {

  my ($self) = @_;
  
  # exit loudly if the path has not been defined by the time this is called
  croak unless defined($self->{_showFolder});

  # Get the root path of the TV Show folder
  my $directory = $self->showFolder();
  my $showNameHolder;

  opendir(DIR, $directory) or die $!;
  while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./); # skip hidden files and folders
    chomp($file); # trim and end of line character
    # create the inital hash strings are converted to lower case so "Doctor Who (2005)" becomes
    # "doctor who (2005)" key="doctor who (2005), path="doctor who (2005)
    $self->{shows}{lc($file)}{path} = $file;
    # hanle if there is US or UK in the show name
    if ($file =~ m/\s\(?$self->{countries}\)?$/i) {
      $showNameHolder = $file;
      # name minus country in $1 country in $2
      $showNameHolder =~ s/(.*) \(?($self->{countries})\)?/$1/gi;
      #catinate them together again with () around country
      #This now another key to the same path
      $self->{shows}{lc($showNameHolder . " ($2)")}{path} = $file;
      # create a key to the same path again with out country unless one has been already defined by another show
      # this handles something like "Prey" which is US version and "Prey UK" which is the UK version
      $self->{shows}{lc($showNameHolder)}{path} = $file unless (exists $self->{shows}{lc($showNameHolder)});
    }
    # Handle shows with Year extensions in the same manner has UK|USA
    if ($file =~ m/\s\(?\d{4}\)?$/i) {
      $showNameHolder = $file;
      $showNameHolder =~ s/(.*) \(?(\d\d\d\d)\)?/$1/gi;
      $self->{shows}{lc($showNameHolder . " ($2)")}{path} = $file;
      $self->{shows}{lc($showNameHolder . " $2")}{path} = $file;
      $self->{shows}{lc($showNameHolder)}{path} = $file unless (exists $self->{shows}{lc($showNameHolder)});
    }
  }
  closedir(DIR);
  return $self->{shows};

}


sub showPath {

  # Access the shows hash and return the correct directory path for the show name as passed to the funtion
  my ($self, $show) = @_;
  return $self->{shows}{lc($show)}{path}; 
}

sub processNewShows {

  my ($self) = @_;
  my $destination;
  
  opendir(DIR, $self->newShowFolder()) or die $!;
  while (my $file = readdir(DIR)) {
    $destination = undef;
    ## Skip hiddenfiles
    next if ($file =~ m/^\./);
    ## Trim the file name incase of end of line marker
    chomp($file);
    ## Skip files that have been processed before. They have had .done appended to to them.
    next if ($file =~ m/\.done$/);
    next if -d $self->newShowFolder() . $file; ## Skip non-Files
    next if ($file !~ m/s\d\de\d\d/i); # skip if SXXEXX is not present in file name
    my $showData;
    # Extract show name, Season and Episode
    $showData = Video::Filename::new($file);
    # Apply special handling if the show is in the exceptionList
    if (exists $self->{_exceptionList}{$showData->{name}}) { ##Handle special cases like "S.W.A.T"
      # Replace the original name value with the one found in _exceptionList
      $showData->{name} = $self->{_exceptionList}{$showData->{name}};
    } else {
      # Handle normally using '.' as the space marker name "Somthing.this" becomes "Something this"
      $showData = Video::Filename::new($file, { spaces => '.'});
    }
    
    # If we don't have a showPath skip. Probably an unhandled show name
    # store it in the UnhandledFileNames hash for reporting later.
    if (!defined $self->showPath($showData->{name})) {
      $self->{UnhandledFileNames}{$file} = $showData->{name};
      next;
    }
    # Create the path string for storing the file in the right place
    $destination = $self->showFolder() . $self->showPath($showData->{name});
    # if this is true. Update the $destination and create the season subfolder if required.
    # if this is false. Do not append the season folder. files should just be stored in the root of the show folder. 
    if($self->seasonFolder()) {
      $destination = $self->createSeasonFolder($destination, $showData->{season});
    };
    # Import the file. This will use rsync to copy the file into place and either rename or delete.
    # see importShow() for implementation details
    $self->importShow($destination,$file); 
  }
  return $self;
}

sub wereThereErrors {

  my ($self) = @_;
  
  # Check if there has been any files that Video::Filename could not handle
  # Check that the hash UnHandledFileNames has actually been created before checking that is is not empty
  # or you will get an error.
  if ((defined $self->{UnhandledFileNames}) && (keys $self->{UnhandledFileNames})) {
    print "\nThere were unhandled files in the directory\n";
    print "consider adding them to the exceptionList\n###\n";
    foreach my $key (keys $self->{UnhandledFileNames}) {
      print "### " .  $key . " ==> " . $self->{UnhandledFileNames}{$key} . "\n";
    }
    print "###\n";
  }
  
  return $self;
}

sub delete {

  my ($self, $delete) = @_;

  return $self->{delete} if(@_ == 1);
  
  if (($delete =~ m/[[:alpha:]]/) || ($delete != 0) && ($delete != 1)) {
    print STDERR "Invalid arguments passed. Value not updated\n";
    return undef;
  } else {
    if ($delete == 1) {
      $self->{delete} = 1;
    } elsif ($delete == 0) {
      $self->{delete} = 0;
    }
    return $self->{delete};
  }
}

sub verbose {
   my ($self, $verbose) = @_;

  return $self->{verbose} if(@_ == 1);
  
  if (($verbose =~ m/[[:alpha:]]/) || ($verbose != 0) && ($verbose != 1)) {
    print STDERR "\n### Invalid arguments passed. Value not updated\n";
    return undef;
  } else {
    if ($verbose == 1) {
      $self->{verbose} = 1;
    } elsif ($verbose == 0) {
      $self->{verbose} = 0;
    }
    return $self->{verbose};
  }
}

sub seasonFolder {
   my ($self, $seasonFolder) = @_;

  return $self->{seasonFolder} if(@_ == 1);
  
  if (($seasonFolder =~ m/[[:alpha:]]/) || ($seasonFolder != 0) && ($seasonFolder != 1)) {
    print STDERR "\n### Invalid arguments passed. Value not updated\n";
    return undef;
  } else {
    if ($seasonFolder == 1) {
      $self->{seasonFolder} = 1;
    } elsif ($seasonFolder == 0) {
      $self->{seasonFolder} = 0;
    }
    return $self->{seasonFolder};
  }
}

sub createSeasonFolder {

  my ($self, $_path, $season) = @_;

  my $path = $_path .  '/';
 
  if (length($season) == 0) {
    $path = $path . 'Specials'
  } else {
    $path = $path . 'Season' . $season;
  }
  # Show Season folder being created if verbose mode is true.
  if($self->verbose) {
    make_path($path, { verbose => 1 }) unless -e $path;
  } else {
    # Verbose mode is false so work silently.
    make_path($path) unless -e $path;
  }
  return $path;
}


sub importShow {

  my ($self, $destination, $file) = @_;
  my $source;

  # If the destination folder is not defined or no file is passed exit with errors
  carp "Destination not passed." unless defined($destination);
  carp "File not passed." unless defined($file);

  # rewrite paths so they are rsync friendly. This means escape spaces and other special characters.
  ($destination, $source) = _rsyncPrep($destination,$self->newShowFolder());

  # create the command string to be used in system() call
  # Set --progress if verbose is true
  my $command = "rsync -ta ";
  $command = $command . "--progress " if ($self->verbose);
  $command = $command . $source . $file . " " . $destination;

  system($command);
  
  if($? == 0) { 
    # If delete is true unlink file.  
    if($self->delete) {
      unlink($source . $file);
    } else {
      # delete is false so merely rename the file by appending .done
      move($source . $file, $source . $file . ".done")
    }
  } else {
    #report failed processing? Error on rsync command return code
    print "Something went very wrong. Rsync failed for some reason.¥n"
  }
  return $self;

}

# This interal sub-routine prepares paths for use with external rsynch command
# Need to escape special characters
sub _rsyncPrep {
  
  my ($dest, $source) = @_;

  # escape spaces and () characters to work with the rsync command.
  $dest =~ s/\(/\\(/g;
  $dest =~ s/\)/\\)/g;
  $dest =~ s/ /\\ /g;
  $dest = $dest . "/";

  $source =~ s/ /\\ /g;
  #$source = $source . "/";

  return $dest, $source;
}

1;


__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Video::File::TVShow::Import - Perl module to move TVShow Files into their matching Show Folder
on a media server. 

=head1 SYNOPSIS

  use Video::File::TVShow::Import;

  our $excpetionList = "S.W.A.T.2017:S.W.A.T 2017|Other:other";

  my $obj = Video::File::TVShow::Import->new();

  $obj->newShowsFolder("/tmp/");
  $obj->showsFolder("/absolute/path/to/TV Shows");

  if((!defined $obj->newShowFolder()) || (!defined $obj->showFolder())) {
    print "Verify your paths. Something in wrong\n";
    exit;
  }

  # Create a hash for matching file name to Folders
  $obj->createShowHash();

  # Delete files are processing.
  $obj->delete(1);

  # Don't create sub Season folders under the root show name folder.
  # Instead just dump them all into the root folder
  $obj->seasonFolder(0);
  
  # Batch process a folder containing TVShow files
  $obj->processNewShows();

  # Report any file names which could not be handled automatically.
  $obj->wereThereErrors();

  #end of program


=head1 DESCRIPTION

      This module moves TV show files from the folder where they currently exist into the correct folder based on
      show name and season.

      Folder structure: /base/folder/Castle -> Season1 -> Castle.S01E01.avi
                                               Season2 -> Castle.S02E01.avi 
                                               Specials -> Castle.S00E01.avi

      This season folder behaviour can be disabled by calling seasonFolder(0). In this case
      all files would simply be placed under Castle without sorting into SeasonX
      
      Source files are renamed or deleted upon successful relocation.

      Possible uses might include moving the files from an original rip directory and moving them into the correct
      folder structure for media servers such as Plex or Kodi. Another use might be to sort shows that are already
      in a single folder and to move them to a Season by Season or Special folder struture for better folder 
      management.

      Works on Mac OS and *nix systems.

=head2 EXPORT

  None by default.

=head1 Methods

=head2 new

  $obj = Video::File::TVShow::Import->new();

  This subroutine creates a new object of type Video::File::TVShow::Import

  If the global varible $exceptionList is defined we load this data into a hash for later use to handle naming
  complications.

  E.G file: S.W.A.T.2017.S01E01.avi is not handled correctly by Video::Filename so we need to know to handle this
  differently. $exceptionList can be left undefined if you do not need to use it. Its format is
  "MatchCase:DesiredValue|MatchCase:DesiredValue"

=head2 countries

  $obj->countries("(US|UK|AU)");
  $obj->countries();

  This subroutine sets the countries internal value and returns it.

  The default value is (UK|US)

  This allows the system to match against programs names such as Agent X US / Agent X (US) / Agent X 
  and reference the same single folder

=head2 showFolder

  $obj->showFolder("/path/to/folder"); Set the path return undef is the path is invalid
  $obj->showFolder();         		     Return the path to the folder

  Always confirm this does not return undef before using.
  undef will be returned in the path is invalid. 

  Also a valid "path/to/folder" will always return "path/to/folder/"

  This is where the TV Show Folder resides on the file system.
  If the path is invalid this would leave the internal value as being undef.


=head2 newShowFolder

  $obj->newShowFolder("/path/to/folder"); Set the path return undef is the path is invalid
  $obj->newShowFolder(); 		              Return the path to the folder

  Always confirm this does not return undef before using.
  undef will be returned if the path is invalid. 

  Also a valid "path/to/folder" will always return "path/to/folder/"

  This is where new files to be add to the TV Show store reside on the file system.

=head2 createShowHash

  $obj->createShowHash;

  This function creates a hash of show names with the correct path to store data based on the
  directories that are found in showFolder.

  Examples:
	Life on Mars (US) creates a 3 keys which point to the same folder
					key: life on mars (us) => folder: Life on Mars (US)
					key: life on mars us   => folder: Life on Mars (US)
					key: life on mars      => folder: Life on Mars (US)

	However if there already exists a folder: "Life on Mars" and a folder "Life on Mars (US)
	the following hash key:folder pairs will be created note that the folder differ
					key: life on mars      => folder: Life on Mars
					key: life on mars (us) => folder: Life on Mars (US)
					key: life on mars us   => folder: Life on Mars (US)

  As such file naming relating to country of origin is important if you are important to versions of the
  same show based on country.

=head2 showPath

  $obj->showPath("Life on Mars US") returns the name of the folder "Life on Mars (US)" 
  or undef if "Life on Mars US" does not exist as a key. 

  No key will be found if there was no folder found when $obj->createShowHash was called.
	
  Example:

  my $file = Video::Filename::new("Life.on.Mars.(US).S01E01.avi", { spaces => '.' });
  # $file->{name} now contains "Life on Mars (US)" 
  # $file->{season} now contains "1"

  my $dest = "/path/to/basefolder/" . $obj->showPath($file->{name});
  result => $dest now cotains "/path/to/basefolder/Life on Mars (US)/"

  $dest = $obj->createSeasonFolder($dest,$file->{season});
  result => $dest now contains "/path/to/basefolder/Life on Mars (US)/Season1/"
	
=head2 processNewShows

  $obj->processNewShows();
        
  This function requires that $obj->showFolder("/absolute/path") and $obj->newShowFolder("/absoute/path")
  have already been called as they will be used with calls as $self->showFolder and $self->newShowFolder

  This is the main process for batch processing of a folder of show files.
  Hidden files, files named file.done as well as directories are excluded from being processed.

=head2 importShow

  $obj->importShow("/absolute/path/to/folder/", "/absolute/path/to/file");

  folder is where to store the file.

  This function does the heavy lifting of actually moving the show file into the determined folder.
  This function is called by processNewShows which does the work to
  determine the paths to folder and file. 
  This function could be called on its own after you have verified "folder" and "file"

  It uses a sytem() call to rsync which always checks that the copy was successful.

  This function then checks the state of $obj->delete to decide if the processed file should be renamed "file.done"
  or should be removed using unlink();

=head2 delete
	
  $obj->delete return the current true or false state (1 or 0)
  $obj->delete(1) set delete to true
  $obj->delete(0) set delete to false

  Input should be 0 or 1. 0 being do not delete. 1 being delete.

  Set if we should delete source file after successfully importing it to the tv store or 
  if we should rename it to $file.done

  The default is false and the file is simply renamed.

  Return undef if the varible passed to the function is not valid. Do not change the current state of delete.

=head2 seasonFolder

  $obj->seasonFolder return the current true or false state (1 or 0)
  $obj->seasonFolder(0) or seasonFolder(1) sets and returns the new value.
  $obj->seasonFolder() returns undef if the input is invalid and the internal state is unchanged.

  if(!defined $obj->seasonFolder("x")) {
    print "You passed and invalid value\n";
  }

  The default is true.

=head2 wereThereErrors

  $obj->wereThereErrors;

  This should be called at the end of the program to report if any file names could not be handled correctly
  resulting in files not being processed. These missed files can then be manually moved or their show name can
  be added to the exceptionList variable. Remember to match the NAME preceeding SXX and to give the corrected
  name 

  EG S.W.A.T.2017.SXX should get an entry such as:
  exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

=head2 createSeasonFolder

  $obj->createSeasonFolder("/absolute/path/to/show/folder/",$seasonNumber)

  creates a folder within "/absolute/path/to/show/folder/" by calling make_path()
  returns the newly created path "absolute/path/to/show/folder/SeasonX/" or 
  "/absolute/path/to/show/folder/Specials/"

  note: "/absolute/path/to/show/folder/" is not verified to be valid and is assumed to have been
  checked before being passed

  Based on SXX
  S01 creates Season1
  S00 creates Specials

=head2 verbose
  $obj->verbose();
  $obj->verbose(0);
  $obj->verbose(1);

  Return undef if passed an invalid imput and write to STDERR. Current value of verbose is not changed.
  Return 0 if verbose mode is off. Return 1 if verbose mode is on.
  
  This state is checked by createSeasonFolder(), importShow()

=head1 INCOMPATIBILITIES

Windows systems.


=head1 SEE ALSO


  File::Path
  File::Copy
  Video::Filename

=head1 AUTHOR

Adam Spann, E<lt>adam_spann@hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 by Adam Spann

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
