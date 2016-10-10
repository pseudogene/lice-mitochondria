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
if (@ARGV != 1) { die "USAGE: embl2ucsc.pl inputfile > outputfile\n"; }
my $seqio = Bio::SeqIO->new('-format' => 'embl', '-file' => "$ARGV[0]");
while (my $seq = $seqio->next_seq)
{
    for my $feat_object ($seq->get_SeqFeatures)
    {
        if ($feat_object->primary_tag eq 'CDS')
        {
            my $start  = $feat_object->location->start;
            my $end    = $feat_object->location->end;
            my $strand = ($feat_object->location->strand == 1 ? '+' : '-');
            my $name;
            for my $tag ($feat_object->get_all_tags)
            {
                if ($tag eq 'gene')
                {
                    for my $value ($feat_object->get_tag_values($tag))
                    {
                        $name = $value;
                    }
                }
            }
            print {*STDOUT}
              "$name\t$name\t1\t$strand\t$start\t$end\t$start\t$end\t1\t$start,\t$end,\n";
        }
        elsif (   $feat_object->primary_tag eq 'tRNA'
               || $feat_object->primary_tag eq 'rRNA')
        {
            my $start  = $feat_object->location->start;
            my $end    = $feat_object->location->end;
            my $strand = ($feat_object->location->strand == 1 ? '+' : '-');
            my $name;
            for my $tag ($feat_object->get_all_tags)
            {
                if ($tag eq 'product')
                {
                    for my $value ($feat_object->get_tag_values($tag))
                    {
                        $name = $value;
                    }
                }
            }
            print {*STDOUT}
              "$name\t$name\t1\t$strand\t$start\t$end\t\t\t1\t$start,\t$end,\n";
        }
    }
}
