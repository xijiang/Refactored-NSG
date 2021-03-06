[toc]

* by Xijiang Yu
* Started: November, 2019.
* Latest update: December, 2019.
* Ås

# Prerequisites
1. `pigz`, `sudo dnf install pigz -y`. Note dnf is for Fedora, CentOS 8. On CentOS 7, use `yum`. On Debian and Ubuntu, use `apt-get`.
2. `g++`, the version should support standard 17
3. `plink`, in `~/.local/bin`, and in `$PATH`.
4. `julia`, version > 1.0, with package `Plots`, `Statistics`
5. `pandoc`, to convert md to manual
6. `most`, for colored manual

# Update
## 2020-07-06
- Added codes to `merge`, `QC` and `filter` 17k$\gamma$ data.
- Reuse of previous imputation results.

# Set up a working evironment

## Obtain the codes
To run my codes, you have to find a working directory on you own (Linux) desktop/server. For example, if this working directory is `~/GS`, then run the commands below:

```bash
mkdir ~/GS  # if this working directory not exists.
cd ~/GS
git clone https://github.com/xijiang/Refactored-NSG nsg
```

All of my codes will be downloaded local. And you are using the quality control release of my codes.

Also, it is important to note that I call this directory `base`.

## Data preparation
Since the data set is large. Also, more importantely, the data set should not be public, it is better to put its repo on a private server, e.g., a NSG server, or just local on the working machine.

If the data is stored on a server, say, LCserv:data/nsg-data, then
```bash
cd ~/GS
git clone user@LCserv:data/nsg-data
cd nsg
ln -s ../nsg-data data
```
Before this, I can help to setup such a local data repo.

This repo can also be on a local machine, e.g., `path-to-repo/nsg-data`. Then,
```bash
cd ~/GS
git clone path-to-repo/nsg-data
cd nsg
ln -s ../nsg-data data
```

I will skip `~/GS` below. If declared otherwise, the default directory is `~/GS/nsg`. This can be, of course, defined otherwise.

# Running pipelines
## General options
### Show version information
```bash
./run-pipeline.sh ver
```

### Upgrade to the latest version
```bash
./run-pipeline.sh update
```
This pipeline will pull the latest version of my codes. It also remove, if exists, binaries. The the binaries are re-compiled.

The latest Beagle will be downloaed to `bin` also, and (soft) linked to beagle.jar.

This procedure also check if beagle2vcf.jar is available or not. If not, it will downloaded also.

Beagle is updated once every one or two months. It is good idea to update it locally, perhaps every month. Above is also required before the first run.

* Beagle 2019-NOV corrected a `stream closed` bug.
* Another update on 25 Nov., 2019 seemed to have solved the problems. 

## Dealing with genotypes
There are currently 3 groups of genotypes, namely, 8k, 17k and 606k. I describe the procedure on 17k data in details. Managements of 8k and 606k are similar.

### Merge data from 17k chips
```bash
./run-pipeline.sh m17
```

A few minutes later, directory `work/17k-alpha` created in the current directory. 

In this folder, there is a file `ori.vcf.gz` and a folder `pre`. Folder `pre` just stores some middle results.  It can be ignored. File `ori.vcf.gz` stores the raw data and is to be analysed in the pipelines below.

### Quality control of 17k data

```bash
./run-pipeline.sh q17
```

This pipeline usually takes a night to finish. So it is better to run this pipeline before you leave for home on a work day.

#### A general statistics

Number of genotype missing statistic results are stored in `onid.missing` and `onsnp.missing`.

#### Hardy Weinberg equillibrium test
And other quality control measures, .e.g, plink.
*To be added*, and maybe some other QC measures.

#### Grid test of ID and SNP
This test strategy is:
- Random divide available ID into a number of groups
- For each of the sub-group, mask $i$th locus of every $n$ loci, where $i=$ group number mod 10 (by default). Using genotypes of the rest ID as reference.
- Impute the masked loci back and compare with true genotypes.
- Above can be finished in several repeats, and in the same number of threads simultaneously.

