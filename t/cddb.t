#!perl -w
# $Id: cddb.t,v 1.15 2001/03/25 03:49:03 troc Exp $
# Copyright 1998 Rocco Caputo <troc@netrus.net>.  All rights reserved.
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.

use strict;
use CDDB;

BEGIN { select(STDOUT); $|=1; print "1..32\n"; };

my ($i, $result);

### test connecting

my $cddb = new CDDB( Host  => 'freedb.freedb.org',
                     Port  => 8880,
                     Debug => 0,
                   );

defined($cddb) || print 'not '; print "ok 1\n";

### test genres

my @test_genres = qw(blues classical country data folk jazz misc newage
                     reggae rock soundtrack
                    );
my @cddb_genres = $cddb->get_genres();

if (@cddb_genres) {
  print "ok 2\n";
  if (@cddb_genres == @test_genres) {
    print "ok 3\n";
    @test_genres = sort @test_genres;
    @cddb_genres = sort @cddb_genres;
    $result = 'ok';
    while (my $test = shift(@test_genres)) {
      $result = 'not ok' if ($test ne shift(@cddb_genres));
    }
    print "$result 4\n";
  }
}
else {
  print "not ok 2\n";
  print "not ok 3\n";
  print "not ok 4\n";
}

### helper sub: replace != tests with "not off by 5%"

sub not_near {
  my ($live, $test) = @_;
  return (abs($live-$test) > ($test * 0.05));
}

### sample TOC info for next few tests

# A CD table of contents is a list of tracks acquired from whatever Your
# Particular Operating System uses to manage CD-ROMs.  Often, it's some
# sort of API or ioctl() interface.  You're on your own here.
#
# Whatever you use should return the TOC as a list of whitespace-delimited
# records.  Each record should have three fields: the track number, the
# minutes offset of the track's beginning, the seconds offset of the track's
# beginning, and the leftover frames of the track's offset.  In other words,
#    track_number M S F  (where M S and F are defined in the CD-I spec.)
#
# Special information is indicated by these "virtual" track numbers:
#   999: lead-out information (same as regular track format)
#  1000: error reading TOC (minutes and seconds are unused; frame
#        contains a text message describing the error)
#
# Sample TOC information:

my @toc = ( "1   0  2  37",  # track  1 starts at 00:02 and 37 frames
            "2   1  38 17",  # track  2 starts at 01:38 and 17 frames
            "3   11 57 30",  # track  3 starts at 11:57 and 30 frames
            "4   16 26 25",  # track  4 starts at 16:26 and 25 frames
            "5   18 48 7",   # track  5 starts at 18:48 and 7  frames
            "6   23 46 42",  # track  6 starts at 23:46 and 42 frames
            "7   35 15 20",  # track  7 starts at 35:15 and 20 frames
            "8   39 18 12",  # track  8 starts at 39:18 and 12 frames
            "9   48 38 47",  # track  9 starts at 48:38 and 47 frames
            "10  51 45 7",   # track 10 starts at 51:45 and 7  frames
            "11  61 6  32",  # track 11 starts at 61:06 and 32 frames
            "12  66 34 30",  # track 12 starts at 66:34 and 30 frames
            "999 75 16 5",   # leadout  starts at 75:15 and 5  frames
          );

### calculate CDDB ID

my ($id, $track_numbers, $track_lengths, $track_offsets, $total_seconds) =
  $cddb->calculate_id(@toc);

($id ne 'b811a20c') && print 'not '; print "ok 5\n";
&not_near($total_seconds, 4514) && print 'not '; print "ok 6\n";

my @test_numbers = qw(001 002 003 004 005 006 007 008 009 010 011 012);
my @test_lengths = qw(01:36 10:19 04:29 02:22 04:58 11:29
                      04:03 09:20 03:07 09:21 05:28 08:42
                     );
my @test_offsets = qw(187 7367 53805 73975 84607 106992 158645 176862
                      218897 232882 274982 299580
                     );

