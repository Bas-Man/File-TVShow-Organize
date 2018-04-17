package BAS::Plex::Import;

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

# This allows declaration	use BAS::Plex::Import ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

# Preloaded methods go here.

sub new
{
  my $class = shift;
  my $self = {
        #default data and states. Other data is created and stored during program execution
        countries => "(UK|US)",
        _delete => undef,
             };

  bless $self, $class;

  ## Additional constructor code goes here.
  ## $::exception is a gobal variable which may or may not exciting in the calling perl script that loads this module.
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
  # Set and get path for where new shows are to be stored in Plex
  my ($self, $path) = @_;
  if (defined $path) {
    $self->{_showFolder} = $path unless !(-e $path);
  }
  return $self->{_showFolder};
}

sub newShowFolder {
  # Set and get path to find new files to be imported into Plex
  my ($self, $path) = @_;
  if(defined $path) {
    $self->{_newDownloads} = $path unless !(-e $path);
  }
  return $self->{_newDownloads};

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
    $self->{_shows}{lc($file)}{path} = $file;
    # hanle if there is US or UK in the show name
    if ($file =~ m/\s\(?$self->{countries}\)?$/i) {
      $showNameHolder = $file;
      # name minus country in $1 country in $2
      $showNameHolder =~ s/(.*) \(?($self->{countries})\)?/$1/gi;
      #catinate them together again with () around country
      #This now another key to the same path
      $self->{_shows}{lc($showNameHolder . " ($2)")}{path} = $file;
      # create a key to the same path again with out country unless one has been already defined by another show
      # this handles something like "Prey" which is US version and "Prey UK" which is the UK version
      $self->{_shows}{lc($showNameHolder)}{path} = $file unless (exists $self->{_shows}{lc($showNameHolder)});
    }
    # Handle shows with Year extensions in the same manner has UK|USA
    if ($file =~ m/\s\(?\d{4}\)?$/i) {
      $showNameHolder = $file;
      $showNameHolder =~ s/(.*) \(?(\d\d\d\d)\)?/$1/gi;
      $self->{_shows}{lc($showNameHolder . " ($2)")}{path} = $file;
      $self->{_shows}{lc($showNameHolder . " $2")}{path} = $file;
      $self->{_shows}{lc($showNameHolder)}{path} = $file unless (exists $self->{_shows}{lc($showNameHolder)});
    }
  }
  closedir(DIR);
  return $self->{_shows};

}


sub showPath {

  # Access the _shows hash and return the correct directory path for the show name as passed to the funtion
  my ($self, $show) = @_;
  return $self->{_shows}{lc($show)}{path}; 
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
    next if -d $self->newShowFolder() . "/" . $file; ## Skip non-Files
    next if ($file !~ m/s\d\de\d\d/i); # skip if SXXEXX is not present in file name
    my $showData;
    # Extract show name, Season and Episode
    $showData = Video::Filename::new($file);
    # Apply special handling if they show is in the exceptionList
    if (exists $self->{_exceptionList}{$showData->{name}}) { ##Handle special cases like "S.W.A.T"
      $showData->{name} = $self->{_exceptionList}{$showData->{name}};
    } else {
      # Handle normally using '.' as the space marker Somthing.this becomes Something this
      $showData = Video::Filename::new($file, { spaces => '.'});
    }
    
    # If we don't have a showPath skip. Probably an unhandled show name
    # store it in the UnhandledFileNames hash for reporting later.
    if (!defined $self->showPath($showData->{name})) {
      $self->{UnhandledFileNames}{$file} = $showData->{name};
      next;
    }
    # Create the path string for storing the file in the right place
    $destination = $self->showFolder() . "/" . $self->showPath($showData->{name});
    $destination = $self->_createSeasonFolder($destination, $showData->{season});
  
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
      print "### " .  $key . ": " . $self->{UnhandledFileNames}{$key} . "\n";
    }
    print "###\n";
  }
  
  return $self;
}

## Legacy code. Not used anymore.
sub _handleExceptionsDatedFileNames {

  my ($self, $name) = @_;

    if($name =~ m/\(?\d{4}\)?$/) {
      if (exists $self->{_exceptionList}{$name}) { ##Handle special cases like "S.W.A.T"
        $name = $self->{_exceptionList}{$name};
      }
    }
  return $name;
}

