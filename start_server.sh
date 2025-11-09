

if [ "$1" = "qwen7B" ]; then
    model_name=Qwen/Qwen2.5-7B-Instruct
    TP=1
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
    model_name=deepseek-ai/DeepSeek-R1-0528
    TP=8
elif [ "$1" = "405B" ]; then
    model_name=RedHatAI/Meta-Llama-3.1-405B-Instruct-FP8
    TP=8
fi


with-proxy vllm serve "$model_name" --load-format dummy -tp "$TP"
