#!/bin/bash

# Define functions OUTSIDE the loops (only once)
start_and_wait_for_server() {
    local model=$1

    # Redirect output and properly background
    nohup bash ./start_server.sh $model > server.log 2>&1 &
    SERVER_PID=$!

    echo "Server script started with PID: $SERVER_PID for model: $model" >&2

    # Better health check with timeout and verbose output
    echo "Waiting for server to be ready..." >&2
    MAX_WAIT=3600  # 10 minutes
    ELAPSED=0

    until curl -s -f http://localhost:8000/health > /dev/null 2>&1; do
        if [ $ELAPSED -ge $MAX_WAIT ]; then
            echo "ERROR: Server did not become healthy within ${MAX_WAIT}s" >&2
            echo "Server log:" >&2
            tail -20 server.log >&2
            kill $SERVER_PID 2>/dev/null
            return 1
        fi

        echo "Waiting... (${ELAPSED}s elapsed)" >&2
        sleep 20
        ELAPSED=$((ELAPSED + 20))
    done

    echo "Server is ready!" >&2
    echo $SERVER_PID
}

kill_gpu_processes() {
    echo "Finding GPU processes to kill..." >&2

    # Get PIDs from nvidia-smi (filter for python/server processes)
    GPU_PIDS=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader 2>/dev/null)

    if [ -z "$GPU_PIDS" ]; then
        echo "No GPU processes found via nvidia-smi" >&2
        return
    fi

    echo "Found GPU PIDs: $GPU_PIDS" >&2

    for pid in $GPU_PIDS; do
        echo "Killing GPU process: $pid" >&2
        kill -9 $pid 2>/dev/null
    done

    # Wait a moment for cleanup
    sleep 2

    # Verify all killed
    nvidia-smi >&2
}

# Model list - Fixed syntax
model_list=( "405B" )
# "qwen3_14B" "qwen3_32B" "L3_70B" "L2_70B" "L3_70B_TP4" "L2_70B_TP4" "deepseek"
# Benchmark list
benchmark_list=("launch_serving_benchmark_prefill.sh" "launch_serving_benchmark.sh")

# Outer loop: iterate over models
for model in "${model_list[@]}"; do
    echo "======================================" >&2
    echo "=== Starting benchmarks for $model ===" >&2
    echo "======================================" >&2

    # Inner loop: iterate over benchmarks
    for benchmark in "${benchmark_list[@]}"; do
        echo "=== Running $benchmark on $model ===" >&2

        SERVER_PID=$(start_and_wait_for_server $model)
        echo "Server PID: $SERVER_PID" >&2

        bash benchmarks/$benchmark $model

        echo "=== Benchmark complete, cleaning up ===" >&2

        # Kill the shell script PID and its children
        pkill -P $SERVER_PID 2>/dev/null
        kill -9 $SERVER_PID 2>/dev/null

        # Kill all GPU processes
        kill_gpu_processes

        echo "Waiting before next benchmark..." >&2
        sleep 5
    done

    echo "=== All benchmarks complete for $model ===" >&2
    echo "" >&2
done

echo "======================================" >&2
echo "=== ALL MODELS AND BENCHMARKS COMPLETE ===" >&2
echo "======================================" >&2
