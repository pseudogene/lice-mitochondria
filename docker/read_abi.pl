#!/usr/bin/perl
#
# Copyright 2014-2016, Michaël Bekaert <michael.bekaert@stir.ac.uk>
#
# This file is part of lice-mitochondria.
#
# lice-mitochondria is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# lice-mitochondria is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License v3
# along with lice-mitochondria. If not, see <http://www.gnu.org/licenses/>.
#
use strict;
use Bio::SeqIO;
use File::Temp qw/ tempfile /;
my $input_file = shift;
my $start      = shift;
my $end        = shift;
my $seq_in     = Bio::SeqIO->new(-format => 'abi', -file => $input_file);

# loads the whole file into memory - be careful
# if this is a big file, then this script will
# use a lot of memory
if (my $inseq = $seq_in->next_seq)
{
    if (
        (
           !defined $inseq->display_id
         || length($inseq->display_id) < 1
         || $inseq->display_id eq '(null)'
        )
        && $inseq->desc =~ m/NAME=(.*)\n/g
       )
    {
        $inseq->display_id($1);
    }
    my (undef, $filename) = tempfile(OPEN => 0, UNLINK => 1);
    my $seq_out = Bio::SeqIO->new(
                                  -format  => 'fastq',
                                  -variant => 'illumina',
                                  -file    => '>' . $filename,
                                 );
    $seq_out->write_fastq($inseq);
    $seq_out->close();
    $start = 1 if (!defined $start);
    $end = length($inseq->length()) if (!defined $end);
    system(  'seqtk trimfq -b '
           . $start . ' -e '
           . ($inseq->length() - $end) . q{ }
           . $filename . ' >'
           . $inseq->display_id
           . '.fastq');
}
