# Parallel Spectral Clustering on GPU-CPU Platforms

## Introduction
##

This software package provides a fast implementation of spectral clustering on GPU and CPU platforms. This work is published on IPDPS 2016 PCO workshop titled as "A high performance implementation of spectral clustering on cpu-gpu platforms" authored by Yu Jin and Joseph F. JaJa. If you use the software in your applications, please cite the paper as,

*
@inproceedings{jin2016,  
  title={A high performance implementation of spectral clustering on cpu-gpu platforms},  
  author={Jin, Yu and Jaja, Joseph F},  
  booktitle={Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International},  
  pages={825--834},  
  year={2016},  
  organization={IEEE}  
}
*

Spectral clustering is one of the most clustering algorithms that can find . However, the algorithm involves finding the smallest 
is computationally expensive  Our implementation modifies the traditional eigensolver, ARPACK, 
The implementation is primarily based on the ARPACK++ eigensolver and the k-means 

The package contains the following,



## Installation
### CUDA Environment Setup
CUDA 

### ARPACKpp installation
First download ARPACK++ package from https://github.com/m-reuter/arpackpp

```
$ cd arpackpp
```
Install the libraries

```
$ ./install-openblas.sh
$ ./install-arpack-ng.sh
$ ./install-superlu.sh
$ ./install-suitesparse.sh

```

## Usage


## Datasets


## Matlab and Python Benchmarks

## Reference
Jin, Yu, and Joseph F. Jaja. "A high performance implementation of spectral clustering on cpu-gpu platforms." Parallel and Distributed Processing Symposium Workshops, 2016 IEEE International. IEEE, 2016.
