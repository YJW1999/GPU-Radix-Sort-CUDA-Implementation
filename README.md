# GPU-Radix-Sort-CUDA-Implementation
The CUDA implementation of the GPU Radix Sort.

Algorithm
The Algorithm is the general way of radix sort

Using 1 thread to set a hist, prefix_sum, and positioning. 

Using N(input_size) threads to calculate the number of hist. 


Correctness

The code can generate the same result as the std::sort() tested with 10000000 random numbers in random order


Performance

Baseline algorithm: std::sort() single thread && std::sort() multi-threads

The runtime for std::sort() starts just before the funtion call of std::sort(), and ends after the function call. The runtime for GPU only counts the calculation time which excludes the transfer time from GPU memory to main memory 

The performance is worse than both single thread and multi-threads std::sort().

                                 10000000 numbers with random order(unit ms)
    std::sort() single thread                    2.13
 
    std::sort() multi-threads                    0.574

    GPU                                          5479