##### Configurations
The configurations for this funciton can be done in file `fnc/parameters.sh`. Below is an example:
```bash
QCD=$a17k/qcd           # QCD: quality control directory
qcblksize=10            # this usually doesn't need change
grpsize=44              # as 44x109 == 4796, the current n-ID
```

The error rates are reported in `ID.qc`, and `SNP.qc`. Each error rate wac calculated as: $\frac{\mathrm{errors}}{\textrm{number of (ID, SNP) pair estimated}}$.

One can examine the results and then put the ID and SNP you want to exclude in `exclude.snp` and `exclude.id`.

Put these two files in `$a17k/flt`. Refer `fnc/parameters.sh` to see where `$a17k` is.

### Remove problematic ID and SNP

You can refer the following information to decide which ID and/or SNP to remove:
- `work/chip/qcd/on{id,snp}.missing`. For example run `sort -nk2 onid.missing | less` to see which ID has the most missing loci at the bottom.
- `work/chip/qcd/rst/{ID,SNP}.qc`. These 2 files contains quality info about an ID or a SNP who were masked and imputed back.

The ID and SNP to be removed should be specified manually. In directory `work/17k-alpha/flt`, put the ID names to be excluded in file `exclude.id`. In the same directory, put the SNP to be excluded in `exclude.snp`. 

Then in the `base` directory, run

```bash
./run-pipeline.sh f17`
```

The results are stored in `work/17k-alpha/flt`. File `flt.vcf.gz` has the unphased genotypes. File `ref.vcf.gz` is a phased version.

### Test imputatin from 8k to 17k

This is to compare imputation error rates between before and after my QC. It also reports quality of individual ID and SNP results, beside a gereral report. Before, the imputation error rates were about 4%.

```bash
run-pipeline.sh tlm
```

### Prepare 17k$\beta$ genotypes

There is only one file of this type.  Run:
```
./run-pipelin.sh b17
```
To prepare a VCF file. No quality control was planned on these ~200ID

### Quality control of 8k genotypes

Quality control of the 8k data follows the same file structure as 17k, except the files are now in directory `8k`. Typically in `base`, you run:

```bash
./run-pipeline.sh m8k`
./run-pipeline.sh q8k`
# then specify some loci and ID to be excluded in work/8k/flt
./run-pipeline.sh f8k`
```

### QC of 606k genotypes

```bash
./run-pipeline.sh m6d`
./run-pipeline.sh q6d`
# then specify some loci and ID to be excluded in work/606k/flt
./run-pipeline.sh f6d`
```

### Backup QC history

```bash
./run-pipeline.sh qch`
```

This pipeline will search `ID.qc` and `SNP.qc` in directory `17k-alpha`, `8k`, `606k`. If they exist, the pipeline will copy them to `log`. The birth seconds of the files since epoch are written into the file names. For example: `8k.1576685419.SNP`. One can use command:

```bash
date -d @1576674675 +%Y-%m-%d\ %H:%M
# 2019-12-18 14:11
```

to see the date that the file was created.

## Imputation and **G** calculation

You have to finish quality control and filtering procedures/pipelines on related genotype data before running this pipeline.

[*Note: major revision 2019-12-18*]

```bash
./run-pipeline.sh i+g
```

### Reference, or the left most file
It is decided to use 17k-$\alpha$ genotype only as reference currently. This can be modified in `parameters.sh`.

All results, including intermediate ones, will be written in `i+g`. 

By default:
- `list.id` stores the ID list
- `G.mat` is $\mathbf{G}$ of binary storage
- `gmat.3c` is $\mathbf{G}$ of plain text format.

The 3 columns of $\mathbf{G}$ specifies the lower triangular elements of $\mathbf{G}$, i.e.:
`id-1 id-2 element-value`
and so on.

