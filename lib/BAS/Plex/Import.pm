package BAS::Plex::Import;

use 5.012004;
use strict;
use warnings;
use Carp;

use File::Path qw(make_path);
use File::Copy;

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
	my %shows = (),
        countries => "(UK|US)",
        showNameExceptions => "(S.W.A.T)",
        _delete => undef
             };

  bless $self, $class;

  ## Additional constructor code goes here.
  ## $::exception is a gobal variable which may or may not exciting in the calling perl script that loads this module.
  if (!defined $::exceptionList) {
  ## Do nothing
  } else {
    # create an array of pairs based seperated by | character
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

  my ($self, $countries) = @_;
  $self->{countries} = $countries if defined $countries;
  return $self->{countries};
}

sub showFolder
{
  my ($self, $path) = @_;
  if (defined $path) {
    $self->{_showFolder} = $path unless !(-e $path);
  }
  return $self->{_showFolder};
}

sub newShowFolder
{
  my ($self, $path) = @_;
  if(defined $path) {
    $self->{_newDownloads} = $path unless !(-e $path);
  }
  return $self->{_newDownloads};

}

sub createShowHash {

  my ($self) = @_;
  
  croak unless defined($self->{_showFolder});
  my $directory = $self->showFolder();
  my $showNameHolder;

  opendir(DIR, $directory) or die $!;
  while (my $file = readdir(DIR)) {
    next if ($file =~ m/^\./); # skip hidden files and folders
    chomp($file);
    $self->{_shows}{lc($file)}{path} = $file;
    if ($file =~ m/\s\(?$self->{countries}\)?$/i) {
      $showNameHolder = $file;
      $showNameHolder =~ s/(.*) \(?($self->{countries})\)?/$1/gi;
      $self->{_shows}{lc($showNameHolder . " ($2)")}{path} = $file;
      $self->{_shows}{lc($showNameHolder)}{path} = $file unless (exists $self->{_shows}{lc($showNameHolder)});
    }
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

  my ($self, $show) = @_;
  return $self->{_shows}{lc($show)}{path}; 
}

sub processNewShows {

  my ($self) = @_;
  my $destination;
  
  opendir(DIR, $self->newShowFolder()) or die $!;
  while (my $file = readdir(DIR)) {
    $destination = undef;
    next if ($file =~ m/^\./);
    chomp($file);
    next if ($file =~ m/\.done$/);
    next if -d $self->newShowFolder() . "/" . $file; ## Skip non-Files
    next if ($file !~ m/s\d\de\d\d/i); # skip if SXXEXX is not present in file name
    my $showData;
   ### This block needs to be re-worked to make it clearer and more robust 
    if ($file =~ m/^$self->{showNameExceptions}/i) { ##Handle special cases like "S.W.A.T"
      ## This code is probably not very robust and will break with other exceptions. Needs to be rethought.
      $showData = Video::Filename::new($file);
      $showData->{name} =~ s/\(//;
      $showData->{name} =~ s/\)//;
      $showData->{name} =~ m/($self->{showNameExceptions})+([^0-9])*(.{4})$/;
      $showData->{name} = "$1 $4";
   ### End of block to be worked on
    } else {
      $showData = Video::Filename::new($file, { spaces => '.'});
    }
    
    $destination = $self->showFolder() . "/" . $self->showPath($showData->{name});
    $destination = $self->_createSeasonFolder($destination, $showData->{season});
  
    $self->importShow($destination,$file); 
  }
  return $self;
}

sub _handleExceptionsDatedFileNames {

  my ($self, $name) = @_;
  my $destination;

    $destination = undef;
    if($name =~ m/\(?\d{4}\)?$/) {
      if ($name =~ m/^$self->{showNameExceptions}/i) { ##Handle special cases like "S.W.A.T"
        print "Data & Exception\n";
        $name =~ m/(.*)\s?\(?(\d{4})\)?/;
        print "$1 $2\n"; 
      }
      print "Dated: $name\n";
    }
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

=head2 countries

	This subroutine sets the countries internal value and returns it.

        The default value is (UK|US)
	This allows the system to match against programs names such as Agent X US / Agent X (US) / Agent X and reference the same single folder

=head2 showFolder

	Always confirm this does not return undef before using.

	This is where the TV Show Folder resides on the file system.
	If the path is invalid this would leave the internal value as being undef.


=head2 newShowFolder

=head2 createShowHash

       This function creates a hash of show names with the correct path to store data based on the directories that are found the in the showFolder path.

=head2 showPath

       Return the Folder that stores the tv shows seasons folder.
     

=head2 processNewShows

Folders are excluded from processing
       
=head2 delete

	Set if we should delete source file after successfully importing it to Plex or if we should rename it to $file.done
        The default is false and the file is simply renamed.

        return undef if we don\'t want to delete. Return defined if we do want to delete

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
