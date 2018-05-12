# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl BAS-TVShow-Import.t'

#########################

use strict;
use warnings;
use Data::Dumper;

use Test::More;
use Test::Carp;
use Cwd;
BEGIN {use_ok( 'Video::File::TVShow::Import' ) };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $obj = Video::File::TVShow::Import->new();

my $ShowDirectory = getcwd . '/t/TV Shows';

subtest "Set showFolder path" => sub {
$obj->showFolder($ShowDirectory);

can_ok($obj, 'createShowHash');

};

$obj->createShowHash();

subtest "Long test to check that we can get the correct folder to store Shows in based on the filename" => sub {
can_ok($obj, 'showPath');

is ($obj->showPath("Agent X"), "Agent X US", "Agent X returns Agent X US");
is ($obj->showPath("Agent X US"), "Agent X US", "Agent X US returns Agent X US");
is ($obj->showPath("Agent X (US)"), "Agent X US", "Agent X (US) returns Agent X US");

is ($obj->showPath("Travelers"), "Travelers (2016)", "Travelers returns Travelers (2016)");
is ($obj->showPath("Travelers 2016"), "Travelers (2016)", "Travelers 2016 returns Travelers (2016)");
is ($obj->showPath("Travelers (2016)"), "Travelers (2016)", "Travelers (2016) returns Travelers (2016)");

is ($obj->showPath("Bull"), "Bull (2016)", "Bull returns Bull (2016)");
is ($obj->showPath("Bull 2016"), "Bull (2016)", "Bull 2016 returns Bull (2016)");
is ($obj->showPath("Bull (2016)"), "Bull (2016)", "Bull (2016) returns Bull (2016)");

is ($obj->showPath("Doctor Who"), "Doctor Who (2005)", "Doctor Who returns Doctor Who (2005)");
is ($obj->showPath("Doctor Who 2005"), "Doctor Who (2005)", "Doctor Who 2005 returns Doctor Who (2005)");
is ($obj->showPath("Doctor Who (2005)"), "Doctor Who (2005)", "Doctor Who (2005) returns Doctor Who (2005)" );

is ($obj->showPath("S.W.A.T"), "S.W.A.T 2017", "S.W.A.T returns S.W.A.T 2017");
is ($obj->showPath("S.W.A.T 2017"), "S.W.A.T 2017", "S.W.A.T 2017 returns S.W.A.T 2017");
is ($obj->showPath("S.W.A.T (2017)"), "S.W.A.T 2017", "S.W.A.T (2017)returns S.W.A.T 2017");

is ($obj->showPath("S.W.A.T 2018"), "S.W.A.T 2018", "S.W.A.T 2018 returns S.W.A.T 2018");


is ($obj->showPath("The Librarian"), "The Librarian", "The Librarian returns The Librarian");

is ($obj->showPath("The Librarians"), "The Librarians US", "The Librarian returns The Librarian US");
is ($obj->showPath("The Librarians US"), "The Librarians US", "The Librarians US returns The Librarian US");
is ($obj->showPath("The Librarians (US)"), "The Librarians US", "The Librarians (US) returns The Librarian US");

is ($obj->showPath("The Tomorrow People (1992) - The New Generation"), "The Tomorrow People (1992) - The New Generation", "The Tomorrow People (1992) - The New Generation");

is ($obj->showPath("The Tomorrow People"), "The Tomorrow People", "The Tomorrow Pople returns The Tomorrow People");

is ($obj->showPath("The Tomorrow People US"), "The Tomorrow People US", "The Tomorrow People US");
is ($obj->showPath("The Tomorrow People (US)"), "The Tomorrow People US", "The Tomorrow People (US)");
isnt ($obj->showPath("The Tomorrow People"), "The Tomorrow People US", "The Tomorrow Poeple doesnt return The Tomorrow People US");

is ($obj->showPath("bogus"), undef, "If a show Folder does not exist return undef");

};

subtest "Test that we can empty the showHash" => sub {
    
can_ok($obj, 'clearShowHash');
$obj->clearShowHash();
is($obj->{shows},undef, "Show Hash is empty.");
};

subtest "We can reload the showHash" => sub {
$obj->createShowHash();
ok(keys %{$obj->{shows}} > 0, "showHash contains objects");
};

done_testing();

