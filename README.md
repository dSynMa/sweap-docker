CAV 2026 Artifact
=======================================
Paper title: "Sweap: Reactive Synthesis for Infinite-State Integer Problems"

Claimed badges: Available + Functional + Reusable

Justification for the badges:

  * Functional: The artifact allows to replicate the results shown in the
    paper (see below), and includes the source code for the tool.

    - replicated:
       * Table 1, 
       * Figures 3a-d,
       * Tables 2-4 (in Appendix).

    - not-replicated: N/A


  * Reusable: The tool is licensed under GNU GPLv3. The artifact allows to
    execute the tool on arbitrary problems besides the benchmarks;
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

Each names indicates a specific experimental configuration, as follows:

- Issy:
  * `issy3`: Issy on Issy files.
  * `issy3-<rpg|tsl>`: Issy on RPG or TSLMT files.

- Sweap, with SemML as the LTL synthesis backend:
  * `sweap-semml`, `sweap-dual`: Sweap on Sweap files, without/with dualisation.
  * `sweap-pf`: Virtual portfolio for `sweap-semml` and `sweap-dual`.
  * `sweap-<issy|rpg|tsl><-dual>`: Sweap on (Issy/RPG/TSLMT) files, without/with dualisation.
  * `sweap-<lang>-pf`: Virtual portfolio of `sweap-<lang>` and `sweap-<lang>-dual`, for `<lang> = issy, rpg, tsl`.

- Additional configurations:
  * `sweap-strix`, `sweap-strix-dual`: Sweap on Sweap files, with Strix as backend, without/with dualisation.


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

Additional documentation on the input format is available below.

The tool and artifact are open-source, with code available at:

* https://github.com/shaunazzopardi/sweap/
* https://github.com/dSynMa/sweap-docker/tree/cav2026



# `.prog` Syntax

This appendix gives an overview of how to specify `sweap` problems in `.prog` syntax, used with the `--p` flag in command line invocation:
`python src/main.py --p <spec.prog>`.

The format describes a symbolic reactive synthesis problem: a finite arena, input/output variables, state variables, transitions, and an LTL
objective.

## Skeleton

A `.prog` file consists of a single arena declaration:

```text
arena <name> {
    CONTROL STATES { <states> }

    INPUTS { <input-events> }

    OUTPUTS { <output-events> }

    STATE VARIABLES { <local-state-variables> }

    TRANSITIONS [<options>] { <transitions> }

    OBJECTIVE { <ltl-objective> }
}
```

The top-level sections may appear in any order. Section names must not be
duplicated. The parser requires control states, inputs, outputs, local state
variables, and transitions. In normal synthesis usage, also provide an
`OBJECTIVE` section.

Preferred section names and accepted aliases (for backwards compatibility) are:

```text
arena            (also accepts program)
CONTROL STATES   (also accepts STATES)
INPUTS           (also accepts ENVIRONMENT EVENTS)
OUTPUTS          (also accepts CONTROLLER EVENTS)
STATE VARIABLES  (also accepts VALUATION)
OBJECTIVE        (also accepts SPECIFICATION)
```

Commas and semicolons are both accepted as separators in declaration lists and
transition lists. A trailing comma or semicolon is usually accepted.

## Names

Program names and event/state-variable declarations use:

```text
[_a-zA-Z][_a-zA-Z0-9$@_-]*
```

State names are parsed more permissively:

```text
[a-zA-Z0-9@$_-]+
```

Formula atoms are parsed by the LTL parser and are narrower in practice:

```text
_?[a-zA-Z][a-zA-Z0-9_-]*
```

For names that appear in guards or specifications, prefer ordinary
letter-starting identifiers with letters, digits, and underscores. Avoid names
matching reserved internal patterns such as `true`, `false`, `lose`, `pred_*`,
`bin_*`, `guard_*`, `act_*`, `eq_con_*`, `sat_con_*`, and
`minigame_event_*`.

Control-state names, event names, and local state-variable names must be
globally unique.

## Control States

The `CONTROL STATES` section lists control states. Exactly one state must be tagged
`: init`.

```text
CONTROL STATES {
    idle : init, busy, done
}
```

## Variables

Accepted variable types are boolean or integers.

Supported types:

```text
bool, boolean
nat, natural
int, integer
[lower..upper], (lower..upper], [lower..upper), (lower..upper)
```

### Input and Output Variables

`INPUTS` and `OUTPUTS` declare variables controlled by the environment and
controller respectively. The older `ENVIRONMENT EVENTS` and `CONTROLLER EVENTS`
section names are still parsed for backwards compatibility, but new files
should use `INPUTS` and `OUTPUTS`.

```text
INPUTS {
    request, delta : integer, limit : [0..10]
}

OUTPUTS {
    grant, finished : boolean
}
```

