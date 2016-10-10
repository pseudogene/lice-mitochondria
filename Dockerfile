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
FROM ubuntu:16.04
MAINTAINER Michael Bekaert <michael.bekaert@stir.ac.uk>
LABEL description="lice-mitochondria Docker" version="1.1" Vendor="Institute of Aquaculture, University of Stirling"

ENV RATT_HOME /usr/local/bin
USER root

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make g++ software-properties-common libtool automake autoconf pkg-config zlib1g-dev libncurses5-dev libncursesw5-dev libbz2-dev libssl-dev --no-install-recommends
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y bioperl --no-install-recommends

COPY docker/Makefile /root/Makefile
COPY docker/GenomeAnalysisTK.tar.bz2 /root/GenomeAnalysisTK.tar.bz2
COPY docker/read_abi.pl /usr/local/bin/read_abi.pl
COPY docker/gb2fasta.pl /usr/local/bin/gb2fasta.pl
COPY docker/gb2embl.pl /usr/local/bin/gb2embl.pl
COPY docker/embl2ucsc.pl /usr/local/bin/embl2ucsc.pl
COPY docker/update_embl.pl /usr/local/bin/update_embl.pl
RUN chmod 755 /usr/local/bin/*.pl
RUN make -C /root
RUN rm -f /root/Makefile

RUN mkdir /sequences

RUN mkdir /mitochondria
WORKDIR /mitochondria
