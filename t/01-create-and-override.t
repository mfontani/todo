#!/usr/bin/env perl
use strict;
use warnings;
use File::Temp qw/ :POSIX /;
use File::Copy;
use File::Slurp;
use Test::More tests => 5;

sub __tmp_backup {
  my ($from) = @_;
  my $tmpfile  = tmpnam();
  if ( -e $from ) {
    diag "$from exists, backing up to $tmpfile";
    copy $from, $tmpfile or die "Can't copy $from to $tmpfile: $!";
    unlink $from or die "Can't unlink $from: $!";
  }
  return $tmpfile;
}
sub __tmp_restore {
  my ($tmp,$to) = @_;
  if ( -e $tmp ) {
    diag "Restoring $to from $tmp";
    copy $tmp, $to or die "Can't copy back $tmp to $to: $!";
  }
}

# move away ~/.todo and .todo if exists
my $tmphome  = __tmp_backup("$ENV{HOME}/.todo");
my $tmphere = __tmp_backup('.todo');

###### TESTS

ok ( !-e "$ENV{HOME}/.todo", 'no ~/.todo present');
qx{./todo};
ok ( -e "$ENV{HOME}/.todo", 'running todo creates ~/.todo');
ok ( !-s "$ENV{HOME}/.todo", 'running todo creates empty ~/.todo');
ok ( !-e '.todo', 'no .todo present');

# write one line to current directory todo
write_file( '.todo', "A\t\@work +prj\twork ;)\n"x2 );
{
  my @lines = qx/todo/;
  ok ( @lines == 3, 'used local .todo file first');
}
unlink '.todo';

###### END TESTS

# restore ~/.todo and .todo if they existed
__tmp_restore($tmphome, "$ENV{HOME}/.todo");
__tmp_restore($tmphere,'.todo');
