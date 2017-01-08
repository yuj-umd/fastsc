#include <iostream>
#include "rsymsol.h"
#include "arrssym.h"
#include <fstream>
#include <cstdlib>
#include <cmath>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>
#include <thrust/functional.h>
#include "cusparse.h"
#include "cuda_runtime.h"
#include <vector>
#include "timer.h"
#include "kmeans.h"

using namespace std;

int CUDA_MULT(float *x, float *y, cusparseHandle_t& handle, cusparseStatus_t& status, cusparseMatDescr_t& descr, int n, int nnz, thrust::device_vector<int>& csrRowPtr, thrust::device_vector<int>& cooColIndex, thrust::device_vector<float>& cooVal, thrust::device_vector<float>& tmpx, thrust::device_vector<float>& tmpy){
	float fone = 1.0;
	float fzero = 0.0;
	cudaMemcpy(thrust::raw_pointer_cast(tmpx.data()), x, n*sizeof(float), cudaMemcpyHostToDevice);
	status = cusparseScsrmv(handle, CUSPARSE_OPERATION_NON_TRANSPOSE, 
			n, n, nnz, &fone, 
			descr, 
			thrust::raw_pointer_cast(cooVal.data()), 
			thrust::raw_pointer_cast(csrRowPtr.data()) , thrust::raw_pointer_cast(cooColIndex.data()),
			thrust::raw_pointer_cast(tmpx.data()), &fzero, 
			thrust::raw_pointer_cast(tmpy.data()));
	if (status != CUSPARSE_STATUS_SUCCESS) {
		printf("cusparseScsrmv Failed");
		return 1;
	}
	cudaMemcpy(y, thrust::raw_pointer_cast(tmpy.data()), n*sizeof(float), cudaMemcpyDeviceToHost);
	return 0;

}


void random_labels(thrust::device_vector<int>& labels, int n, int k) {
	thrust::host_vector<int> host_labels(n);
	for(int i = 0; i < n; i++) {
		host_labels[i] = rand() % k;
	}
	labels = host_labels;
}

void regular_labels(thrust::device_vector<int>& labels, int n, int k) {
	// Initialize by assigning nodes that are close in indexing order with the same label.
	thrust::host_vector<int> host_labels(n);
	int l = n/k;
	int count = 0;
	int cur = 0;
	for(int i = 0; i < n; i++) {
		host_labels[i] = cur;
		count++;
		if(count > l) {
			cur++;
			count = 0;
		}
	}
	labels = host_labels;
}

