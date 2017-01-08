# A Fast Implementation of Spectral Clustering on GPU-CPU Platforms

## Introduction
##

This software package provides a fast implementation of spectral clustering on GPU and CPU platforms. 

This work is published on IPDPS 2016 workshop titled as "A high performance implementation of spectral clustering on CPU-GPU platforms" authored by Yu Jin and Joseph F. JaJa. 

If you use the software in your applications, please cite the paper as


@inproceedings{jin2016,  
  title={A high performance implementation of spectral clustering on cpu-gpu platforms},  
  author={Jin, Yu and Jaja, Joseph F},  
  booktitle={Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International},  
  pages={825--834},  
  year={2016},  
  organization={IEEE}  
}



Spectral clustering is one of the most popular clustering algorithms for finding structural communities in graphs. However, the running time of the algorithm is usually quite long as it involves very expensive numerical operations, i.e. finding the smallest few eigenvectors of a real symmetric matrix. 

In this package, we provides a fast implementation of the spectral clustering algorithm which is significantly faster than using other CPU-based software packages such as Matlab and Python. As far as we know, our implementation is also the fastest implementation available in the open source community. 

The implementation contains three parts:

- Normalize the edge weights by the inverse of the corresponding node degrees.
- Computet the first k eigenvectors of the normalized Laplacian matrix based on arpackpp package and CUDA libraries.
- Apply k-means algorithm on rows of the k eigenvectors. The implementation of k-means algorithm is originally developed by Bran Catanzaro at https://github.com/bryancatanzaro/kmeans

Each part can be easily divided for individual functional usage. 

If you have trouble working with the software package, please contact Yu Jin (yuj AT umd.edu).


## Installation
### CUDA Environment Setup
CUDA libraries, such as CUSPARSE, CUBLAS and Thrust are pre-installed. 

### arpackpp installation
Check out ARPACK++ package from https://github.com/yuj-umd/arpackpp

```
$ git clone https://github.com/yuj-umd/arpackpp.git
$ cd arpackpp
```

Install the libraries

```
$ ./install-openblas.sh
$ ./install-arpack-ng.sh
$ ./install-superlu.sh
$ ./install-suitesparse.sh

```
Change the directory and library path in Makefile.inc, as instructed in Makefile_example.inc.

### fastsc installation
Check out the code from https://github.com/yuj-umd/fastsc

```
$ git clone https://github.com/yuj-umd/fastsc.git
$ cd fastsc
```
Modify the arpack library path and cuda architecture in Makefile.

Compile and run the program
```
$ make
$ ./spectral_clustering input_file_name n k output_file_name
```

## Usage
The program format is 
```
$ ./spectral_clustering input_file_name n k output_file_name
```

The input file contains the graph information represented as edge list. By default, the program supports unweighted graphs where each row contains two node indices. It is easy to adapt the code for weighted graphs and other graph representations. 

n is the total number of nodes and k is the desired number of clusters. The graph nodes are indexed from 0 to n-1 and there are NO isolated nodes.

output file will contain the node ID and the corresponding label.

Two input examples are contained in Dataset folder.

## Matlab and Python Benchmarks
The Benchmark folder contains Matlab code with the same function. Our implementation is faster than the naive Matlab implementation especially for large-scale problems. 


## Reference
Jin, Yu, and Joseph F. Jaja. "A high performance implementation of spectral clustering on cpu-gpu platforms." Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International. IEEE, 2016.