sub delete {

  my $self;
  my $delete;

  ($self, $delete) = @_;

  if ((defined $delete) && ($delete == 1)) {
    $self->{_delete} = defined;
  } elsif ((defined $delete) && ($delete == 0)) {
    $self->{_delete} = undef;
  }
  return $self->{_delete};
}

sub _createSeasonFolder {

  my ($self, $_path, $season) = @_;

  my $path = $_path .  '/';
 
  if (length($season) == 0) {
    $path = $path . 'Specials'
  } else {
    $path = $path . 'Season' . $season;
  }
  make_path($path, { verbose => 1 }) unless -e $path;
  return $path;
}


sub importShow {

  my ($self, $destination, $file) = @_;
  my $source;

  carp "Destination not passed." unless defined($destination);
  carp "File not passed." unless defined($file);

  ($destination, $source) = _rsyncPrep($destination,$self->showFolder());

  my $command = "rsync -ta --progress " . $self->newShowFolder() . "/" . $file . " " . $destination;

  system($command);
  print "Rsync Return Code: " . $? . "\n";
  if($? == 0) { 
  print "We can Delete $file\n";
  move($source . $file, $source . $file . ".done")
  }
  return $self;

}

# This interal sub-routine prepares paths for use with external rsynch command
# Need to escape special characters
sub _rsyncPrep {
  
  my ($dest, $source) = @_;

  # replace space with \space for rsync to work
  $dest =~ s/\(/\\(/g;
  $dest =~ s/\)/\\)/g;
  $dest =~ s/ /\\ /g;
  $dest = $dest . "/";

  $source =~ s/ /\\ /g;
  $source = $source . "/";

  return $dest, $source;
}

1;


__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

BAS::Plex::Import - Perl extension for blah blah blah

=head1 SYNOPSIS

  use BAS::Plex::Import;

  our $excpetionList = "S.W.A.T.2017:S.W.A.T 2017|Other:other";

  my $obj = BAS::Plex::Import->new();

  $obj->newShowsFolder("/tmp/");
  $obj->showsFolder("/plex/TV Shows");

=head1 DESCRIPTION

Stub documentation for BAS::Plex::Import, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.

=head1 Methods

=cut

=head2 new

	This subroutine creates a new object of type BAS::Plex::Import
        If the global varible $exceptionList is defined we load this data into a hash for later use to handle naming
	complications.
	E.G file: S.W.A.T.2017.S01E01.avi is not handled correctly by Video::Filename so we need to know to handle this
	differently. $exceptionList can be left undefined if you do not need to use it. Its format is
	"MatchCase:DesiredValue|MatchCase:DesiredValue"

=head2 countries

	This subroutine sets the countries internal value and returns it.

        The default value is (UK|US)
	This allows the system to match against programs names such as Agent X US / Agent X (US) / Agent X 
	and reference the same single folder

=head2 showFolder

	Always confirm this does not return undef before using.

	This is where the TV Show Folder resides on the file system.
	If the path is invalid this would leave the internal value as being undef.

        $obj->showFolder("/path/to/folder"); Set the path return undef is the path is invalid
        $obj->showFolder(); 		     Return the path to the folder


=head2 newShowFolder

	Always confirm this does not return undef before using.

	This is where new files to be add to Plex reside on the file system.
	If the path is invalid this would leave the internal value as being undef.

        $obj->newShowFolder("/path/to/folder"); Set the path return undef is the path is invalid
        $obj->newShowFolder(); 		     Return the path to the folder

=head2 createShowHash

        This function creates a hash of show names with the correct path to store data based on the
	directories that are found the in the showFolder path.

=head2 showPath

       Return the Folder that stores the tv shows seasons folder.
     

=head2 processNewShows

	Folders are excluded from processing
       
=head2 delete

	Set if we should delete source file after successfully importing it to Plex or 
	if we should rename it to $file.done

        The default is false and the file is simply renamed.

        Return undef if we don't want to delete. Return defined if we do want to delete

=head2 wereThereErrors

	This should be called at the end of the program to report if any file names could not be handled correctly
	resulting in files not being processd. These missed files can then be manually moved or their show name can
	be added to the exceptionList variable. remember to match the NAME preceeding SXX and to give the corrected
	name 
	EG S.W.A.T.2017.SXX should get an entry such as:
	exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

=head2 _createSeasonFolder

        This is an internal function and should not be called by the programmer directly.

	Create season folder with the TV Shows folder based on SXX
        S01 creates Season1
	S00 creates Specials

=cut

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Adam Spann, E<lt>aspann@apple.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Adam Spann

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
