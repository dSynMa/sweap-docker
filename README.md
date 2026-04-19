CAV 2026 Artifact
=======================================
Paper title: "Sweap: Reactive Synthesis for Infinite-State Integer Problems"

Claimed badges: Available + Functional + Reusable

Justification for the badges: [no need to justify Available -- just provide the DOI link in HotCRP]

  * Functional: [give reasons why you believe that the Functional badge should
    be awarded (if applied for Functional or Reusable); 
    
    
    example: The artifact allows to replicate the results shown in the
    paper (see below). The artifact also includes the source code
    for the tool.

    - replicated: [which claims/results of the paper are replicated by the
      artifact and how (you can, e.g., refer to a concrete point in FULL REVIEW
      below), e.g.,
       * Figure 1, 
       * Table 2.
      ]

    - not-replicated: 


  * Reusable: The tool is licensed under GNU GPLv3. The artifact allows to
    execute the tool on arbitrary problems besides the benchmarks (see below).
    
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

external connectivity: NO

-------------------------------------------------------------------------------
**                                SMOKE TEST                                 **
-------------------------------------------------------------------------------

Run the following to load the Docker image:

```
docker load < docker-tool-image.tar
```

Extract the results from our run of the experiments with
`unzip benchmarks-submitted.zip`. This should create a directory name 
`benchmarks` in the working directory.

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
docker run --rm -v ./benchmarks:/benchmarks --memory 32g  --stop-timeout=300 sweap-cav26:latest make TIMEOUT=15 issy
```

These commands try to run both our tool (sweap) and the baseline (issy), with a 
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
`>/dev/null && cat ...` and include the full output in the report.

-------------------------------------------------------------------------------
**                               FULL REVIEW                                 **
-------------------------------------------------------------------------------

Assuming the smoke test passed, run the following commands to remove
previous results:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make clean
```

Then, the full benchmark suite may be evaluated by running these commands:

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

Running the full benchmark suite can take days on a standard laptop if the
`make` tasks are run one at a time. If resources allow, the commands may be execute
concurrently. We do _not_ recommend parallelising the individual tasks (e.g.,
`make -j2 ...`) as that could compromise intermediate file and produce corrupted
results.

To make the experimental evaluation faster, the user may also override the
default limit of 10 minutes per experiment by appending `TIMEOUT=<seconds>` to
any command. We actually recommend performing a first run with `TIMEOUT=300`
for a 5-minute limit, which should show the general trends described in the
paper. To delete only the results for experiments that timed out, run the
following command:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make clean-timeouts
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
to those in Table 1, although they are not broken down into realisable and
unrealisable problems.

To recreate the scatter plots from Figure 2 and the tables in Appendix
(Tables 3--5), run the following command:

```
docker run --rm -v ./benchmarks:/benchmarks sweap-cav26:latest make plots
```

The plots and TeX code for the tables will be generated in
`benchmarks/results`.

-------------------------------------------------------------------------------
**                            REUSABLE BADGE                                 **
-------------------------------------------------------------------------------

As part of our claim to the _Reusable_ badge, we prepared the artifact so that
users can use it to run Sweap beyond the scope of experiment replication.
To obtain inline help, use the following command:

```
docker run --rm sweap --help
```

To solve a problem `dir/program.prog`, the user should mount the directory
`dir` onto the container. The basic command for this is

```
docker run --rm -v ./dir:/dir sweap-cav26:latest sweap --synthesise --synthesis_backend semml --p /dir/program.prog
```

Additional documentation on the tool and its input format are available with 
this command:

```
docker run --rm sweap-cav26:latest cat README.md
```

The tool and artifact are open-source, with code available at:

* https://github.com/shaunazzopardi/sweap/
* https://github.com/dSynMa/sweap-docker/tree/cav2026

-------------------------------------------------------------------------------
**                             FINAL REMARKS                                 **
-------------------------------------------------------------------------------

Note that the evaluation might also be performed using `podman` instead of
`docker`, with minimal changes to the command lines provided above (e.g.,
`--stop-timeout` becomes `--timeout` in Podman).

