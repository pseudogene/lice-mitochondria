# Copyright 2014-2017, Michaël Bekaert <michael.bekaert@stir.ac.uk>
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
.PHONY: base abi trimmomatic samtools bowtie clustalo gatk ratt anno

all: base abi trimmomatic samtools bowtie clustalo gatk ratt anno

base:
	@apt-get update
	@DEBIAN_FRONTEND=noninteractive apt-get install -y wget git ca-certificates unzip --no-install-recommends

abi:
	@wget https://sourceforge.net/projects/staden/files/io_lib/1.14.7/io_lib-1.14.7.tar.gz -O io_lib-1.14.7.tar.gz
	@tar xfz io_lib-1.14.7.tar.gz
	@cd io_lib-1.14.7; ./configure; make
	@make -C io_lib-1.14.7 -k install
	@rm -rf io_lib-1.14.7 io_lib-1.14.7.tar.gz
	@git clone https://github.com/bioperl/bioperl-ext.git
	#https://github.com/bioperl/bioperl-ext/archive/master.zip
	@cd bioperl-ext/Bio/SeqIO/staden; perl Makefile.PL; make; make install
	@rm -rf bioperl-ext

bowtie:
	@DEBIAN_FRONTEND=noninteractive apt-get install -y bowtie2

clustalo:
	@DEBIAN_FRONTEND=noninteractive apt-get install -y clustalo

samtools:
	@DEBIAN_FRONTEND=noninteractive apt-get install -y seqtk samtools bcftools --no-install-recommends

trimmomatic:
	@DEBIAN_FRONTEND=noninteractive apt-get install -y trimmomatic --no-install-recommends

gatk:
	@wget https://github.com/broadinstitute/picard/releases/download/2.2.4/picard-tools-2.2.4.zip -O picard-tools-2.2.4.zip
	@unzip picard-tools-2.2.4.zip
	@mv picard-tools-2.2.4/* /usr/local/bin
	@rm -rf picard-tools-2.2.4 picard-tools-2.2.4.zip
	-@tar xjf /root/GenomeAnalysisTK.tar.bz2
	-@mv *.jar /usr/local/bin
	-@rm -rf resources /root/GenomeAnalysisTK.tar.bz2

ratt:
	@DEBIAN_FRONTEND=noninteractive apt-get install -y mummer subversion --no-install-recommends
	@svn co "https://svn.code.sf.net/p/ratt/code/" ratt-code
	@rm -rf ratt-code/.svn
	@chmod 755 ratt-code/main.ratt.pl
	@sed -i -e 's,defined(@{$$ref_shift{$refName}}),exists $$ref_shift{$refName},g' ratt-code/main.ratt.pl
	@sed -i -e 's,$resultName ; ; ; ; ; $length BP,$resultName ; ; circular ; ; ; $length BP,g' ratt-code/main.ratt.pl
	@sed -i -e 's/translationTable=1/translationTable=5/g' ratt-code/main.ratt.pl
	@sed -i -e "s/'TGA' => 1,/ /g" ratt-code/ratt_correction.pm
	@sed -i -e "s#'ATG' => 1#'ATG' => 1, 'TTG' => 1, 'ATT' => 1, 'ATC' => 1, 'ATA' => 1, 'GTG' => 1#g" ratt-code/ratt_correction.pm
	@echo -e "#START\nTTG\nATT\nATC\nATA\nATG\nGTG\n#STOP\nTAA\nTAG\n#SPLICE\nXX..XX"> ratt-code/RATT.config
	@cp ratt-code/* /usr/local/bin/
	@rm -rf ratt-code

anno:
	@git clone https://github.com/pseudogene/anno.git
	@make -C anno
	@sed -i -e 's/AGA\tArg\tR\tArginine/AGA\tSer\tS\tSerine/g' anno/codon.txt
	@sed -i -e 's/AGG\tArg\tR\tArginine/AGG\tSer\tS\tSerine/g' anno/codon.txt
	@sed -i -e 's/ATA\tIle\tI\tIsoleucine/ATA\tMet\tM\tMethionine/g' anno/codon.txt
	@sed -i -e 's/TGA\tStp\tO\tStop/TGA\tTrp\tW\tTryptophan/g' anno/codon.txt
	@make -C anno -k install
	@rm -rf anno
