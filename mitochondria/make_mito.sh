#!/bin/bash
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
CPU=15
REF=NC_007215.B
NEWREF=reference

mkdir fastq
mkdir samples

mkdir databases
mkdir embl

gb2fasta.pl "${REF}.gb" "databases/${REF}.fa"
gb2embl.pl "${REF}.gb" "embl/${REF}.embl"
java -jar /usr/local/bin/picard.jar CreateSequenceDictionary R="databases/${REF}.fa" O="databases/${REF}.dict"
samtools faidx "databases/${REF}.fa"
bowtie2-build -q -f "databases/${REF}.fa" "databases/${REF}"

IFS=$'\t'
while read -r A B C D;
do
    echo "${A} (${D}) ${B} - ${C}"
    read_abi.pl "/sequences/${A}.ab1" "${B}" "${C}"
    TrimmomaticSE -threads "${CPU}" "${A}.fastq" "fastq/${A}.fastq" LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    rm -f "${A}.fastq"
    cat "fastq/${A}.fastq" >> "samples/${D}.fastq"
done < sequences.tsv

mkdir map
COUNTER=1
for A in samples/*.fastq;
do
    B=$(echo "$A" | cut -f1 -d'.' | cut -f2 -d'/')

    bowtie2 -p "${CPU}" --very-sensitive-local -x "databases/${REF}" -U "${A}" -S "${B}_scaffolds.sam"
    samtools view -b -S -F 4 -T "databases/${REF}.fa" -o "${B}_scaffolds.bam" "${B}_scaffolds.sam"
    samtools sort "${B}_scaffolds.bam" -o "${B}.bam"
    java -jar /usr/local/bin/picard.jar AddOrReplaceReadGroups I="${B}.bam" O="map/${B}.bam" RGID="${COUNTER}" RGLB="lice" RGPL=PACBIO RGPU="lice" RGSM="${B}"
    rm -f "${B}_scaffolds.bam" "${B}_scaffolds.sam" "${B}.bam"
    echo "map/${B}.bam" >> merge.list
    let COUNTER=COUNTER+1
done

##
#IoA-00 susceptible
echo -e "map/Fam1.1_F2_F582.bam\nmap/Fam1.1_F2_F583.bam\nmap/Fam1.1_F2_F585.bam\nmap/Fam1.1_F2_M576.bam\nmap/Fam1.1_F2_M578.bam\nmap/Fam1.1_F2_M580.bam\nmap/Fam1_P0_Female.bam\nmap/Fam6_P0_Male.bam" > merge.list
##

samtools merge --threads "${CPU}" --reference "databases/${REF}.fa" -b merge.list "map/${REF}_merged.bam"
samtools index "map/${REF}_merged.bam"
rm merge.list

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T HaplotypeCaller -R "databases/${REF}.fa" -I "map/${REF}_merged.bam" --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -ploidy 1 -o raw_variants.vcf
java -jar /usr/local/bin/GenomeAnalysisTK.jar -T FastaAlternateReferenceMaker -R "databases/${REF}.fa" -o "databases/${NEWREF}.fa" -V raw_variants.vcf --lineWidth 70

mkdir results
mkdir ratt
cd ratt
start.ratt.sh ../embl "../databases/${NEWREF}.fa" ref_genome Strain
cd ..
cp ratt/ref_genome.1.final.embl "results/${NEWREF}.embl"
rm -rf ratt

java -jar /usr/local/bin/picard.jar CreateSequenceDictionary R="databases/${NEWREF}.fa" O="databases/${NEWREF}.dict"
samtools faidx "databases/${NEWREF}.fa"
bowtie2-build -q -f "databases/${NEWREF}.fa" "databases/${NEWREF}"

COUNTER=1
for A in samples/*.fastq;
do
    B=$(echo "$A" | cut -f1 -d'.' | cut -f2 -d'/')

    bowtie2 -p "${CPU}" --very-sensitive-local -x "databases/${NEWREF}" -U "${A}" -S "${B}_scaffolds.sam"
    samtools view -b -S -F 4 -T "databases/${NEWREF}.fa" -o "${B}_scaffolds.bam" "${B}_scaffolds.sam"
    samtools sort "${B}_scaffolds.bam" -o "${B}.bam"
    java -jar /usr/local/bin/picard.jar AddOrReplaceReadGroups I="${B}.bam" O="map/${B}.ref.bam" RGID="${COUNTER}" RGLB="lice" RGPL=PACBIO RGPU="lice" RGSM="${B}"
    rm -f "${B}_scaffolds.bam" "${B}_scaffolds.sam" "${B}.bam"
    echo "map/${B}.ref.bam" >> merge.list
    let COUNTER=COUNTER+1
done

samtools merge --threads "${CPU}" --reference "databases/${NEWREF}.fa" -b merge.list map/merged.bam
samtools index map/merged.bam
rm merge.list

java -jar /usr/local/bin/GenomeAnalysisTK.jar -T HaplotypeCaller -R "databases/${NEWREF}.fa" -I map/merged.bam --fix_misencoded_quality_scores -fixMisencodedQuals --genotyping_mode DISCOVERY -stand_emit_conf 10 -stand_call_conf 30 -ploidy 1 -o variants.vcf 

embl2ucsc.pl "results/${NEWREF}.embl" >reference_genes.txt
anno -i variants.vcf -o "results/output" -r "databases/${NEWREF}.fa" -g reference_genes.txt
rm -f reference_genes.txt

mv results/output results/output.vcf
update_embl.pl --embl "results/${NEWREF}.embl" --vcf results/output.vcf --group groups.list >results/mito.allvar.embl
update_embl.pl --embl "results/${NEWREF}.embl" --vcf results/output.vcf --group groups.list --filter Synonymous --filter Upstream --filter Intergenic --filter Downstream >results/mito.sigvar.embl

