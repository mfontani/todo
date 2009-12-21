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
ok ( !-e '.todo', 'no .todo present');

my $t = '';
$t .= "A\t\@work +prj\twork\n";
$t .= "B\t\@work +break\tdrink coffee\n";
$t .= "B\t\@home +morning\tdrink coffee\n";
write_file( '.todo', $t );
{
  my @lines = qx/todo/;
  ok ( @lines == 4, 'local todo shows 4 lines');
  ok ( $lines[0] =~ /^Searching \.todo\:$/, 'first output line is informative' )
    or diag("First line doesn't match: ~~$lines[0]~~");
  foreach ( 1..$#lines ) {
    ok ($lines[$_] =~ /^\#\d\s+\w\s+\[\+\w+\s\@\w+]\s+[\w\s]+$/, "Output line $_ has correct form")
      or diag( "Line $_ doesn't have correct form: >$lines[$_]<");
  }
}
unlink '.todo';

###### END TESTS

# restore ~/.todo and .todo if they existed
__tmp_restore($tmphome, "$ENV{HOME}/.todo");
__tmp_restore($tmphere,'.todo');
