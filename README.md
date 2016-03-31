This repository contains the data and source code for the following paper:

* J. Urbano and M. Marrero, "[Estimating the Rank Correlation between the Test Collection Results and the True System Performance](http://julian-urbano.info/files/publications/066-estimating-rank-correlation-test-collection-results-true-system-performance.pdf)", *International ACM SIGIR Conference on Research and Development in Information Retrieval*, 2016.

A [single ZIP file](https://github.com/julian-urbano/sigir2016-correlation/archive/master.zip) can be downloaded as well.


## Project Structure

* `bin/` Shell scripts to run the code in Linux.
* `config/` Machine-dependent configuration files.
* `data/` Input data files.
* `output/` Generated output files.
* `src/` Source code in R.
* `scratch/` Temporary files generated in the process.

## License

* The TREC results in `data/` are anonymized and posted here with permission from the organizers.
* Databases and their contents are distributed under the terms of the [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
* Software is distributed under the terms of the [GNU General Public License v3](http://www.gnu.org/licenses/gpl-3.0-standalone.html).

When using this archive, please [cite](CITE.bib) the above paper:

    @inproceedings{Urbano2016:correlation,
	  author = {Urbano, Juli\'{a}n and Marrero, M\'{o}nica},
      booktitle = {International ACM SIGIR Conference on Research and Development in Information Retrieval},
      title = {{Estimating the Rank Correlation between the Test Collection Results and the True System Performance}},
      year = {2016}
    }
