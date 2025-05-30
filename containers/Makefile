# Shortnames we give to the tools
TOOLS := raboniel rpgsolve rpgsolve-syn rpg-stela sweap sweap-noac sweap-nobin temos tslmt2rpg tslmt2rpg-syn
# Timeout for each benchmark, in seconds
TIMEOUT := 1200

# Memory limit for tslmt2rpg
MEMLIMIT := 16G

# Directory that contains this Makefile
ROOT_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
BENCHMARKS_DIR := /benchmarks

.PHONY: all others everything clean clean-aux clean-timeouts tables plots $(TOOLS)

# Paths to benchmark files
SWEAP_BENCHS :=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/tacas16/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/cav24/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/isola24/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl24/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/basic/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/limitations/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/misc/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/robot-missions/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/tasks/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/popl25/thermostat/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/full-ltl/*.prog))
SWEAP_BENCHS +=		$(basename $(wildcard $(BENCHMARKS_DIR)/sweap/full-ltl/hard/*.prog))
RPG_BENCHS :=		$(basename $(wildcard $(BENCHMARKS_DIR)/rpgsolve/*.rpg))
RABONIEL_BENCHS :=	$(basename $(wildcard $(BENCHMARKS_DIR)/raboniel/*.tslmt))
TEMOS_BENCHS := 	$(basename $(wildcard $(BENCHMARKS_DIR)/temos/*.tslt))
TSLMT2RPG_BENCHS :=	$(basename $(wildcard $(BENCHMARKS_DIR)/tslmt2rpg/*.tslmt))


SWEAP_LOGS :=			$(addsuffix .sweap.log, 			$(SWEAP_BENCHS))
SWEAP_LAZY_LOGS :=		$(addsuffix .sweap-noacc.log, 		$(SWEAP_BENCHS))
SWEAP_NOBIN_LOGS :=		$(addsuffix .sweap-nobin.log,       $(SWEAP_BENCHS))
RPG_STELA_LOGS :=		$(addsuffix .rpg-stela.log,			$(RPG_BENCHS))
RPG_SYN_LOGS :=			$(addsuffix .rpgsolve-syn.log,		$(RPG_BENCHS))
RPG_LOGS :=				$(addsuffix .rpgsolve.log,			$(RPG_BENCHS))
RABONIEL_LOGS :=		$(addsuffix .raboniel.log,			$(RABONIEL_BENCHS))
TEMOS_LOGS :=			$(addsuffix .temos.log,				$(TEMOS_BENCHS))
TSLMT2RPG_LOGS :=		$(addsuffix .tslmt2rpg.log,			$(TSLMT2RPG_BENCHS))
TSLMT2RPG_SYN_LOGS :=	$(addsuffix .tslmt2rpg-syn.log,		$(TSLMT2RPG_BENCHS))

# Tool command-line invocation
$(SWEAP_LOGS): cmd = 			sweap --synthesise --p
$(SWEAP_LAZY_LOGS): cmd =		sweap --synthesise --lazy --p
$(SWEAP_NOBIN_LOGS): cmd =		sweap --synthesise --no_binary_enc --p
$(RPG_STELA_LOGS): cmd = 		rpg-stela solve --enable-no-pruning <
$(RPG_SYN_LOGS): cmd =			rpgsolve-popl24 --generate-program --disable-log <
$(RPG_LOGS): cmd =			rpgsolve-popl24 --disable-log <
$(RABONIEL_LOGS): cmd =			./raboniel --spec
$(TEMOS_LOGS): cmd = 			temos.sh
$(TSLMT2RPG_LOGS): cmd =		/wrapper.sh <
$(TSLMT2RPG_SYN_LOGS): cmd =		/wrapper-syn.sh <

# paths that the tool needs in $PATH
path =							binaries
$(SWEAP_LOGS) : path =			binaries:binaries/CPAchecker-2.3-unix/scripts
$(SWEAP_LAZY_LOGS): path =		binaries:binaries/CPAchecker-2.3-unix/scripts
#$(RPG_SYN_LOGS): path =			binaries/z3-4-8:binaries
#$(TSLMT2RPG_LOGS): path =		binaries
#$(TSLMT2RPG_SYN_LOGS): path =		binaries

# Because Raboniel will run from binaries/
$(RABONIEL_LOGS): path = 		.

# Set up environment variables, create temporary log file, record start time
define HEADER
	export PATH=$(path):$$PATH ;\
	export FILE=$$(mktemp --suffix .log) ;\
	echo "timeout $(TIMEOUT) $(cmd) $<" >> $$FILE ;\
	starttime=`date +%s%N`
endef

# Record return code and elapsed time, move log file to its final location
define FOOTER
	exitcode=$$? ;\
	endtime=`date +%s%N` ;\
	echo $$exitcode >> $$FILE ;\
	echo $$(((endtime - starttime)/1000000)) >> $$FILE ;\
	mv $$FILE $(ROOT_DIR)/$@
endef

all: raboniel rpgsolve rpgsolve-syn rpg-stela sweap sweap-noacc tslmt2rpg tslmt2rpg-syn
everything: all temos sweap-nobin

sweap:          /bin/nuxmv check-existing-logs-sweap $(SWEAP_LOGS)
sweap-noacc:    /bin/nuxmv check-existing-logs-sweap-noacc $(SWEAP_LAZY_LOGS)
sweap-nobin:    /bin/nuxmv check-existing-logs-sweap-nobin $(SWEAP_NOBIN_LOGS)
rpg-stela:      check-existing-logs-rpg-stela $(RPG_STELA_LOGS)
rpgsolve-syn:   check-existing-logs-rpgsolve-syn $(RPG_SYN_LOGS)
rpgsolve:       check-existing-logs-rpgsolve $(RPG_LOGS)
raboniel:       check-existing-logs-raboniel $(RABONIEL_LOGS)
temos:          check-existing-logs-temos $(TEMOS_LOGS)
tslmt2rpg:      check-existing-logs-tslmt2rpg $(TSLMT2RPG_LOGS)
tslmt2rpg-syn:  check-existing-logs-tslmt2rpg-syn $(TSLMT2RPG_SYN_LOGS)

################################################################################
# Here are the core commands that run a tool on a benchmark <bench>.<ext>
# and record all output into <bench>.<tool>.log
# The log also contains the exact command line, the return code,
# and the execution time (in ms)

$(SWEAP_LOGS): %.sweap.log: %.prog
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(SWEAP_LAZY_LOGS): %.sweap-noacc.log: %.prog
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(SWEAP_NOBIN_LOGS): %.sweap-nobin.log: %.prog
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(RPG_STELA_LOGS): %.rpg-stela.log : %.rpg
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(RPG_SYN_LOGS): %.rpgsolve-syn.log : %.rpg
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(RPG_LOGS): %.rpgsolve.log : %.rpg
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(RABONIEL_LOGS): %.raboniel.log : %.tslmt
	@echo "$(cmd) $< $(TIMEOUT)"
	@cd /bin ; $(HEADER) ;\
	timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(TEMOS_LOGS): %.temos.log : %.tslt
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(TSLMT2RPG_LOGS): %.tslmt2rpg.log : %.tslmt
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

$(TSLMT2RPG_SYN_LOGS): %.tslmt2rpg-syn.log : %.tslmt
	@echo "$(cmd) $< $(TIMEOUT)"
	@$(HEADER) ; /usr/bin/time timeout $(TIMEOUT) $(cmd) $< >> $$FILE 2>&1 ; $(FOOTER)

################################################################################

################################################################################
# Cleanup commands
clean: clean-aux
	@echo "Cleaning up all logs..."
	-@rm $(SWEAP_LOGS) 2>/dev/null || true
	-@rm $(SWEAP_LAZY_LOGS) 2>/dev/null || true
	-@rm $(SWEAP_NOBIN_LOGS) 2>/dev/null || true
	-@rm $(RPG_LOGS) 2>/dev/null || true
	-@rm $(RPG_SYN_LOGS) 2>/dev/null || true
	-@rm $(RPG_STELA_LOGS) 2>/dev/null || true
	-@rm $(RABONIEL_LOGS) 2>/dev/null || true
	-@rm $(TEMOS_LOGS) 2>/dev/null || true
	-@rm $(TSLMT2RPG_LOGS) 2>/dev/null || true
	-@rm $(TSLMT2RPG_SYN_LOGS) 2>/dev/null || true

clean-aux:
	@echo "Cleaning up auxiliary files..."
	-@rm -rf $(BENCHMARKS_DIR)/raboniel/*.t 2>/dev/null || true
	-@rm -rf $(BENCHMARKS_DIR)/raboniel/*.tsl 2>/dev/null || true
	-@rm -rf $(BENCHMARKS_DIR)/raboniel/*.py 2>/dev/null || true
	-@rm -rf $(BENCHMARKS_DIR)/raboniel/*.t_R*.tlsf 2>/dev/null || true
	-@rm -rf $(BENCHMARKS_DIR)/raboniel/*.t_R*.kiss 2>/dev/null || true

clean-timeouts:
	@echo "Cleaning up logs for experiments that timed out..."
	-@tail -n2 $(RABONIEL_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(TEMOS_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(SWEAP_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(SWEAP_LAZY_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(SWEAP_NOBIN_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(RPG_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(RPG_SYN_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(RPG_STELA_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(TSLMT2RPG_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true
	-@tail -n2 $(TSLMT2RPG_SYN_LOGS) 2>/dev/null | grep -B1 124 | grep "==>" | cut -d ' ' -f2 | xargs rm -v 2>/dev/null || true

/bin/nuxmv:
	@echo "!!! nuxmv not found, it will be installed."
	@echo "!!! Make sure you read and agree with the NuXmV license at:"
	@echo "!!! https://nuxmv.fbk.eu/downloads/LICENSE.txt"
	@wget --content-disposition https://nuxmv.fbk.eu/theme/download.php\?file\=nuXmv-2.1.0-linux64.tar.xz && \
    tar -xf nuXmv-2.1.0-linux64.tar.xz && \
    mv nuXmv-2.1.0-linux64/bin/nuXmv /bin/nuxmv && \
    rm -rf nuXmv-2.1.0-linux64*
	@echo "!!! NuXmv installed successfully"


################################################################################
tables: #$(ALL_LOGS)
	@scripts/process_logs.py $(BENCHMARKS_DIR)

plots:
	cd scripts; \
	./cactus.py ../benchmarks/results/results.csv

define TEST_LOGS
	if [ "$$number" -ge "$$exp" ] ; then \
		echo "Logs already exist, no experiments will run." && \
		echo "Use 'make clean' or 'make clean-timeouts' to remove log files." ; \
	fi	
endef

check-existing-logs-sweap:
	@number=`find $(BENCHMARKS_DIR)/sweap -iname '*.sweap.log' | wc -l`; exp=97 ; $(TEST_LOGS)
check-existing-logs-sweap-noacc:
	@number=`find $(BENCHMARKS_DIR)/sweap -iname '*.sweap-noacc.log' | wc -l`; exp=97 ; $(TEST_LOGS)
check-existing-logs-sweap-nobin:
	@number=`find $(BENCHMARKS_DIR)/sweap -iname '*.sweap-nobin.log' | wc -l`; exp=97 ; $(TEST_LOGS)

check-existing-logs-rpgsolve:
	@number=`find $(BENCHMARKS_DIR)/rpgsolve -iname '*.rpgsolve.log' | wc -l`; exp=88 ; $(TEST_LOGS)
check-existing-logs-rpgsolve-syn:
	@number=`find $(BENCHMARKS_DIR)/rpgsolve -iname '*.rpgsolve-syn.log' | wc -l`; exp=88 ; $(TEST_LOGS)
check-existing-logs-rpg-stela:
	@number=`find $(BENCHMARKS_DIR)/rpgsolve -iname '*.rpg-stela.log' | wc -l`; exp=88 ; $(TEST_LOGS)

check-existing-logs-raboniel:
	@number=`find $(BENCHMARKS_DIR)/raboniel -iname '*.raboniel.log' | wc -l`; exp=66 ; $(TEST_LOGS)
check-existing-logs-temos:
	@number=`find $(BENCHMARKS_DIR)/temos -iname '*.temos.log' | wc -l`; exp=66 ; $(TEST_LOGS)

check-existing-logs-tslmt2rpg:
	@number=`find $(BENCHMARKS_DIR)/tslmt2rpg -iname '*.tslmt2rpg.log' | wc -l`; exp=66 ; $(TEST_LOGS)
check-existing-logs-tslmt2rpg-syn:
	@number=`find $(BENCHMARKS_DIR)/tslmt2rpg -iname '*.tslmt2rpg-syn.log' | wc -l`; exp=66 ; $(TEST_LOGS)
