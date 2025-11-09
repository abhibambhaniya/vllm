from vllm.benchmarks.datasets import ShareGPTDataset
from vllm.transformers_utils.tokenizer import get_tokenizer

tokenizer = get_tokenizer(
        "NousResearch/Llama-2-70b-hf",
        tokenizer_mode="auto",
        trust_remote_code=True,
    )

requests = ShareGPTDataset(
                random_seed=0,
                dataset_path="/data/users/abhimanyub/vllm_runtime_profile/benchmarks/ShareGPT_V3_unfiltered_cleaned_split.json",
                disable_shuffle=False,
            ).sample(
                tokenizer=tokenizer,
                num_requests=5000,
                output_len=None,
                request_id_prefix="",
                no_oversample=False,
                min_input_tokens=None,
            )
print('num_prefill_tokens,num_decode_tokens,num_total_tokens,pd_ratio')
for req in requests:
    num_prefill_tokens =  req.prompt_len
    num_decode_tokens =  req.expected_output_len
    num_total_tokens = num_prefill_tokens + num_decode_tokens
    pd_ratio = num_prefill_tokens / num_decode_tokens
    print(f'{num_prefill_tokens},{num_decode_tokens},{num_total_tokens},{pd_ratio}')
