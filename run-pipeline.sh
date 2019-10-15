#!/usr/bin/env bash
if [ $# != 1 ]; then
    cat fnc/opts.txt
else
    echo preparing functions
    . fnc/parameters.sh
    . fnc/functions.sh

    if [ ! -f $bin/ivcf-cmp ]; then
        cd $src
        make
        make mv
    fi
    cd $base

    case "$1" in
    17k | 17K)
        source fnc/17k-alpha.sh
        calc-ga17k # with genotype 17k alpha
        ;;
    lmr | LMR | Lmr)
        source fnc/l2m-imputation.sh
        lmr
        ;;
    6dk)
        source fnc/606k.sh
        e17k
        ;;
    v34)
        source fnc/v3-vs-v4.sh
        new-lmr
        ;;
    8vr)
        source fnc/8d-vs-random.sh
        8d-v-ran-lmr
        ;;
    6vr)
        source fnc/nws-hd.sh
        6d-v-ran-lmr
        ;;
    qcd)
        source fnc/qc-17k-id.sh
        quanlity-control
        ;;
    *)
        cat fnc/opts.txt
        ;;
    esac
fi
