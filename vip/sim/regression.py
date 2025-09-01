import os
import random
import shlex

# Input and output files
input_file = "/home/vandan-parekh/Downloads/uvm_examples/single_component_project_serdes/vip/sim/testlist.sv"
output_file = "/home/vandan-parekh/Downloads/uvm_examples/single_component_project_serdes/vip/sim/run_commands.sh"

with open(input_file, "r") as f:
    lines = f.readlines()

with open(output_file, "w") as f:
    for line in lines:
        line = line.strip()
        if not line or line.startswith("//"):  # skip empty or commented lines
            continue

        # Split using shlex to respect quotes
        args = shlex.split(line)

        if len(args) < 5:
            print(f"Skipping malformed line (not enough args): {line}")
            continue

        testname   = args[0]
        repeat_cnt = int(args[1])
        seed_arg   = args[2]
        coverage_arg = args[3]
        plusargs   = args[4]  # full string inside quotes

        try:
            speed      = plusargs.split("SPEED=")[1].split()[0]
            parallel   = plusargs.split("PARALLEL_TRANSACTION_COUNT=")[1].split()[0]
            serial     = plusargs.split("SERIAL_TRANSACTION_COUNT=")[1].split()[0]
            scoreboard = plusargs.split("SCOREBOARD_ENABLE=")[1].split()[0]
            
            # Extract DATA_PATTERN only for serdes_data_pattern_test
            data_pattern = None
            if testname == "serdes_data_pattern_test":
                try:
                    data_pattern = plusargs.split("DATA_PATTERN=")[1].split()[0]
                except IndexError:
                    print(f"Warning: DATA_PATTERN not found for {testname}, defaulting to RANDOM")
                    data_pattern = "RANDOM"
        except IndexError:
            print(f"Skipping malformed plusargs: {plusargs}")
            continue

        for i in range(repeat_cnt):
            seed = str(random.randint(1, 999999)) if seed_arg == "0" else "1234"

            cmd = (
                f"vsim -c -assertdebug -msgmode both work.tb_opt "
                f"+UVM_TESTNAME={testname} "
                f"+SPEED={speed} "
                f"+SERIAL_TRANSACTION_COUNT={serial} "
                f"+PARALLEL_TRANSACTION_COUNT={parallel} "
                f"+SCOREBOARD_ENABLE={scoreboard} "
            )

            # Add DATA_PATTERN to the command only for serdes_data_pattern_test
            if testname == "serdes_data_pattern_test" and data_pattern:
                cmd += f"+DATA_PATTERN={data_pattern} "

            cmd += (
                f"-sv_seed {seed} "
                f"-l $(sim_dir)$(log){testname}_{speed}_{seed}.log "
            )

            if coverage_arg == "1":
                cmd += (
                    f"-cvgperinstance "
                    f"-do \"add wave -r /*; coverage save -onexit coverage_for_{testname}_{speed}_{seed}.ucdb;run -all\""
                )
            else:
                cmd += f"-do \"add wave -r /*; run -all\""

            f.write(cmd + "\n")

print(f"Run commands generated in {output_file}")
