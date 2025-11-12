import json
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

with open("/home/abhimanyub/openai-5.0qps-Hermes-4-70B-20251112-105740.json", "r") as json_file:
    json_data = json.load(json_file)

json_data_df = pd.json_normalize(json_data)
json_data_df['tpot'] = json_data_df['itls'].apply(lambda x: [np.mean(values) for values in x])
json_data_df.head()

request_metrics_df = pd.read_csv("/home/abhimanyub/request_metrics.csv")
request_metrics_df.head()

fig, axes = plt.subplots(1, 2, figsize=(20, 5), facecolor='white')

vLLM_TTFT = json_data_df['ttfts'][0]
vidur_TTFT = request_metrics_df['prefill_e2e_time']
axes[0].plot(range(len(vLLM_TTFT)), vLLM_TTFT, label='vLLM')
axes[0].plot(range(len(vidur_TTFT)), vidur_TTFT, label='vidur')
axes[0].set_title('TTFT')
axes[0].set_xlabel('Request Idx')
axes[0].set_ylabel('Latency (ms)')
axes[0].legend()
axes[0].grid(True)

# vLLM_TPOT = json_data_df['tpot'][0]
# axes[1].plot(range(len(vLLM_TPOT)), vLLM_TPOT, label='vLLM')
# axes[1].set_title('TPOT')
# axes[1].set_xlabel('Request Idx')
# axes[1].set_ylabel('Latency (ms)')
# axes[1].legend()
# axes[1].grid(True)

vLLM_e2el = json_data_df['e2el'][0]
vidur_e2el = request_metrics_df['request_e2e_time']
axes[1].plot(range(len(vLLM_e2el)), vLLM_e2el, label='vLLM')
axes[1].plot(range(len(vidur_e2el)), vidur_e2el, label='vidur', alpha=0.5)
axes[1].set_title('End 2 End Latency')
axes[1].set_xlabel('Request Idx')
axes[1].set_ylabel('Latency (ms)')
axes[1].legend()
axes[1].grid(True)

plt.tight_layout()
plt.show()

import matplotlib.pyplot as plt

plt.figure(figsize=(10, 6))

vLLM_e2el = sorted(json_data_df['e2el'][0])
vidur_e2el = sorted(request_metrics_df['request_e2e_time'])

plt.plot(range(len(vLLM_e2el)), vLLM_e2el, label='vLLM')
plt.plot(range(len(vidur_e2el)), vidur_e2el, label='vidur', alpha=0.5)
plt.title('End 2 End Latency (Sorted)')
plt.xlabel('Request Idx')
plt.ylabel('Latency (ms)')
plt.legend()
plt.grid(True)

plt.show()
