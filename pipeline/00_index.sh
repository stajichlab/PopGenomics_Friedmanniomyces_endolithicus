#!/usr/bin/bash
module load samtools/1.12
module load bwa/0.7.17
if [ -f config.txt ]; then
	source config.txt
fi
FASTAFILE=Friedmanniomyces_endolithicus_CCFEE_5311.dna.fasta
GFFILE=$(basename $FASTAFILE .dna.fasta).gff3
mkdir -p $GENOMEFOLDER
pushd $GENOMEFOLDER
# THIS IS EXAMPLE CODE FOR HOW TO DOWNLOAD DIRECT FROM FUNGIDB
curl -o $GFFILE.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/005/059/855/GCA_005059855.1_ASM505985v1/GCA_005059855.1_ASM505985v1_genomic.gff.gz
curl -o $FASTAFILE.gz https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/005/059/855/GCA_005059855.1_ASM505985v1/GCA_005059855.1_ASM505985v1_genomic.fna.gz
pigz -d $FASTAFILE.gz $GFFILE.gz

if [[ ! -f $FASTAFILE.fai || $FASTAFILE -nt $FASTAFILE.fai ]]; then
	samtools faidx $FASTAFILE
fi
if [[ ! -f $FASTAFILE.bwt || $FASTAFILE -nt $FASTAFILE.bwt ]]; then
	bwa index $FASTAFILE
fi

DICT=$(basename $FASTAFILE .fasta)".dict"

if [[ ! -f $DICT || $FASTAFILE -nt $DICT ]]; then
	rm -f $DICT
	samtools dict $FASTAFILE > $DICT
	ln -s $DICT $FASTAFILE.dict 
fi

popd