The current parameters for this pipeline is as below:
```bash
## Imputation and G calculation
wig=$work/i+g                   # work directory for imputaion and G calculation

## We have 4 classes of genotypes to date: 8k, 17k-alpha, 17k-beta, and 606k
## Genotype files to be imputed
i8k=$g8k/ori.vcf.gz             # QC is removing too many ID and SNP
i17b=$b17k/ori.vcf.gz           # not filtered
i6dk=$g6dk/ori.vcf.gz           # can modify this to a filtered one

## Reference files
r17k=$a17k/flt/ref.vcf.gz

##------------------------------------------------------------------------------
## Specify files to be used for a big G matrix
lref=$r17k                      # the left most reference file
rinc="$i17b $i6dk $i8k"         # these will be left joined to above

gmat="bigg.3c"
```

The two parts of above specifications states the files that will be used for $\mathbf{G}$ calculation. The pipeline will first determine if the file exists. It then left join the reference file and files to be imputed one by one. After imputation, it will calculate `G.mat` and `bigg.3c`. You can name the later otherwise.

---

# Data and program management

## Data
Data are managed with git also. I can gave you an initial root copy of these data. These can be put either in a separate directory on local machine. Or, it can be on a remote machine. I call this a `repo`. You can have several `repo` and have them synchonized regularily.

### Obtain data

```bash
# In your working directory
git clone path-to-nsg-data  # if the data are on local machine
git clone user@remote:path-to-nsg-data # if on remote
cd base  # remember base I defined in the beginning of this documentation.
ln -s path-to-cloned-nsg-data data # and must with this name
```

### Update data general
There are 4 directories in `data`, namely, `genotypes`, `ids`, `maps`, and `phenotypes`.

New data will come regularily later. After each update, it is a good habbit to update the its repo.

```bash
git add files # you just added or modified
git commit -am message # message can be '17k data 2019-12'
git push origin master
```

After above the `repo` will be updated. It also keeps a history of what you have done to it.

#### Update genotypes
Currently there are 4 sub-directories in `data/genotypes`. They are
- 600k
- 7327
- a17k
- b17k

When new genotypes arrives, you just copy the `FinalReportMatrix_Design.txt` file in the relavent directory. For example:

```bash
cd data/genotypes/a17k  # new 17k genotypes arrived
cp path-to-from/JCM3786_FinalReportMatrix_Design.txt . # the file named JCM3786_FinalReportMatrix_Design.txt
git add JCM3786_FinalReportMatrix_Design.txt
git commit -am '17k genotype JCM3786'
git push orgin master
```

You can add 25k directory and genotypes later in this way.

#### Update ID info
The current ID specification format was decide by Jette. It includes a header. The columns are as below:

| Column | Item |
| --: | -- |
|  1 | Herdbook_number   |
|  2 | AnimalID	         |
|  3 | SampleID_LD       |
|  4 | SampleID_HD       |
|  5 | SampleID_17Kbeta  |
|  6 | SampleID_17K      |
|  7 | BirthYear         |
|  8 | BreedGroup        |
|  9 | Breed	         |
| 10 | Gender            |
| 11 | SampleID_17Kgamma |

The current file is `genomiclink.txt`. A soft link `id.lst` is pointing to this file.

Later when genotypes with new chips, e.g., 25k chip, comes. The program need some modifification for new format of `id.lst`. Also `id.lst` should always point to the news version of ID info file.

#### Update maps

I have proved that physical map version 4 is superior than version 3. Hence currently version 4 is being used. In the `data/maps` directory, `8k.map`, `17k.map`, and `606k.map` point to their version-4 physical-files, respectively. In the future, if new map version is available, say 7327.v-7.map, do below:

```bash
rm 8k.map
ln -s 7327.v-7.map 8k.map
git commit -am 'ver7 map of 8k'
git push origin master
```
#### Update phenotypes

Management is similar to above.

## Codes

All my relevant codes has a repo on https://github.com/xijiang/Refactered-NSG. Later, I will release my codes in format `v1.0`, `v2.2`, etc. You can later run below in `base`:

```bash
./run-pipeline.sh update
```
