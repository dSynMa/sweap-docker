# Replication instructions

This document is a guide to replicate experiments related to the reactive synthesis tool `sweap` ("the tool").
To support reproducibility, we provide instructions ("the `Dockerfile`s") to build an OS-level virtualization image ("the image").
The image contains all software needed to replicate these experiments, and allows to run the experiments on a containerisation platform such as Podman.

## Legal preliminaries

Make sure you have read `/LICENSE`, `containers/LICENSE`, and `DISCLAIMER` before proceeding.

In short:

* The original contents of this repository, i.e., mostly the `Dockerfile`s, are BSD-licensed.
* The image will contain a source copy of the tool, subject to the restrictions described in `containers/LICENSE`.
* These restrictions do allow artifact evaluations.
* The image and the tool therein may only be used for the purpose of artifact evaluation.
* Using this version of the tool for any other purpose requires explicit prior consent by the copyright holders.
* Containers based off the image will automatically download a copy of Nuxmv if needed. This means the user must read and agree with the Nuxmv license (https://nuxmv.fbk.eu/downloads/LICENSE.txt) to use the image.
* The image itself may be redistributed for academic, non-commercial research purpose.

## Building the image

We recommend using Podman. (We provide a `make` recipe to build a Docker image, but have not tested it extensively.)

From the root directory, invoke:

```bash
make artifact-podman
```

This will build a Podman image called `sweap-artifact`, using the `containers/Dockerfile` description.

To check that the build has completed successfully, invoke:

```bash
podman image ls 
```

The output should contain something like the following:

```
REPOSITORY                        TAG         IMAGE ID      CREATED       SIZE
...
localhost/sweap-artifact             latest      ...
...
```

## Running experiments

```bash
podman run  --memory 16G -t -v ./benchmarks:/benchmarks localhost/sweap-artifact:latest make [tool]
```

where `[tool]` is one of `sweap, sweap-noacc, sweap-nobin, rpgsolve, rpgsolve-syn, rpg-stela, tslmt2rpg, tslmt2rpg-syn, raboniel, temos`.

* `sweap` and `sweap-noacc` are respectively S_acc and S in the paper.
* `sweap-nobin` is S with the binary encoding disabled, and is only evaluated in the appendix.

This command runs `[tool]` on benchmarks taken from the `benchmarks/[tool]` directory, and generates a `benchmarks/[tool]/.../[bench].[tool].log` file for every completed experiment. It will also skip any benchmark for which a log already exists. Hence, the command is restartable: if needed, one may stop the container (`podman stop ...`) and run remaining experiments at a later time.

Note that:

* `--memory 16G` enforces a memory limit of 16GB. If an experiment exceeds this quota, it will fail with an out-of-memory error and the next experiment will be executed.
* `-t` allocates a pseudo-tty to the container, needed for the logging to work correctly.
* `-v ./benchmarks:/benchmarks` option mounts the `./benchmarks` directory as `/benchmarks` within the container.

Special shortcuts are `make all` (every tool except `temos` and `sweap-nobin`) and `make everything` (every tool).

Each experiment is given a default time limit of 1200'' (20 minutes). For shorter timeouts, use e.g.,

```bash
podman run ... make [tool] TIMEOUT=120
```

for a 2' timeout. `TIMEOUT` **must** be in **upper case**.
Notice that this might partially affect the output of some scripts in the next section, which expect a 20' timeout.


Running the entire benchmark suite, one experiment at a time, on all tools from `make all` with the default timeout takes around 5-6 days.
To speed up things, one may:

* reduce the timeout as explained before; and/or
* run two or more containers side by side. This should work as long as the machine has enough resources and the containers are running experiments for different tools.

## Generating tables and plots

Run _in this order_:

```bash
podman run -t -v ./benchmarks:/benchmarks localhost/sweap-artifact:latest make tables
podman run -t -v ./benchmarks:/benchmarks localhost/sweap-artifact:latest make plots
```

This will generate several `.tex` and `.pdf` files and a `.csv` under `benchmarks/results`.

Optionally, you may compile `benchmarks/results/main.tex` to obtain a PDF of these results,
using the traditional workflow:

```bash
cd benchmarks/results
pdflatex main
bibtex main
pdflatex main
pdflatex main
```

## Running sweap manually

To run sweap manually, use:

```bash
podman run -t -v [...bind mount...] localhost/sweap-artifact:latest sweap --synthesise --p /path/to/file.prog
```

Notice that you will need to bind the directory of your `.prog` file, so that the container can find it. Here, for instance, we kept the `benchmarks` bind. An example:

```bash
podman run -t -v /path/to/benchmarks:/benchmarks localhost/sweap-artifact:latest sweap --synthesise --p /benchmarks/sweap/full-ltl/elevator-paper.prog
```

When it terminates, Sweap prints:

* `Realizable.`, followed by a controller in HOA format, if it manages to synthesise a controller;
* or `Unrealizable.`, followed by a counterstrategy in DOT format, if it determines that the problem is unrealizable.

Please run:

```bash
podman run -t -v localhost/sweap-artifact:latest sweap --help
```

to get detailed usage instructions.