if (@$track_numbers == @test_numbers) {
  print "ok 7\n";
  $i = 0; $result = 'ok';
  foreach my $number (@test_numbers) {
    $result = 'not ok' if ($number ne $track_numbers->[$i++]);
  }
  print "$result 8\n";
}
else {
  print "not ok 7\n";
  print "not ok 8\n";
}

if (@$track_lengths == @test_lengths) {
  print "ok 9\n";
  $i = 0; $result = 'ok';
  foreach my $length (@test_lengths) {
    $result = 'not ok' if ($length ne $track_lengths->[$i++]);
  }
  print "$result 10\n";
}
else {
  print "not ok 9\n";
  print "not ok 10\n";
}

if (@$track_offsets == @test_offsets) {
  print "ok 11\n";
  $i = 0; $result = 'ok';
  foreach my $offset (@test_offsets) {
    $result = 'not ok' if (&not_near($offset, $track_offsets->[$i++]));
  }
  print "$result 12\n";
}
else {
  print "not ok 11\n";
  print "not ok 12\n";
}

### test looking up discs (one match)

my @discs = $cddb->get_discs($id, $track_offsets, $total_seconds);

(@discs == 1) || print 'not '; print "ok 13\n";

my ($genre, $cddb_id, $title) = @{$discs[0]};
($genre   eq 'classical')                  || print 'not '; print "ok 14\n";
($cddb_id eq 'b811a20c')                   || print 'not '; print "ok 15\n";

( ($title =~ /Various/i) &&
  ($title =~ /Cartoon\s*Classics/i)
) || print 'not';
print "ok 16\n";

### test macro lookup

my @other_discs = $cddb->get_discs_by_toc(@toc);

(@other_discs == 1) || print 'not '; print "ok 17\n";
($other_discs[0]->[0] eq $discs[0]->[0]) || print 'not '; print "ok 18\n";
($other_discs[0]->[1] eq $discs[0]->[1]) || print 'not '; print "ok 19\n";
($other_discs[0]->[2] eq $discs[0]->[2]) || print 'not '; print "ok 20\n";


### test gathering disc details

my $disc_info = $cddb->get_disc_details($genre, $cddb_id);

# -><- uncomment if you'd like to see all the details
# foreach my $key (sort keys(%$disc_info)) {
#   my $val = $disc_info->{$key};
#   if (ref($val) eq 'ARRAY') {
#     print STDERR "\t$key: ", join('; ', @{$val}), "\n";
#   }
#   else {
#     print STDERR "\t$key: $val\n";
#   }
# }

($disc_info->{'disc length'} eq '4516 seconds') || print 'not ';
print "ok 21\n";

($disc_info->{'discid'} eq $cddb_id) || print 'not ';
print "ok 22\n";

($disc_info->{'dtitle'} eq $title) || print 'not ';
print "ok 23\n";

if (@{$disc_info->{'offsets'}} == @$track_offsets) {
  print "ok 24\n";
  $i = 0; $result = 'ok';
  foreach my $offset (@{$disc_info->{'offsets'}}) {
    $result = 'not ok' if &not_near($offset, $track_offsets->[$i++]);
  }
  print "$result 25\n";
}
else {
  print "not ok 24\n";
  print "not ok 25\n";
}

my @test_titles = ( "Comedian's Gallop / Kabalevsky",
                    "Dance of the Hours / Ponchielli",
                    "The Sleeping Beauty Waltz / Tchaikovsky",
                    "The Barber of Seville: Overture-Conclusion / Rossini",
                    "The Barber of Seville: Largo al Factotum / Rossini",
                    "The Sorcerer's Apprentice / Dukas",
                    "Tannhauser: Pilgrim's Chorus / Wagner",
                    "Toccata and Fugue in D Minor, BWV 565 / Bach",
                    "William Tell: Overture-Conclusion / Rossini",
                    "Morning, Noon and Night in Vienna: Overture / Suppe",
                    "Ride of the Valkyries / Wagner",
                    "Hungarian Rhapsody No. 2 / Liszt"
                  );

