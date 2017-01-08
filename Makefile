CUDA_CPP = nvcc
CUDA_ARCH ?= sm_35
include ../arpackpp/Makefile.inc
CUDA_FLAGS = -arch=$(CUDA_ARCH) -Xptxas -v
CUDA_LIBS = -lcublas -lcusparse

spectral_clustering: spectral_clustering.cu timer.o labels.o kmeans.h centroids.h
	$(CUDA_CPP) $(CPP_FLAGS) $(CUDA_FLAGS) -o spectral_clustering spectral_clustering.cu timer.o labels.o $(ALL_LIBS) $(CUDA_LIBS) 

labels.o: labels.cu labels.h
	$(CUDA_CPP) $(CPP_FLAGS) $(CUDA_FLAGS)  -c -o labels.o labels.cu 
	   
timer.o: timer.cu timer.h
	$(CUDA_CPP) $(CPP_FLAGS) $(CUDA_FLAGS) -c -o timer.o timer.cu
