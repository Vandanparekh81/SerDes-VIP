path += ../sv/env/serdes_pkg.sv

sim_dir = ../sim/

log = log/

top_module = tb_top
override no_of_agents ?= 4

override test_name ?=serdes_sanity_test

override serial_transaction_count ?=1

override parallel_transaction_count ?=1

override speed ?=1

work += ../script/work

override waves ?=0

ifeq ($(waves),1)
	wlf += ./*.wlf
endif

override seed ?=random
directory = $(test_name)

ifeq ($(seed),random)
        SEED := $(shell bash -c 'echo $$RANDOM')
else
        SEED := $(seed)
endif


all:compile sim move

compile_with_vsim:compile sim

compile:
	@echo "Using random seed $(SEED)"
ifeq ($(seed),random)
	seed=$(SEED)
	@echo "Using random seed: $(seed)"
endif
	@echo "compiling......"
	@vlog -work work -O0 +fcover +acc -cover bcst $(path)

sim:
	@vopt work.$(top_module) -o tb_opt +acc=arn
ifeq ($(waves),1)
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)
	vsim -c -cvgperinstance -assertdebug -msgmode both work.tb_opt +UVM_TESTNAME=$(test_name) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) -sv_seed $(SEED) -l $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/$(directory)_$(speed)_$(SEED).log -do "add wave -r /*; coverage save -onexit coverage_for_$(directory)_$(speed)_$(SEED).ucdb;run -all"
	vcover merge -out merged.ucdb merged.ucdb coverage_for_$(directory)_$(speed)_$(SEED).ucdb
	vcover report -html -htmldir merged_html_report merged.ucdb
	#vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html coverage_for_$(directory)_$(speed)_$(SEED).ucdb
else
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)
	vsim -c -assertdebug -msgmode both work.tb_opt +UVM_TESTNAME=$(test_name) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) -sv_seed $(SEED) -l $(sim_dir)$(log)$(directory)_$(speed)_$(SEED)/$(directory)_$(speed)_$(SEED).log -do "run -all"
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

#cleaning all log
clean_all_log:
	@rm -rf $(sim_dir)$(log)/*
