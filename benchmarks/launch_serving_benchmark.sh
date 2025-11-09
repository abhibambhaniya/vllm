if [ "$1" = "qwen7B" ]; then
    model_name=Qwen/Qwen2.5-7B-Instruct
    TP=1
    download_dir="/home/abhimanyub/.cache/huggingface/hub/models--Qwen--Qwen2.5-7B-Instruct/snapshots/a09a35458c702b33eeacc393d103063234e8bc28"
elif [ "$1" = "qwen3_4B" ]; then
    model_name=Qwen/Qwen3-4B-Instruct-2507
    TP=1
elif [ "$1" = "qwen3_14B" ]; then
    model_name=Qwen/Qwen3-14B
    TP=1
elif [ "$1" = "qwen3_32B" ]; then
    model_name=Qwen/Qwen3-32B
    TP=2
elif [ "$1" = "L3_70B" ]; then
    model_name=NousResearch/Hermes-4-70B
    TP=8
elif [ "$1" = "L3_70B_TP4" ]; then
    model_name=NousResearch/Hermes-4-70B
    TP=4
elif [ "$1" = "L2_70B" ]; then
    model_name=NousResearch/Llama-2-70b-hf
    TP=8
elif [ "$1" = "L2_70B_TP4" ]; then
    model_name=NousResearch/Llama-2-70b-hf
    TP=4
elif [ "$1" = "deepseek" ]; then
    model_name="deepseek-ai/DeepSeek-R1-0528"
    TP=8
elif [ "$1" = "405B" ]; then
    model_name="RedHatAI/Meta-Llama-3.1-405B-Instruct-FP8"
    TP=8
fi

# Shift to remove the first argument if it exists
if [ $# -gt 0 ]; then
    shift
fi
# Run the command with any additional arguments passed through
vllm bench serve \
    --model "$model_name" \
    --tokenizer "$model_name" \
    --endpoint /v1/completions \
    --dataset-name sharegpt \
    --dataset-path /data/users/abhimanyub/vllm_runtime_profile/benchmarks/ShareGPT_V3_unfiltered_cleaned_split.json \
    --request-rate 10.0 \
    --ready-check-timeout-sec 5 \
    --num_prompts 2000 \
    --min-input-tokens 50
    "$@"
