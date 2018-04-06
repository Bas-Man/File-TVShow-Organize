package BAS::Plex::Import;

use 5.012004;
use strict;
use warnings;
use Carp;

use File::Path qw(make_path);
use File::Copy;
#use File::Basename;

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

my $countries = "(US|UK)";
my $ShowNameExceptions = "(S.W.A.T)";

# Preloaded methods go here.

sub new
{
  my $class = shift;
  my $self = {
	my %shows = (),
             };

  
  bless $self, $class;
  return $self;
}

sub showFolder
{
  my ($self) = @_;
  return $self->{_showFolder};
} 

sub set_showFolder
{
  my ($self, $path) = @_;
  $self->{_showFolder} = $path unless !(-e $path);
  return $self->{_showFolder};
}

sub newDownloads
{
  my ($self) = @_;
  return $self->{_newDownloads};
} 

sub set_newDownloads
{
  my ($self, $path) = @_;
  $self->{_newDownloads} = $path unless !(-e $path);
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
    if ($file =~ m/\s\(?$countries\)?$/i) {
      $showNameHolder = $file;
      $showNameHolder =~ s/(.*) \(?($countries)\)?/$1/gi;
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


sub getShowPath {

  my ($self, $show) = @_;
  return $self->{_shows}{lc($show)}{path}; 
}

sub processNewDownloads {

  my ($self) = @_;
  my $destination;
  
  opendir(DIR, $self->{_newDownloads}) or die $!;
  while (my $file = readdir(DIR)) {
    $destination = undef;
    next if ($file =~ m/^\./);
    chomp($file);
    next if ($file =~ m/\.done$/);
    next if -d $self->{_newDownloads} . "/" . $file; ## Skip non-Files
    next if ($file !~ m/s\d\de\d\d/i); # skip if SXXEXX is not present in file name
    my $showData = Video::Filename::new($file, { spaces => '.'});
    if ($file =~ m/^$ShowNameExceptions/i) { ##Handle special cases like "S.W.A.T"
      $showData->{name} = $ShowNameExceptions;
      $showData->{name} =~ s/\(//;
      $showData->{name} =~ s/\)//;
    }
    $destination = $self->showFolder() . "/" . $self->getShowPath($showData->{name});
    $destination = $self->createSeasonFolder($destination, $showData->{season});
  
    $self->importShow($destination,$file); 
  }
  return $self;
}

sub createSeasonFolder {

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

  my $command = "rsync -ta --progress " . $self->newDownloads() . "/" . $file . " " . $destination;

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
  blah blah blah

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

=head2 showFolder

	Access the Show Folder path set using set_showFolder()

	Always confirm this does not return undef before using.

=head2 set_showFolder

	Set the Show Folder path.

	This is where the TV Show Folder resides on the file system.
	If the path is invalid this would leave the internal value as being undef.


=head2 newDownloads

	Access the download folder where TV Shows are downloaded into.

	Always confirm this does not return undef before using.

=head2 set_newDownloads

	Set where to look for new downloads that need to be processed.

	If the path is invalid this would leave the internal value as being undef.

=head2 createShowHash

       This function creates a hash of show names with the correct path to store data based on the directories that are found the in the showFolder path.

=head2 getShowPath

       Return the Folder that stores the tv shows seasons folder.
     

=head2 processNewDownloads

Folders are excluded from processing
       
=head2 createSeasonFolder


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
