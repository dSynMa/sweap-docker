CAV 2026 Artifact
=======================================
Paper title: "Sweap: Reactive Synthesis for Infinite-State Integer Problems"

Claimed badges: Available + Functional + Reusable

Justification for the badges:

  * Functional: The artifact allows to replicate the results shown in the
    paper (see below), and includes the source code for the tool.

    - replicated:
       * Table 1 (overall results),  
       * Figures 3a-d,
       * Tables 2-4 (in Appendix).

    - not-replicated: N/A. We do not separate results between
      realisable/unrealisable instances as Table 1 does, but the data is
      directly derived from Tables 2-4.

  * Reusable: The tool `sweap` is licensed under GNU GPLv3. The artifact
    allows to execute the tool on arbitrary problems besides the benchmarks;
    we provide documentation for the tool's input format (see below).
    
Requirements:

  * RAM: 48 GB or more recommended. The paper used a 32 GB limit for all
    experiments, and extra memory would be needed for the rest of the OS.
    Users with less memory may reduce the value of the `--memory` option
    in the commands below, but they will observe a higher incidence of
    out-of-memory experiments.
  * CPU cores: 4 or more (8 or more recommended).
  * Time (smoke test): 10-15 minutes
  * Time (full review): 1-2 days in the worst case, i.e., run all experiments,
    one at a time. See below for instructions on how to run multiple
    experiments in parallel (if memory and CPU resources allow).

External connectivity: NO


-------------------------------------------------------------------------------
**                             IMPORTANT NOTICE                              **
-------------------------------------------------------------------------------

The tool `sweap` depends on nuXmv internally. As a consequence,
YOU MUST READ AND AGREE TO THE NUXMV LICENSE BEFORE USING THIS REPOSITORY.
The license can be found at:

https://nuxmv.fbk.eu/downloads/LICENSE.txt

And inside the Docker image, at `/sweap/binaries/LICENSE-nuxmv`.

-------------------------------------------------------------------------------
**                                SMOKE TEST                                 **
-------------------------------------------------------------------------------

Run the following to load the Docker image:

```
docker load < sweap-cav26.tar
```

Extract the results from our run of the experiments with
`unzip benchmarks-submitted.zip`. This should create a directory name 
`benchmarks` in the working directory.
(Note: the directory is ~840 MB uncompressed).

To test that the code to generate tables and plots is working, run

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make tables
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make plots
```

(Note:
the `--rm` flag creates a disposable container that will be deleted upon exit.
the `-v` option mounts `benchmarks` below the container's root directory).


If any error occurs, please enclose the full output of these commands in the
smoke test report.

To start the smoke test, first remove all logs with:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make clean
```

Then, execute the following commands:

```
docker run --rm -v ./benchmarks:/benchmarks --memory 32g  --stop-timeout=300 sweap-cav26:latest make TIMEOUT=15 sweap-semml
docker run --rm -v ./benchmarks:/benchmarks --memory 32g  --stop-timeout=300 sweap-cav26:latest make TIMEOUT=15 issy3
```

These commands run both our tool (Sweap) and the baseline (Issy), with a 
short time limit of 15 seconds for each problem, a global timeout of 300 
seconds (5 minutes), and a memory limit of 32 GB. The script should display
which command is being executed and the timeout, similar to this
(first command):

```
python3 src/main.py --synthesise --synthesis_backend semml --p /benchmarks/sweap/tacas16/box-limited.prog 15
python3 src/main.py --synthesise --synthesis_backend semml --p /benchmarks/sweap/tacas16/box.prog 15
python3 src/main.py --synthesise --synthesis_backend semml --p /benchmarks/sweap/tacas16/diagonal.prog 15
...
```

and this (second command):

```
issy-bin --synt --caller-z3 /usr/bin/z3-4.15.1 --caller-muval /usr/bin/call-muval --caller-aut /usr/local/bin/ltl2tgba --issy /benchmarks/issy/cav25-azzopardi-arbiter-paper-unreal.issy 15
issy-bin --synt --caller-z3 /usr/bin/z3-4.15.1 --caller-muval /usr/bin/call-muval --caller-aut /usr/local/bin/ltl2tgba --issy /benchmarks/issy/cav25-azzopardi-arbiter-with-failure-variant.issy 15
issy-bin --synt --caller-z3 /usr/bin/z3-4.15.1 --caller-muval /usr/bin/call-muval --caller-aut /usr/local/bin/ltl2tgba --issy /benchmarks/issy/cav25-azzopardi-elevator-paper.issy 15
...
```

To check that the smoke test was successful, run the following command:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make tables > /dev/null
cat benchmarks/results/stats.csv
```

Notice that the second command is run _outside_ the container.
The output is CSV-formatted and should look like this

```
tool,right,wrong,timeout,oom,unsupported,error,total
issy3,0,0,6,0,0,0,6
sweap-pf,3,0,4,0,0,0,7
sweap-semml,3,0,4,0,0,0,7
```

The distribution of `right,wrong,timeout`, and `oom` columns might change but
the value of `error` should be `0` on all rows. If this is the case,
the smoke-test was successful. If not, please rerun without the
`>/dev/null` and include the full output in the report.

Assuming the smoke test passed, run the following commands to remove
the generated results:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make clean
```