$i = 0; $result = 'ok';
foreach my $detail_title (@{$disc_info->{'ttitles'}}) {
  my ($detail_norm, $test_norm) = (lc($detail_title), lc($test_titles[$i++]));
                                        # quick normalization for approx match
  $detail_norm =~ tr[aeiouy][]d;
  $detail_norm =~ tr[a-z ][]cd;
  $detail_norm =~ s/\s+/ /g;
  $test_norm =~ tr[aeiouy][]d;
  $test_norm =~ tr[a-z ][]cd;
  $test_norm =~ s/\s+/ /g;

  my $mismatches = 0;
  foreach my $test_word (split ' ', $test_norm) {
    $mismatches++ unless ($detail_norm =~ $test_word);
  }

  if ($mismatches) {
    $result = 'not ok';
    last;
  }
}
print "$result 26\n";

### test fuzzy matches ("the freeside tests")

$id = 'a70cfb0c';
$total_seconds = 3323;
my @fuzzy_offsets = qw(0 20700 37275 57975 78825 102525 128700 148875 167100
                       184500 209250 229500
                      );

@discs = $cddb->get_discs($id, \@fuzzy_offsets, $total_seconds);
@discs || print 'not '; print "ok 27\n";

($genre, $cddb_id, $title) = @{$discs[0]};
($genre   eq 'rock')              || print 'not '; print "ok 28\n";
($cddb_id =~ /a..cfd0c/)          || print 'not '; print "ok 29\n";
($title   eq 'U2 / Achtung Baby') || print 'not '; print "ok 30\n";


$id = 'c509b810';
$total_seconds = 2488;
@fuzzy_offsets = qw(0 11250 19125 33075 47850 58950 69075 80175 91500 105975
                    120225 142425 152325 163200 167850 182775
                   );

@discs = $cddb->get_discs($id, \@fuzzy_offsets, $total_seconds);

if (@discs > 1) {
  print "ok 31\n";
}
else {
  print "not ok 31\n";
}

### test CDDB submission

if ($cddb->can_submit_disc()) {
  eval {
    $cddb->submit_disc
      ( 'Genre'       => 'classical',
        'Id'          => 'b811a20c',
        'Artist'      => 'Various',
        'DiscTitle'   => 'Cartoon Classics',
        'Offsets'     => $disc_info->{'offsets'},
        'TrackTitles' => $disc_info->{'ttitles'},
      );
    print "ok 32\n";
  };
                                        # skip if SMTPHOSTS and default are bad
  if ($@ ne '') {
    print "ok 32 # Skip - $@\n";
  }
}

# <bekj> dngor It's not Polite to have tests fail when things are OK,
# Makes CPAN choke :(

                                        # skip when needed modules are missing
else {
  print "ok 32 # Skip - Mail::Internet & Mail::Header needed to submit disc\n";
}

__END__ 

sub developing {
                                        # CD-ROM interface
  $cd = new CDROM($device) or die $!;
                                        # loads CD TOC
  @toc = $cd->toc();
                                        # returs an array like:


  $toc[0] = [ # track 999 is the lead-out information
              # track 1000 indicates an error
              $track_number,
              # next three fields are CD-i MSF information, broken apart
              $offset_minutes, $offset_seconds, $offset_frames,
            ];
                                        # rips a track to a file
  $cd->rip(track => 2, file => '/tmp/track-2', format => 'wav') or die $!;
  $cd->rip(start => '12:34/0', stop => '15:57/0', file => '/tmp/msfrange',
           format => 'wav'
          ) or die $!;

  # synchronous methods wait for finish
  $cd->play(track => 1, method => synchronous);

  # asynch methods return right away
  $cd->play(track => 2, method => asynchronous);

  # returns what's going on ('playing', 'ripping', etc.)
  # used to poll the device during asynchronous operations?
  $cd->status();

  # fill out the interface
  $cd->stop();
  $cd->pause();
  $cd->resume();

  # whimsy.  virtually useless stuff, but why not?
  $cd->seek(track => 1);
  $cd->seek(offset => '12:34/0');
  $cd->seek(offset => '-0:34/0');
  $cd->seek(offset => '+0:34/0');
}
