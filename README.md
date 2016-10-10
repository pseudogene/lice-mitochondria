# lice-mitochondria

We foster the openness, integrity, and reproducibility of scientific research.

Scripts and tools used to analyse mitochondrial sequence variations between to strain of sea-lice (_Lepeophtheirus salmonis_).


## Associated publication

>**Maternal inheritance of pyrethroid resistance in the salmon louse _Lepeophtheirus salmonis_ (Krøyer) is mediated by mitochondrial DNA**.
>
>Carmona-Antoñanzas G, Bekaert M, Humble JL, Boyd S, Roy W, Houston RD, Gharbi K, Bron JE, Sturm A
>
>_submitted_


## Associated dataset

The Sanger DNA sequencing trace files (ABI/AB1) generated for this study are provided as the compacted archive `abi.01.tar.bz2` and `abi.02.tar.bz2`. To unpack it use `tar`

```
tar xfj abi.01.tar.bz2
tar xfj abi.02.tar.bz2
```


## How to use this repository?

This repository hosts both the scripts and tools used by this study and the raw results generated at the time. Feel free to adapt the scripts and tools, but remember to cite their authors!

To look at our scripts and raw results, **browse** through this repository. If you want to reproduce our results, you will need to **clone** this repository, build the docker, and the run all the scripts. If you want to use our data for our own research, **fork** this repository and **cite** the authors.


## Prepare a docker

All required files and tools run in a self-contained [docker](https://www.docker.com/) image.

#### Clone the repository

```
git clone https://github.com/pseudogene/lice-mitochondria.git
cd lice-mitochondria
```

#### Download GATK tools

After cloning this repository, you need to manually download the last version of the [GATK tools](https://www.broadinstitute.org/gatk/download/). You will need to agree to the Licensing. Once you have the `GenomeAnalysisTK-x.x.tar.bz2` file, copy it into the `docker` folder, under `GenomeAnalysisTK.tar.bz2` (no version number).

```
mv GenomeAnalysisTK-x.x.tar.bz2 docker/GenomeAnalysisTK.tar.bz2
```

#### Create a docker

```
docker build --rm=true --file=Dockerfile -t lice-mitochondria .
```

#### Start the docker

To import and export the results of your analyse you need to link a folder to the docker. It this example your data will be store in `mitochondria` (current filesystem) which will be seem as been `/mitochondria` from within the docker by using `-v <USERFOLDER>:/mitochondria`. Similarly the raw electrophoregrams will be store in `abi` (current filesystem) which will be seem as been `/sequences` from within the docker.

```
docker run -i -t --rm -v $(pwd)/abi:/sequences \
  -v $(pwd)/mitochondria:/mitochondria \
  lice-mitochondria /bin/bash
```

#### Re-run the analysis of the associted study

Make sure your ABI/AB1 files are in `abi`, while the `mitochondria` must have the `sequences.tsv` and `groups.list` files.  `sequences.tsv` has the trimming coordinates for all ABI/AB1 file you want to use. Each line need the file prefix (filename without the `ab1` extension), the start and stop of the relevant sequence and the sample name, separated by tabulations:

```
18CFPAB004_F7	41	814	Fam6.3_F2_M662
18CFPAB004_F8	36	925	Fam6.3_F2_M663
18CFPAB004_F9	34	782	Fam6.3_F2_M664
18CFPAB004_F10	27	775	Fam6.3_F2_F688
18CFPAB004_F11	38	871	Fam6.3_F2_F689
...
```

The `groups.list` only provide the list samples and the associated groupIDs separated by a tabulation:

```
Fam6.3_F2_M662	1
Fam6.3_F2_F688	0
```

To run the full pipeline:

```
tar xfj abi.01.tar.bz2
tar xfj abi.02.tar.bz2
docker run -i -t --rm -v $(pwd)/abi:/sequences -v $(pwd)/mitochondria:/mitochondria lice-mitochondria /mitochondria/make_mito.sh
```


## For impatient

```
git clone https://github.com/pseudogene/lice-mitochondria.git
cd lice-mitochondria
#Add GenomeAnalysisTK.tar.bz2 to docker
docker build --rm=true --file=Dockerfile -t lice-mitochondria .
#Add sequences.tsv and groups.list to mitochondria
#Add an abi folder with the ABI/AB1 files used in sequences.tsv
tar xfj abi.01.tar.bz2
tar xfj abi.02.tar.bz2
docker run -i -t --rm -v $(pwd)/abi:/sequences -v $(pwd)/mitochondria:/mitochondria lice-mitochondria /mitochondria/make_mito.sh
```


## Issues

If you have any problems with or questions about the scripts, please contact us through a [GitHub issue](https://github.com/pseudogene/lice-mitochondria/issues).
Any issue related to the scientific results themselves must be done directly with the authors.


## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.


## License and distribution

The content of this project itself including the raw data and work are licensed under the [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/), and the source code presented is licensed under the [GPLv3 license](http://www.gnu.org/licenses/gpl-3.0.html).
