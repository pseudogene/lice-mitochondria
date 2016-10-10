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
use Getopt::Long;
use Bio::SeqIO;
my ($verbose, $embl, $vcf, $groupfile) = (0);
my @filter;
GetOptions(
           'embl=s'     => \$embl,
           'vcf=s'      => \$vcf,
           'group=s'    => \$groupfile,
           'f|filter:s' => \@filter,
           'v|verbose!' => \$verbose
          );

if (   defined $embl
    && -r $embl
    && defined $vcf
    && -r $vcf
    && defined $groupfile
    && -r $groupfile)
{
    my %groups;
    if (open my $in, '<', $groupfile)
    {
        while (<$in>)
        {
            next if (m/^#/g);
            chomp;
            my @tmp = split m/\t/x;
            if (scalar @tmp == 2) { $groups{$tmp[0]} = $tmp[1]; }
        }
        close $in;
    }
    my %params = map { $_ => 1 } @filter;
    my $seqio = Bio::SeqIO->new('-format' => 'embl', '-file' => "$embl");
    my $seqout = new Bio::SeqIO('-format' => 'embl');
    my $seq = $seqio->next_seq;
    my %variations;
    my @header;
    if (open my $in, '<', $vcf)
    {

        while (<$in>)
        {
            next if (m/^##/g);
            chomp;
            my @tmp = split m/\t/x;
            if (scalar @tmp >= 9)
            {
                if (m/^#/g) { @header = @tmp; }
                elsif ($tmp[7] !~ m/;AF=1\.00;/g)
                {
                    @{$variations{$tmp[1]}} = @tmp;
                    my %allele;
                    foreach my $j (9 .. (scalar @tmp - 1))
                    {
                        if (length($tmp[$j]) > 4 && $tmp[$j] =~ m/^(\d+):/g)
                        {
                            if (   exists $header[$j]
                                && exists $groups{$header[$j]})
                            {
                                push @{$allele{$1}}, $groups{$header[$j]};
                            }
                            else {
                                print {*STDERR} "$j missing\n"
                                  if ($verbose);
                            }
                        }
                    }
                    if (scalar keys %allele > 1)
                    {
                        my ($skip, $llast);
                        foreach my $j (keys %allele)
                        {
                            my $last;
                            foreach my $i (@{$allele{$j}})
                            {
                                if (!defined $last) { $last = $i; }
                                else { $skip = 1 if ($last ne $i); }
                                $skip = 1
                                  if (defined $llast && $llast eq $last);
                            }
                            $llast = $last;
                        }
                        if (!defined $skip)
                        {
                            my ($anno, $annofull) = ('', '');
                            if ($tmp[7] =~ m/ANNO=(.*?);/g) { $anno = $1; }
                            if ($tmp[7] =~ m/ANNOFULL=(.*);?/) {
                                $annofull = $1;
                            }
                            if (scalar @filter == 0 || ($anno =~ m/^([^:]+):?/ && !exists($params{$1})))
                            {
                                print {*STDERR} "YES\t$_\n" if ($verbose);
                                my $feat =
                                  new Bio::SeqFeature::Generic(
                                    -start => (
                                               length($tmp[3]) > length($tmp[4])
                                               ? $tmp[1] + 1
                                               : $tmp[1]
                                              ),
                                    -end => (
                                             length($tmp[3]) == length($tmp[4])
                                             ? $tmp[1] + length($tmp[4]) - 1
                                             : ($tmp[1] + length($tmp[3]) - 1)
                                            ),
                                    -strand      => 1,
                                    -primary_tag => 'Variation',
                                    -tag         => {
                                        product     => "$anno",
                                        description => "$annofull",
                                        replace     => (
                                               length($tmp[3]) > length($tmp[4])
                                               ? substr $tmp[4],
                                               1
                                               : $tmp[4]
                                        ),
                                        note => (
                                            length($tmp[3]) < length($tmp[4])
                                            ? 'insertion'
                                            : (
                                               length($tmp[3]) > length($tmp[4])
                                               ? 'deletion'
                                               : 'polymorphism')
                                        )
                                    }
                                  );
                                $seq->add_SeqFeature($feat);
                            }
                            else { print {*STDERR} "NO\t$_\n" if ($verbose); }
                        }
                        else { print {*STDERR} "SKIP\t$_\n" if ($verbose); }
                    }
                    else { print {*STDERR} "IGNORE\t$_\n" if ($verbose); }
                
                }
            }
        }
        close $in;
    }
    $seqout->write_seq($seq);
}
else
{
    print
      "Usage $0  --embl=<embl annotation> --vcf=<anno annotation> --group=<group tab file> [--filter=]\n\nPossible filters:\n    Intergenic\n    Deletion\n    Downstream\n    Nonsynonymous\n    Synonymous\n    Upstream\n    Exon\n\neg: $0 --embl reference.embl  --vcf output --group groups.list --filter Synonymous --filter Upstream --filter Intergenic --filter Downstream > mito.embl\n\n";
}
