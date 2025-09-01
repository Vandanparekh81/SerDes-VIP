path += ../sv/env/serdes_pkg.sv

sim_dir = ../sim/

log = log/

top_module = tb_top

sim_dir_home = /home/vandan-parekh/Downloads/uvm_examples/single_component_project_serdes/vip/sim/

override test_name ?= serdes_sanity_test

override data_pattern_seq ?= RANDOM

override serial_transaction_count ?= 1

override parallel_transaction_count ?= 1

override speed ?= 1

override verbosity ?= UVM_MEDIUM

override scoreboard ?= 1

override coverage ?= 1

work += ../script/work

override waves ?= 0

ifeq ($(waves),1)
	wlf += ./*.wlf
endif

override seed ?= random
directory = $(test_name)

ifeq ($(seed),random)
        SEED := $(shell bash -c 'echo $$RANDOM')
else
        SEED := $(seed)
endif

PATH_ABS := $(abspath $(path))

all: compile sim move

compile_with_vsim: compile sim

compile:
	@echo "Using random seed $(SEED)"
ifeq ($(seed),random)
	seed=$(SEED)
	@echo "Using random seed: $(seed)"
endif
	@echo "compiling......"
	@mkdir -p ./work
ifeq ($(coverage),1)
	@vlog -work ./work -O0 +fcover +acc -cover bcst $(path)
else
	@vlog -work ./work -O0 +acc $(path)
endif

sim:
	@vopt -work ./work work.$(top_module) -o tb_opt +acc=arn
ifeq ($(waves),1)
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)
	vsim -c -assertdebug -msgmode both -lib ./work tb_opt +UVM_TESTNAME=$(test_name) +DATA_PATTERN=$(data_pattern_seq) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) +UVM_VERBOSITY=$(verbosity) +SCOREBOARD_ENABLE=$(scoreboard) -sv_seed $(SEED) -l $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/$(directory)_$(speed)_$(SEED).log -do "add wave -r /*; $(if $(filter 1,$(coverage)),coverage save -onexit $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/coverage_for_$(directory)_$(speed)_$(SEED).ucdb;)run -all"
else
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)
	vsim -c -assertdebug -msgmode both -lib ./work tb_opt +UVM_TESTNAME=$(test_name) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) +UVM_VERBOSITY=$(verbosity) +SCOREBOARD_ENABLE=$(scoreboard) -sv_seed $(SEED) -l $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/$(directory)_$(speed)_$(SEED).log -do "$(if $(filter 1,$(coverage)),coverage save -onexit $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/coverage_for_$(directory)_$(speed)_$(SEED).ucdb;)run -all"
endif
ifeq ($(coverage),1)
	mkdir -p $(sim_dir)$(log)merge_coverage_report
	vcover merge -out $(sim_dir)$(log)merge_coverage_report/merged.ucdb $(sim_dir)$(log)merge_coverage_report/merged.ucdb $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/coverage_for_$(directory)_$(speed)_$(SEED).ucdb
	vcover report -html -htmldir $(sim_dir)$(log)merged_coverage_report/ $(sim_dir)$(log)merge_coverage_report/merged.ucdb
endif

move:
ifeq ($(waves),1)
	@echo "Using random seed: $(SEED)"
	@mv $(wlf) $(sim_dir)/$(log)/$(directory)_$(speed)_$(SEED)/$(directory)_$(speed)_$(SEED).wlf
endif

clean:
	@rm -rf $(work)

# cleaning particular log	
clean_log:
	@rm -rf $(sim_dir)$(log)$(directory)_$(SEED)

# cleaning all log
clean_all_log:
	@rm -rf $(sim_dir)$(log)/*

regression:
	@DATE_TIME=$$(date +%Y-%m-%d_%H-%M-%S); \
	REG_DIR=$(sim_dir_home)$(log)regression_$${DATE_TIME}; \
	SIM_ABS=$(sim_dir_home); \
	mkdir -p $${REG_DIR}/build/work; \
	cd $${REG_DIR}/build || { echo "Error: Cannot cd to $${REG_DIR}/build"; exit 1; }; \
	vlog -work $${REG_DIR}/build/work -O0 +fcover +acc -cover bcst $(PATH_ABS) || { echo "Error: Compilation failed"; exit 1; }; \
	vopt -work $${REG_DIR}/build/work work.$(top_module) -o tb_opt +acc=arn || { echo "Error: Optimization failed"; exit 1; }; \
	python3 $${SIM_ABS}/regression.py || { echo "Error: Failed to run regression.py"; exit 1; }; \
	if [ ! -f $${SIM_ABS}/run_commands.sh ]; then echo "Error: $${SIM_ABS}/run_commands.sh not found"; exit 1; fi; \
	while read -r line; do \
	  testname=$$(echo "$$line" | sed -E 's/.*\+UVM_TESTNAME=([^ ]+).*/\1/'); \
	  speed=$$(echo "$$line" | sed -E 's/.*\+SPEED=([^ ]+).*/\1/'); \
	  seed=$$(echo "$$line" | sed -E 's/.*-sv_seed ([^ ]+).*/\1/'); \
	  mkdir -p $${REG_DIR}/$${testname}_$${speed}_$${seed}; \
	  cd $${REG_DIR}/$${testname}_$${speed}_$${seed} || { echo "Error: Cannot cd to $${REG_DIR}/$${testname}_$${speed}_$${seed}"; exit 1; }; \
	  new_cmd=$$(echo "$$line" | sed 's/work\.tb_opt/tb_opt/'); \
	  new_cmd="$$new_cmd -lib $${REG_DIR}/build/work -wlf $${REG_DIR}/$${testname}_$${speed}_$${seed}/$${testname}_$${speed}_$${seed}.wlf"; \
	  eval $$new_cmd || { echo "Error: Simulation failed for $${testname}_$${speed}_$${seed}"; exit 1; }; \
	done < $${SIM_ABS}/run_commands.sh; \
	ucdb_files=$$(find $${REG_DIR} -name 'coverage_for_*.ucdb' 2>/dev/null); \
	if [ -n "$$ucdb_files" ]; then \
	  mkdir -p $${REG_DIR}/merge_coverage_report; \
	  mkdir -p $${REG_DIR}/merge_html_report; \
	  vcover merge -out $${REG_DIR}/merge_coverage_report/merged.ucdb $$ucdb_files; \
	  vcover report -html -output $${REG_DIR}/merge_html_report/ $${REG_DIR}/merge_coverage_report/merged.ucdb; \
	fi; \
	summary_report=$${REG_DIR}/summary_report.txt; \
	echo "Regression Summary Report" > $${summary_report}; \
	echo "Generated on: $${DATE_TIME}" >> $${summary_report}; \
	echo "------------------------" >> $${summary_report}; \
	total_tests=0; \
	passed_tests=0; \
	failed_tests=0; \
	while read -r line; do \
	  testname=$$(echo "$$line" | sed -E 's/.*\+UVM_TESTNAME=([^ ]+).*/\1/'); \
	  speed=$$(echo "$$line" | sed -E 's/.*\+SPEED=([^ ]+).*/\1/'); \
	  seed=$$(echo "$$line" | sed -E 's/.*-sv_seed ([^ ]+).*/\1/'); \
	  log_file=$${REG_DIR}/$${testname}_$${speed}_$${seed}/$${testname}_$${speed}_$${seed}.log; \
	  if [ -f "$$log_file" ]; then \
	    if grep -E "Testcase Failed" "$$log_file" > /dev/null; then \
	      echo "$${testname}_$${speed}_$${seed}: failed" >> $${summary_report}; \
	      failed_tests=$$((failed_tests + 1)); \
	    else \
	      echo "$${testname}_$${speed}_$${seed}: passed" >> $${summary_report}; \
	      passed_tests=$$((passed_tests + 1)); \
	    fi; \
	    total_tests=$$((total_tests + 1)); \
	  else \
	    echo "$${testname}_$${speed}_$${seed}: failed (log file not found)" >> $${summary_report}; \
	    failed_tests=$$((failed_tests + 1)); \
	    total_tests=$$((total_tests + 1)); \
	  fi; \
	done < $${SIM_ABS}/run_commands.sh; \
	echo "------------------------" >> $${summary_report}; \
	echo "Total Test Cases: $$total_tests" >> $${summary_report}; \
	echo "Passed: $$passed_tests" >> $${summary_report}; \
	echo "Failed: $$failed_tests" >> $${summary_report}; \
	echo "Summary report generated at: $${summary_report}"

