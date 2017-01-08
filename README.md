# A Fast Implementation of Spectral Clustering on GPU-CPU Platforms

## Introduction
##

This software package provides a fast implementation of spectral clustering on GPU and CPU platforms. This work is published on IPDPS 2016 workshop titled as "A high performance implementation of spectral clustering on cpu-gpu platforms" authored by Yu Jin and Joseph F. JaJa. 

If you use the software in your applications, please cite the paper as


@inproceedings{jin2016,  
  title={A high performance implementation of spectral clustering on cpu-gpu platforms},  
  author={Jin, Yu and Jaja, Joseph F},  
  booktitle={Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International},  
  pages={825--834},  
  year={2016},  
  organization={IEEE}  
}



Spectral clustering is one of the most clustering algorithms that can find nonconvex clusters. However, as the algorithm involves computationally expensive numerical operations, i.e. finding the smallest few eigenvectors of a real symmetric matrix, the running time in real applications is long. In this software package, we provides a fast implementation of the spectral clustering algorithm which is significantly faster than other software packages such as . As far as we know, our implementation is the fastest implementation available in the open source community. 

The implementation contains three parts:

- Construct the graph normalized Laplacian by normalizing the edge weights by the inverse of the corresponding node degrees.
- Computet the first k eigenvectors based on arpackpp package and CUDA libraries.
- Apply k-means algorithm on rows of the k eigenvectors. 

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

### Spectral clustering installation
Check out the code from https://github.com/yuj-umd/fastsc

```
$ git clone https://github.com/yuj-umd/fastsc.git
$ cd arpackpp
```

## Usage


## Datasets


## Matlab and Python Benchmarks

## Reference
Jin, Yu, and Joseph F. Jaja. "A high performance implementation of spectral clustering on cpu-gpu platforms." Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International. IEEE, 2016.
