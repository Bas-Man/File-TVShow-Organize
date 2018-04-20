# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-Plex-Import.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Carp;
use BAS::Plex::Import;
use Cwd;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

our $exceptionList = "S.W.A.T.2017:S.W.A.T 2017";

my $obj = BAS::Plex::Import->new();

ok($obj->_handleExceptionsDatedFileNames("S.W.A.T.2017") =~ m/S.W.A.T 2017/, "Returned S.W.A.T 2017"); 

done_testing();