Untyped variables are interpreted as boolean. 

Output variables must be boolean; non-boolean output variables will result in a parsing error.

Empty `INPUTS` and `OUTPUTS` sections are accepted.

### State Variables

`STATE VARIABLES` declares local state variables owned by the program, for example:

```text
STATE VARIABLES {
    count : natural := 0;
    mode : [0..3] := 0;
    enabled : bool := false;
    unconstrained : integer;
    arbitrary_start : integer := *;
}
```

Initial values are optional, omitting `:= ...` leaves the initial value
unconstrained. When unconstrained, the specification universally quantifies over all possible initial values. That is, a controller must work for all possible unspecified initial values, while a counterstrategy must work for at least one initial valuation.

## Formulas

Guards and normal action conditions are propositional formulas over current
state variables, inputs, and outputs. LIA predicates are also allowed.

Common operators:

```plain
true, false, TRUE, FALSE
!p
p & q      or p && q
p | q      or p || q
p -> q     or p => q
p <-> q    or p <=> q
x = y      or x `== y
x != y
x < y, x <= y, x > y, x >= y
x + y, x - y, -x
```

`OBJECTIVE` formulas additionally allow LTL operators and reference to control states (and also LIA predicates):

```text
X p
F p
G p
p U q
p W q
p R q
p M q
```

Examples:

```text
G(request -> F grant)
G((count >= 0) -> F(done & count = 0))
(!idle) U done
```

## Transitions

Transitions define how the state variables values are allowed to evolve. `sweap` supports two styles of transition specification: guarded assignments, and propositional formulas over current and next variable labels:

```text
source -> target [ guard $ <guarded-assignments|formula(V,V')> ]
```

The guard is optional and if not present the interpretation defaults to `true`. 

### Canonical Transitions

The high-level syntax, while more concise, is not the canonical arena format used internally by sweap. The canonical arena transitions are simpler, consisting of a source state, target state, a guard formula over current variables only, and explicit assignments for each local state variables. 

In a canonical arena, given a set of transitions from a state `s`, with guards `g_0`, ..., `g_n`, these guards must be mutually exclusive, and they must cover all possible valuations of the variables in `s` (i.e. `g_0 | ... | g_n` must be a tautology). 

Non-mutually exclusive guards introduce nondeterminism, and will result in a parsing error. A user can manually deal with this non-determinism by introducing new input or output variables to allow the environment or controller to choose between the transitions.

For convenience, `sweap` allows incomplete guards, but the user must specify how to complete them with the `completion` option (see below). 

To view the canonical arena from a higher-level `sweap` specification, use the following command:

```text
python src/main.py --p <spec.prog> --translate prog
```

### Guarded Assignments

Assignments are exact updates of a state variable:

```text
x := x + 1
enabled := request & x > 0
```

The left-hand side of an assignment must be a local state variable. The right-hand side is a formula over current input, output, and/or state variables; it cannot reference next variables. For boolean variables, is any boolean formula over the mentioned variables (including LIA predicates). For integer variables, the right-hand side must be an arithmetic expression over the mentioned variables, using addition, subtraction, and negation.

Assignments are optional. When an assignment for a state variable is not defined, the interpretation defaults to the identity assignment. For a list of assignments, a variable can only be assigned once.

Examples:

```text
idle -> busy [request]
busy -> idle [done $ count := count - 1]
busy -> busy [$ count := count + 1]
busy -> idle [done $]
```

Multiple updates may be separated by commas or semicolons:

```text
q0 -> q1 [request $ count := count + 1; enabled := true]
```

An update can have its own condition using the literal token ` if `:

```text
q -> q [true $
    x := x + 1 if inc;
    x := x - 1 if dec & x > 0;
    active := inc | dec
]
```

For multiple guarded updates to the same variable, the parser treats them in
order: later updates only apply where earlier guards for that same variable did
not apply. If none applies, the variable is left unchanged by normal action
completion.

### `otherwise` Transitions

The special guard `otherwise` is a fallback for one source state:

```text
s0 -> s1 [x > 0 $ x := x - 1],
s0 -> s2 [otherwise $ x := x + 1]
```

It is expanded to the negation of the disjunction of the other guards from the same source state.
At most one `otherwise` transition is allowed per source state.

### Formulas over Current and Next Variables

`#` introduces a relational action formula over current variable values and next state variable values. Use a
prime suffix to refer to the next value of a local variable.

```text
q0 -> q1 [true # (x' = x + 1) & (y' = x)]
q0 -> q1 [x > 0 # (x' = 0) | (x' = 1)]
q0 -> q1 [true #]
```

These propositional formulas may reference local state variables (either current
or primed next values), and input and output variables (only current value).

When such a formula does not constrain a local variable, that
variable is treated as **nondeterministically updated, not as an identity update**. Note this differs from the guarded assignment style, where unconstrained variables are treated as identity updates. This allows more concise specification of general relational constraints over next variables, but also requires care to avoid unintentionally leaving variables unconstrained.

An empty `#` therefore allows any next local state for all local variables.

Equality constraints such as `x' = x + 1` are lowered to ordinary updates.
Branching formulas may lower to several transitions. More general relational
constraints over next variables can introduce fresh internal (minigame) states, to allow the controller to choose any value of a next variable that satisfies the constraint. Thus, a transition that appears to take one time step in the original specification may take several time steps in the canonical arena. The LTL objective is modified automatically to ignore these extra time steps, maintaining equirealisability of the original specification.

Example:

```text
q0 -> q1 [true # (x' >= x + 1)]
```

results in the addition of a fresh internal state `q0_minigame_0`, a fresh controller output `minigame_event_0`, and the following transitions:

```text
q0 -> q0_minigame_0 [true $ x := x + 1],
q0_minigame_0 -> q0_minigame_0 [!minigame_event_0 $ x := x + 1],
q0_minigame_0 -> q1 [minigame_event_0],
```

If the objective was `F (x = 10)`, it would be automatically modified to `F (!q0_minigame_0 & x = 10) & G(F(!q0_minigame_0))`.

## Transition Options

Options are written after `TRANSITIONS`:

```text
TRANSITIONS [completion=stutter] { ... }
TRANSITIONS [completion=lose] { ... }
```

These two options are the only currently supported options. They specify how to complete the transition relation when the guards do not cover all possible valuations of the variables.

`completion=stutter` fills uncovered behavior from a reachable source state with stutter transitions (remain in same control state, and state variables maintain their current value in the next state).

`completion=lose` fills uncovered behavior with transitions to a generated
`lose` sink state and adds `G(!lose)` to the objective guarantees. Reaching this state, if the environment respects the assumptions, results in a loss for the controller.

If no `completion` option is specified, incomplete transition coverage results in an error.

## Complete Example

```text
program small_counter {
    CONTROL STATES {
        idle : init, busy
    }

    INPUTS {
        request, reset
    }

    OUTPUTS {
        grant
    }

    STATE VARIABLES {
        count : natural := 0;
        served : bool := false;
    }

    TRANSITIONS [completion=stutter] {
        idle -> busy [request $ count := count + 1; served := false],
        busy -> idle [grant & count > 0 $ count := count - 1; served := true],
    }

    OBJECTIVE {
        G(request -> F grant)
    }
}
```

The canonical arena for this example will add the following transitions:

```text
idle -> idle [!request]
busy -> busy [!grant | count = 0]

## Guarded-Update Example

```text
program robot_step {
    CONTROL STATES {
        q : init
    }

    INPUTS {
        inc, dec
    }

    OUTPUTS {
        move
    }

    STATE VARIABLES {
        x : integer := 0
    }

    TRANSITIONS [completion=stutter] {
        q -> q [true $
            x := x + 1 if move & inc;
            x := x - 1 if move & dec & x > 0
        ]
    }

    OBJECTIVE {
        G(move -> F(x = 0))
    }
}
```

The canonical arena for this example will have following transition section:

```text
q -> q [move & inc $ x := x + 1],
q -> q [move & dec & x > 0 $ x := x - 1],
q -> q [!((move & inc) | (move & dec & x > 0)) $]
```

## Relational `#` Example

```text
program relational_step {
    CONTROL STATES {
        q0 : init, q1
    }

    INPUTS {
    }

    OUTPUTS {
    }

    STATE VARIABLES {
        x : integer := 0;
        y : integer := 0;
    }

    TRANSITIONS [completion=stutter] {
        q0 -> q1 [true # (x' > x + 1) & (y' = x)],
        q1 -> q1 [true # (x' < x) & (y' = y)]
    }

    OBJECTIVE {
        G true
    }
}
```

The canonical arena for this example will have the following transition section:

```text
q0 -> q0_minigame_0 [true $ x := x + 2, y := x],
q0_minigame_0 -> q0_minigame_0 [!minigame_event_0 $ x := x + 1, y := x],
q0_minigame_0 -> q1 [minigame_event_0],
q1 -> q1_minigame_1 [true $ x := x - 1, y := x],
q1_minigame_0 -> q1_minigame_0 [!minigame_event_0 $ x := x - 1, y := y],
q1_minigame_0 -> q1 [minigame_event_0]
```

Note, if the controller has boolean outputs, we re-use these outputs as the minigame events, so the translation of `#` formulas may not always introduce fresh outputs. Given we massage the LTL objective to ignore behaviour at minigame state equirealisability is preserved, while avoiding introducing unnecessary fresh controller outputs (which would increase the complexity of synthesis).
