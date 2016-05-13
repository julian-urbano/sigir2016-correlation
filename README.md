This repository contains the data and source code for the following paper:

* J. Urbano and M. Marrero, "[Toward Estimating the Rank Correlation between the Test Collection Results and the True System Performance](http://julian-urbano.info/files/publications/066-toward-estimating-rank-correlation-test-collection-results-true-system-performance.pdf)", *International ACM SIGIR Conference on Research and Development in Information Retrieval*, 2016.

A [single ZIP file](https://github.com/julian-urbano/sigir2016-correlation/archive/master.zip) can be downloaded as well.


## Project Structure

* `bin/` Shell scripts to run the code in Linux.
* `config/` Machine-dependent configuration files.
* `data/` Input data files.
* `output/` Generated output files.
* `src/` Source code in R.
* `scratch/` Temporary files generated in the process.

## How to reproduce the results in the paper 

It takes several days to run all the code, so it is ready to use an SGE cluster, parallelizing across collections, correlation coefficients and estimators. You can still run everything on a single machine using just one core. **It is important that you always run from the base directory**.

1. Edit file `config/environment.sh`:
    * If you want to use a cluster, set variable `SGE=true`. Edit file `bin/qsub.sub` as well to change the notification e-mail and make sure that R is properly loaded in the SGE job.
    * If you don't want to use a cluster, set variable `SGE=false` and make the variable `RSCRIPT` point to the correct path in your machine.
2. Run script `bin/01-simulation.sh`. This simulates the new collections and stores them in `scratch/01-simulation/`.
3. Run script `bin/11-estimation.sh`. This computes all the correlation estimates and stores them in `scratch/11-estimation/`.
6. Run script `bin/12-compile.sh`. This compiles all estimates and stores the results in `output/estimates/`.
7. Run script `bin/99-paper.sh`. This generates all figures in the paper and stores them in `output/paper/`.

The code to simulate collections is in `src/simulation.R`, which adapts the [original code](https://raw.githubusercontent.com/julian-urbano/irj2015-reliability/9d33236efa413232d1999cf91553a51c7b741886/src/simulation.R) in another repository. For more information on how the simulation works, take a look at the [original repository](https://github.com/julian-urbano/irj2015-reliability).

## How to customize and extend the results in the paper

You can easily customize and extend the code to run with your own initial test collections or your own estimators. 

If you only want to use certain collections or estimators, edit file `config/params.sh` and follow the instructions. If you want to analyze different topic set sizes or use a different number of trials, edit file `config/params.R`.

Note that the script `src/99-paper.R` is only intended to generate the figures in the paper. If you customize something and want a similar analysis, you will need to extend this script yourself.

### Custom test collections

Simply add new CSV files with the topic-by-system effectiveness matrices in directory `data/` (no row names). Take a look for instance at the file from the [Ad hoc 2006 collection](/data/adhoc2006.csv). After adding your own files, run all the scripts again as detailed [above](#how-to-reproduce-the-results-in-the-paper).

### Custom estimators

You can add new estimators by creating a file `src/estimators/estimator.<name>.R` for each of them. This file must contain three functions:

* `precompute.<name>`, which receives the topic-by-system effectiveness matrix `X`. This function is used to precompute anything relevant, like the probabilities of discordance. The returned object contains this information, and is then passed on to the functions which actually compute the estimated correlations.
* `Etau.<name>` and `EtauAP.<name>`, which receive the same effectiveness matrix `X` and the object returned by the precomputation. They must return the estimated correlation coefficient.

Take a look for instance at estimators [`ML`](/src/estimators/estimator.ML.R) and [`SHw`](/src/estimators/estimator.SHw.R). These functions are called from `src/11-estimation.R` for each simulated collection. After adding your own files, run script `bin/11-estimation.sh` again to compute all estimates, and `bin/12-compile.sh` to aggregate results.

## License

* The TREC results in `data/` are anonymized and posted here with permission from the organizers.
* Databases and their contents are distributed under the terms of the [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
* Software is distributed under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0-standalone.html).

When using this archive, please [cite](CITE.bib) the above paper:

    @inproceedings{Urbano2016:correlation,
	  author = {Urbano, Juli\'{a}n and Marrero, M\'{o}nica},
      booktitle = {International ACM SIGIR Conference on Research and Development in Information Retrieval},
      title = {{Toward Estimating the Rank Correlation between the Test Collection Results and the True System Performance}},
      year = {2016}
    }