-------------------------------------------------------------------------------
**                               FULL REVIEW                                 **
-------------------------------------------------------------------------------

The full experimental suite is described in a set of `make` recipes.
Each recipe name indicates a specific experimental configuration, as follows:

- Issy:
  * `issy3`: Issy on Issy files.
  * `issy3-<rpg|tsl>`: Issy on RPG or TSLMT files.

- Sweap, with SemML as the LTL synthesis backend:
  * `sweap-semml`, `sweap-dual`: Sweap on Sweap files, without/with dualisation.
  * `sweap-pf`: Virtual portfolio for `sweap-semml` and `sweap-dual`.
  * `sweap-<issy|rpg|tsl><-dual>`: Sweap on (Issy/RPG/TSLMT) files, without/with dualisation.
  * `sweap-<fmt>-pf`: Virtual portfolio of `sweap-<fmt>` and `sweap-<fmt>-dual`, for `<fmt> = issy, rpg, tsl`.

- Additional configurations:
  * `sweap-strix`, `sweap-strix-dual`: Sweap on Sweap files, with Strix as backend, without/with dualisation.

The full benchmark suite includes:

* 95 Sweap files (`.prog`), to be analysed with 4 configurations
  (`sweap-semml`, `sweap-dual`, `sweap-strix`, `sweap-strix-dual`)
* 266 non-Sweap files (`.issy`, `.rpg`, `.tsl`), to be analysed with 3
  configurations (`issy3-<fmt>`, `sweap-<fmt>`, `sweap-<fmt>-dual`)

This sums up to 1,178 total experiments. If the tasks are run one at a time,
even a (quite optimistic) average time of 2 minutes per experiments leads to
a total runtime of about 39 hours.
If resources allow, the `make` tasks may be executed concurrently.
We do _not_ recommend parallelising the individual tasks (e.g.,
`make -j2 ...`) as that could compromise intermediate file and produce corrupted
results.

To make the experimental evaluation faster, the user may also override the
default limit of 10 minutes per experiment by appending `TIMEOUT=<seconds>` to
any command. **We actually recommend performing a first run with `TIMEOUT=60`
for a 1-minute limit, which should show the general trends described in the
paper.** To delete only the results for experiments that timed out, run the
following command:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make clean-timeouts
```

The full list of commands to replicate all experiments is:

```
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-semml
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-dual
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-strix
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-strix-dual
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-rpg
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-rpg-dual
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-tsl
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make sweap-tsl-dual
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make issy3
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make issy3-rpg
docker run --rm --memory 32g -v ./benchmarks:/benchmarks sweap-cav26:latest make issy3-tsl
```


Also note that the experiments are resumable. If a `make` task is terminated
abruptly, invoking the same command will only run the experiments that have
not yet been performed.

Again, use the commands

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make tables > /dev/null
cat benchmarks/results/stats.csv
```

to obtain statistics on the results. (This may be done at any time without
interfering with running experiments). These results directly correspond
to those in Table 1. They are reported in CSV form with field named

```
tool,right,right_real,wrong,timeout,oom,unsupported,error,total,total_real,
```

which should be interpreted as follows:

* `tool` is one of the configurations described above.
* `right`, `right_real`: Number of correct verdicts made by the tool, both total and limited to realisable instances.
* `wrong`: Number of incorrect verdicts (realisable instances declared unrealisable, or vice versa).
* `timeout,oom`: Instances where the tool ran out of time or memory.
* `unsupported`: Instances using language features not supported by the tool, or failing with another, unrecognised error.
* `total,total_real`: Overall number of instances and how many of them are realisable.

When `make tables` is run, the CSV is saved in `benchmarks/results/stats.csv`.
Disaggregated results are also saved, in `benchmarks/results/results.csv`

To recreate the scatter plots from Figure 2 and the tables in Appendix
(Tables 3--5), run the following command:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make plots
```

The plots and TeX code for the tables will be saved in `benchmarks/results`.

-------------------------------------------------------------------------------
**                             PODMAN vs DOCKER                              **
-------------------------------------------------------------------------------

Note that the evaluation might also be performed using `podman` instead of
`docker`, with minimal changes to the command lines provided above (e.g.,
`--stop-timeout` becomes `--timeout` in Podman).

-------------------------------------------------------------------------------
**                            REUSABLE BADGE                                 **
-------------------------------------------------------------------------------

The tool and artifact are open-source, with code available at:

* https://github.com/shaunazzopardi/sweap/
* https://github.com/dSynMa/sweap-docker/tree/cav2026


As part of our claim to the _Reusable_ badge, we prepared the artifact so that
users can use it to run Sweap beyond the scope of experiment replication.
To obtain inline help, use the following command:

```
docker run --rm sweap-cav26:latest sweap --help
```

To solve a problem `dir/program.prog`, the user should mount the directory
`dir` onto the container. The basic command for this is

```
docker run --rm -v ./dir:/dir sweap-cav26:latest sweap --synthesise --synthesis_backend semml --p /dir/program.prog
```

Additional documentation on the input format is available at this URL:

https://github.com/shaunazzopardi/sweap/blob/dddfc726f59a3c606d2c9b322d656296f90a2a40/SYNTAX.md

This documentation is also part of the artifact, and may be extracted with
the command

```
docker run --rm sweap-cav26:latest cat /sweap/SYNTAX.md
```
