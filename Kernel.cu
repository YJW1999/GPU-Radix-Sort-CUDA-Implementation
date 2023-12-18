#pragma once
#ifdef __INTELLISENSE__
void __syncthreads();
#endif

#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <thrust/device_vector.h>
#include <vector>
#include <iostream>
#include <chrono>

__global__ void print_arr(int* pd_vec, int n){
    if (threadIdx.x < n)
        printf("%d\n",pd_vec[threadIdx.x]);
}

__global__ void set_hist(int* hist) {
    hist[0] = 0;
    hist[1] = 0;
}

__global__ void radixSort_hist(int* d_input, int* d_output, int* hist, int size, int bit) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        int bitVal = (d_input[idx] >> bit) & 1;
        atomicAdd(&hist[bitVal], 1);
    }
    __syncthreads();
}

__global__ void radixSort_prefix_sum(int * hist) {
    int prefixsum = 0;
    for (int i = 0; i < 2; i += 1) {
        int temp = hist[i];
        hist[i] = prefixsum;
        prefixsum += temp;
    }
}

__global__ void radixSort_move(int* d_input, int* d_output, int* hist, int size, int bit) {
    for (int i = 0; i < size; i += 1) {
        int bitVal = (d_input[i] >> bit) & 1;
        int targetIdx = hist[bitVal]++;
        d_output[targetIdx] = d_input[i];
    }
}

extern "C" void Kernel(std::vector<int> &input_v) {
	int input_size = input_v.size();
	int block_size = 256;
	int num_block = input_size / block_size + 1;
 
	//cuda array pointer
    int* d_input = nullptr, * d_output = nullptr;

	//cuda memory allocation and copy memory to GPU
	cudaMalloc((void**)&d_input, sizeof(int) * input_size);
	cudaMemcpy(d_input, input_v.data(), input_size * sizeof(int), cudaMemcpyHostToDevice);
    cudaMalloc((void**)&d_output, sizeof(int) * input_size);

    //sort function call
    int* hist = nullptr;
    cudaMalloc((void**)&hist, sizeof(int) * 3);

    std::chrono::high_resolution_clock::time_point start, end;
    start = std::chrono::high_resolution_clock::now();
    for (int bit = 0; bit < 32; ++bit) {
        //reset hist
        set_hist <<<1, 1>>> (hist);
        //create hist
        radixSort_hist<<<(input_size + block_size - 1) / block_size, block_size>>> (d_input, d_output, hist, input_size, bit);
        //calculate prefix sum
        radixSort_prefix_sum <<<1,1>>> (hist);
        //move element
        radixSort_move <<<1,1>>> (d_input, d_output, hist, input_size, bit);
        //radixSort_move << <(input_size + block_size - 1) / block_size, block_size >> > (d_input, d_output, hist, input_size, bit);
        std::swap(d_input, d_output); // Swap input and output arrays for next iteration
    }
    end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << "execution time for GPU:" << duration.count() << std::endl;

    //copy data from GPU to original
    cudaMemcpy(input_v.data(), d_input, input_size * sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(hist);
}
