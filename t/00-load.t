#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;
use IPC::Cmd qw(can_run);

plan tests => 2;

use_ok( 'File::TVShow::Organize' ) || BAIL_OUT("Unable to load module\n");

my $command = can_run('rsync');
like($command, qr/rsync$/, "Found rsync command\n") || BAIL_OUT("rsync not found\n");
