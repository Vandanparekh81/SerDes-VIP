import subprocess
import os
import yaml
import html
import time
import argparse
import shutil
import glob

# Configuration (mirroring Makefile structure)
CONFIG = {
    "paths": {
        "source": [
            "../sv/env/serdes_pkg.sv",
        ],
        "sim_dir": "../sim",
        "log_dir": "log/",
        "work_dir": "../script/work",
        "uvm_path": "/home/vandan-parekh/Downloads/Mentor_Graphics_QuestaSim_2021.2.1/installation/questasim/uvm-1.2/verilog_src/uvm-1.2/src"
    },
    "simulation": {
        "top_module": "tb_top",
        "test": {
            "name": "serdes_test",
            "serial_transaction_count": 1,
            "parallel_transaction_count": 1,
            "speed": 1,
            "no_of_agents": 4
        },
        "waves": {
            "enabled": False,
            "file": "*.wlf"
        },
        "seed": 100
    },
    "directories": {
        "serdes_test": "serdes_test"
    }
}

def run_command(command, description):
    """Execute a shell command and print its description."""
    print(f"{description}...")
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        exit(1)

def compile_task():
    """Execute the compile task with UVM compilation first."""
    # Step 1: Compile UVM source files
    uvm_files = glob.glob(f"{CONFIG['paths']['uvm_path']}/*.sv")
    uvm_files_str = " ".join(uvm_files)
    if uvm_files_str:
        command = f"vlog -work {CONFIG['paths']['work_dir']} +incdir+{CONFIG['paths']['uvm_path']} {uvm_files_str}"
        run_command(command, "Compiling UVM source files")
    else:
        print(f"Warning: No UVM source files found in {CONFIG['paths']['uvm_path']}")

    # Step 2: Compile user source files
    files = " ".join(CONFIG['paths']['source'])
    command = f"vlog -work {CONFIG['paths']['work_dir']} +incdir+{CONFIG['paths']['uvm_path']} -cover bcst +acc {files}"
    run_command(command, "Compiling user source files")

def sim_task(test_name, serial_transaction_count, parallel_transaction_count, speed, no_of_agents, seed, waves):
    """Execute the simulation task."""
    # Create log directory
    log_dir = f"{CONFIG['paths']['sim_dir']}/{CONFIG['paths']['log_dir']}{CONFIG['directories'][test_name]}_{speed}_{seed}"
    os.makedirs(log_dir, exist_ok=True)

    # Optimization step
    command = f"vopt work.{CONFIG['simulation']['top_module']} -o tb_opt +acc=arn"
    run_command(command, "Optimizing")

    # Simulation command
    base_command = f"vsim -work {CONFIG['paths']['work_dir']} -c -assertdebug -msgmode both -coverage work.tb_opt"
    params = [
        f"+UVM_TESTNAME={test_name}",
        f"+SPEED={speed}",
        f"+SERIAL_TRANSACTION_COUNT={serial_transaction_count}",
        f"+PARALLEL_TRANSACTION_COUNT={parallel_transaction_count}",
        f"+NO_OF_AGENTS={no_of_agents}",
        f"-sv_seed {seed}",
        f"-l {log_dir}/{CONFIG['directories'][test_name]}_{speed}_{seed}.log"
    ]
    if waves:
        do_command = '"add wave -r /*; run -all"'
    else:
        do_command = '"run -all"'
    command = f"{base_command} {' '.join(params)} -do {do_command}"
    run_command(command, "Running simulation")

def move_task(seed, waves, test_name, speed):
    """Move waveform files if waves are enabled."""
    if waves:
        log_dir = f"{CONFIG['paths']['sim_dir']}/{CONFIG['paths']['log_dir']}{CONFIG['directories'][test_name]}_{speed}_{seed}"
        command = f"mv {CONFIG['simulation']['waves']['file']} {log_dir}/{CONFIG['directories'][test_name]}_{speed}_{seed}.wlf"
        run_command(command, "Moving waveform files")

def clean_task():
    """Remove work directory."""
    work_dir = CONFIG['paths']['work_dir']
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
        print("Cleaning work directory...")

def clean_log_task(test_name, seed, speed):
    """Remove specific log directory."""
    log_dir = f"{CONFIG['paths']['sim_dir']}/{CONFIG['paths']['log_dir']}{CONFIG['directories'][test_name]}_{speed}_{seed}"
    if os.path.exists(log_dir):
        shutil.rmtree(log_dir)
        print(f"Cleaning log directory {log_dir}...")

def clean_all_log_task():
    """Remove all log directories."""
    log_base_dir = f"{CONFIG['paths']['sim_dir']}/{CONFIG['paths']['log_dir']}"
    if os.path.exists(log_base_dir):
        for item in os.listdir(log_base_dir):
            item_path = os.path.join(log_base_dir, item)
            if os.path.isdir(item_path):
                shutil.rmtree(item_path)
        print("Cleaning all log directories...")

def main():
    """Main function to parse arguments and execute tasks."""
    parser = argparse.ArgumentParser(description="Simulation control script")
    parser.add_argument("--test_name", default=CONFIG['simulation']['test']['name'], help="Test name")
    parser.add_argument("--serial_transaction_count", type=int, default=CONFIG['simulation']['test']['serial_transaction_count'], help="Serial transaction count")
    parser.add_argument("--parallel_transaction_count", type=int, default=CONFIG['simulation']['test']['parallel_transaction_count'], help="Parallel transaction count")
    parser.add_argument("--speed", type=int, default=CONFIG['simulation']['test']['speed'], help="Speed")
    parser.add_argument("--no_of_agents", type=int, default=CONFIG['simulation']['test']['no_of_agents'], help="Number of agents")
    parser.add_argument("--seed", type=int, default=CONFIG['simulation']['seed'], help="Random seed")
    parser.add_argument("--waves", type=int, choices=[0, 1], default=int(CONFIG['simulation']['waves']['enabled']), help="Enable waves (0 or 1)")
    parser.add_argument("target", choices=["all", "compile_with_vsim", "compile", "sim", "move", "clean", "clean_log", "clean_all_log"], help="Target task")

    args = parser.parse_args()

    # Update directory based on test_name
    if args.test_name == "serdes_test":
        CONFIG['directories']['serdes_test'] = "serdes_test"
    else:
        CONFIG['directories'][args.test_name] = args.test_name

    # Execute tasks based on target
    if args.target == "all":
        compile_task()
        sim_task(args.test_name, args.serial_transaction_count, args.parallel_transaction_count, args.speed, args.no_of_agents, args.seed, args.waves)
        move_task(args.seed, args.waves, args.test_name, args.speed)
    elif args.target == "compile_with_vsim":
        compile_task()
        sim_task(args.test_name, args.serial_transaction_count, args.parallel_transaction_count, args.speed, args.no_of_agents, args.seed, args.waves)
    elif args.target == "compile":
        compile_task()
    elif args.target == "sim":
        sim_task(args.test_name, args.serial_transaction_count, args.parallel_transaction_count, args.speed, args.no_of_agents, args.seed, args.waves)
    elif args.target == "move":
        move_task(args.seed, args.waves, args.test_name, args.speed)
    elif args.target == "clean":
        clean_task()
    elif args.target == "clean_log":
        clean_log_task(args.test_name, args.seed, args.speed)
    elif args.target == "clean_all_log":
        clean_all_log_task()

if __name__ == "__main__":
    main()
