#!/usr/bin/perl -w
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
if (@ARGV != 2) { die "USAGE: gb2fasta.pl\n"; }
my $seqio = Bio::SeqIO->new('-format' => 'genbank', '-file' => "$ARGV[0]");
my $seqout = new Bio::SeqIO('-format' => 'fasta', '-file' => ">$ARGV[1]");
while (my $seq = $seqio->next_seq) { $seqout->write_seq($seq) }
