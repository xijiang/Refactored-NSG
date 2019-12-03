# There might be some ID whose genotypes are just weird
# Here, I test the ID genotyped with 17k chips one-by-one.
# I mask their every fourth locus, and then impute them back.
# In four round, every locus was masked and imputed back once.
# I then calculate the genotype imputation errors
# and then rank all the ID according to these errors
# Currently I run this for physical map version 3
# But This will be a general test procedure, and should work smoothly on version 4.

prepare-data-8k() {
    if [ ! -d $g8k ]; then
	source $base/fnc/merge-8k-gt.sh
	merge-8k-genotypes
    fi
    if [ -d $qcd ]; then rm -rf $qcd; fi
    mkdir -p $qcd/rst
    cd $g8k
    if [ ! -f ref.vcf.gz ]; then
	java -jar $bin/beagle.jar \
	     nthreads=4 \
	     gt=ori.vcf.gz \
	     ne=$ne \
	     out=ref
    fi
}

quality-control-8k(){
    qcd=$g8k/qcd

    prepare-data-8k
    cd $qcd
    general-statisitcs
    cd $qcd
    stride-on-snp $grpsz8k
    cd $qcd
    qc-summarize
}