# GPU-Radix-Sort-CUDA-Implementation
The CUDA implementation of the GPU Radix Sort.

General Radix Sort Algorithm
Using 1 thread to set a hist, prefix_sum, and positioning. 
Using N(input_size) threads to calculate the number of hist. 

Correctness
The code can generate the same result as the std::sort() tested with 10000000 random numbers in random order

Performance
Baseline algorithm: std::sort() single thread && std::sort() multi-threads
The performance is worse than both single thread and multi-threads std::sort()

                                 10000000 numbers with random order
std::sort() single thread
std::sort() multi-threads
GPU                     

