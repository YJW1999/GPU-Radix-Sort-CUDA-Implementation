#include <algorithm>
#include <chrono>
#include <execution>
#include <vector>
#include <iostream>

//#include "Kernel.cu"

extern "C" void Kernel(std::vector<int> &input_v);

void cpu_single_thread_sort(std::vector<int> &v) {
    std::sort(v.begin(), v.end(), std::greater<int>());
}

void cpu_multi_threads_sort(std::vector<int>& v) {
    std::sort(std::execution::par, v.begin(), v.end(), std::greater<int>());
}

int main() {
    
    // data setup
    std::vector<int> v;
    std::vector<int> v1;
    std::vector<int> v2;

    for (int i = 0; i < 1000000; ++i) {
        v.emplace_back(rand());
    }
    v1 = v;
    v2 = v;

    //single_thread cpu test
    std::chrono::high_resolution_clock::time_point start = std::chrono::high_resolution_clock::now();
    cpu_single_thread_sort(v);
    std::chrono::high_resolution_clock::time_point end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> dura = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << "execution time for single_threads CPU" << dura.count() << std::endl;

    //multi_threads cpu test
    start = std::chrono::high_resolution_clock::now();
    cpu_multi_threads_sort(v1);
    end = std::chrono::high_resolution_clock::now();
    dura = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << "execution time for multi_threads CPU" << dura.count() << std::endl;

    //GPU test
    /*std::cout << "unsorted List" << std::endl;
    for (auto it = v2.begin(); it != v2.end(); ++it) {
        std::cout << *it << std::endl;
    }*/
    
    Kernel(v2);
    //std::cout << "execution time for GPU" << dura.count() << std::endl;
    
    //Store data back to main memory
   
    std::cout << "sorted List" << std::endl;
    for (auto it = v2.begin(); it != v2.end(); ++it) {
        std::cout << *it << std::endl;
    }


    return 0;
}