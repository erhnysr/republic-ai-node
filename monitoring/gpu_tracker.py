#!/usr/bin/env python3
import subprocess
import json
import time
from datetime import datetime

def get_gpu_stats():
    try:
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu', '--format=csv,noheader,nounits'],
            capture_output=True, text=True
        )
        gpu_util, mem_used, mem_total, temp = result.stdout.strip().split(', ')
        return {
            'utilization': float(gpu_util),
            'memory_used': float(mem_used),
            'memory_total': float(mem_total),
            'temperature': float(temp)
        }
    except:
        return None

def main():
    print("🚀 Republic AI - GPU Tracker")
    while True:
        gpu = get_gpu_stats()
        if gpu:
            print(f"GPU: {gpu['utilization']}% | Mem: {gpu['memory_used']}/{gpu['memory_total']} MB | Temp: {gpu['temperature']}°C")
        time.sleep(10)

if __name__ == '__main__':
    main()
