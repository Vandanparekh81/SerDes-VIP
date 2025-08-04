path += ../sv/env/serdes_pkg.sv

sim_dir = ../sim/

log = log/

top_module = tb_top

override no_of_agents ?= 4

override test_name ?=serdes_test

override serial_transaction_count ?=1

override parallel_transaction_count ?=1

override speed ?=1

work += ../script/work

override waves ?=0

ifeq ($(waves),1)
	wlf += ./*.wlf
endif

override seed ?=100

ifeq ($(test_name),serdes_test)
	directory = serdes_test
endif

all:compile sim move

compile_with_vsim:compile sim

compile:
	@echo "compiling......"
	@vlog $(path)

sim:
	@vopt work.$(top_module) -o tb_opt +acc=arn
ifeq ($(waves),1)
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(seed)
	vsim -c -assertdebug -msgmode both work.tb_opt +UVM_TESTNAME=$(test_name) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) +NO_OF_AGENTS=$(no_of_agents) -sv_seed $(seed) -l $(sim_dir)$(log)$(directory)_$(speed)_$(seed)/$(directory)_$(speed)_$(seed).log -do "add wave -r /*; run -all"
else
	mkdir -p $(sim_dir)$(log)$(directory)_$(speed)_$(seed)
	vsim -c -assertdebug work.tb_opt +UVM_TESTNAME=$(test_name) +SPEED=$(speed) +SERIAL_TRANSACTION_COUNT=$(serial_transaction_count) +PARALLEL_TRANSACTION_COUNT=$(parallel_transaction_count) +NO_OF_AGENTS=$(no_of_agents) -sv_seed $(seed) -l $(sim_dir)$(log)$(directory)_$(speed)_$(seed)/$(directory)_$(speed)_$(seed).log -do "run -all"
endif

move:
ifeq ($(waves),1)
	@mv $(wlf) $(sim_dir)/$(log)/$(directory)_$(speed)_$(seed)/$(directory)_$(speed)_$(seed).wlf
endif

clean:
	@rm -rf $(work)

# cleaning particular log	
clean_log:
	@rm -rf $(sim_dir)$(log)$(directory)_$(seed)

#cleaning all log
clean_all_log:
	@rm -rf $(sim_dir)$(log)/*