int main(int argc, char* argv[]) {
	if(argc < 5) {
		cout<<"Not enough input arguments!"<<endl;
		cout<<"The input format is: " <<endl;
		cout<<"1. Filename"<<endl;
		cout<<"2. Number of nodes n"<<endl;
		cout<<"3. Number of clusters k"<<endl;
		cout<<"4. Output labeling file"<<endl;
		exit(1);
	}
	// The graph is represented in edgelist format.
	// Each row represent the edge between <i, j>. 
	// For undirected graphs, both <i, j> and <j, i> need to be included in the file.
	// Nodes are indexed from 0 to n-1 with no isolated nodes.
	ifstream infile(argv[1]);
	if(!infile) {
		cout<<"wrong input file"<<endl;
		return;
	}   
	int n = atoi(argv[2]);
	int k = atoi(argv[3]);
	string line;
	int nnz = 0;

	// Get the number of edges
	while(getline(infile, line)) nnz++;
	thrust::host_vector<int> row(nnz), col(nnz);

	// Initialize the degree
	thrust::host_vector<float> degree(n, 0.0);

	// For unweighted graphs, edge weights are initilized to 1.0. Otherwise, revise the code to the specific graph representation.
	thrust::host_vector<float> val(nnz, 1.0);
	infile.close();
	infile.open(argv[1]);
	cout<<"Start loading data..."<<endl;
	for(int i = 0; i < nnz; ++i) {
		infile>>row[i]>>col[i];
		if (row[i] >= n || col[i] >= n) {
			cout<<"Index exceed the dimension. Please check the right number of nodes"<<endl;
			exit(1);
		}
		// If the input graph is weighted, change it to
		//infile>>row[i]>>col[i]>>val[i];
		degree[row[i]] = degree[row[i]] + val[i];
	}
	infile.close();
	cout<<"Loading data completed!"<<endl;

	cout<<"Start computing normalized Graph Laplacian..."<<endl;
	for(int i = 0; i < n; ++i) {
		if (degree[i] < 1e-8) {
			cout<<"Node " <<i<<" is an isolated node"<<endl;
			cout<<"Please eliminate isolated nodes and try again!"<<endl;
			exit(1);
		}
	}
	thrust::host_vector<float> degree_sqrt(n);

	// Normlize the edge weight of <i, j> by 1.0/sqrt(degree[i] * degree[j])
	for(int i = 0; i < n; ++i) {
		degree_sqrt[i] = sqrt(degree[i]);
	}

	for(int i = 0; i < nnz; ++i) {
		val[i] = val[i] / (degree_sqrt[col[i]] * degree_sqrt[row[i]]);
	}

	cout<<"Computing normalized Graph Laplacian completed"<<endl;
	cout<<"Start computing the first smallest k eigenvectors..."<<endl;
	thrust::device_vector<int> cooRowIndex = row;
	thrust::device_vector<int> cooColIndex = col;
	thrust::device_vector<float> cooVal = val;
	cusparseStatus_t status;
	cusparseHandle_t handle=0;
	cusparseMatDescr_t descr=0;
	status= cusparseCreate(&handle);
	status= cusparseCreateMatDescr(&descr);
	if (status != CUSPARSE_STATUS_SUCCESS) {
		printf("Matrix descriptor initialization failed");
		return 1;
	}
	cusparseSetMatType(descr,CUSPARSE_MATRIX_TYPE_GENERAL);
	cusparseSetMatIndexBase(descr,CUSPARSE_INDEX_BASE_ZERO);
	thrust::device_vector<int> csrRowPtr(n+1);

	status= cusparseXcoo2csr(handle,thrust::raw_pointer_cast(cooRowIndex.data()),nnz,n,
			thrust::raw_pointer_cast(csrRowPtr.data()),CUSPARSE_INDEX_BASE_ZERO);
	if (status != CUSPARSE_STATUS_SUCCESS) {
		printf("Conversion from COO to CSR format failed");
		return 1;
	}
	thrust::device_vector<float> tmpx(n);
	thrust::device_vector<float> tmpy(n);
	ARrcSymStdEig<float> prob(n, k, "LM");
	while (!prob.ArnoldiBasisFound()) {
		prob.TakeStep();
		if ((prob.GetIdo() == 1)||(prob.GetIdo() == -1)) {
			CUDA_MULT(prob.GetVector(), prob.PutVector(), handle, status, descr, n, nnz, csrRowPtr, cooColIndex, cooVal, tmpx, tmpy);
		}
	}

	// Finding eigenvalues and eigenvectors.
	prob.FindEigenvectors();
	// Printing eigenvalue solution.
	// Solution(prob);

	cout<<"Completed computing the first smallest k eigenvectors!"<<endl;

	// Extract eigenvectors. 
	// Rearrange the order such that values between i * k and (i+1)*k-1 are eigenmap for node indexed by i
	cout<<"Start kmeans clustering algorithm on the k eigenvectors..."<<endl;
	thrust::host_vector<float> eigenvectors_h(n*k);
	for (int i = 0; i < n; ++i) {
		for (int j = 0; j < k; ++j) {
			eigenvectors_h[i*k + j] = prob.Eigenvector(j, i);
		}
	}

	//Apply K-means algorithm on the eigenvectors
	int iterations = 100;
	// The dimension of each point is equal to the number of desired clusters.
	int d = k; 
	thrust::device_vector<float> eigenvectors_d = eigenvectors_h; 
	thrust::device_vector<int> labels(n);
	thrust::device_vector<float> centroids(k * d); 
	thrust::device_vector<float> distances(n);
	// Randomly initialize the labels. (You can also try the regular_labels)
	random_labels(labels, n, k);
	kmeans::kmeans(iterations, n, d, k, eigenvectors_d, labels, centroids, distances);
	cout<<"Completed kmeans clustering algorithm on the k eigenvectors!"<<endl;
	cout<<"Start output clustering results..."<<endl;
	ofstream outfile(argv[4]);
	outfile<<"Node ID" <<' ' <<"Label"<<endl;
	for(int i = 0; i < n; ++i){ 
		outfile<<i<<' '<<labels[i]<<endl;
	} 
	outfile.close();
	cout<<"Completed output clustering results!"<<endl;
	return 0;
}
