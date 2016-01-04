#include <iostream>
#include <cstring>
#include <fstream>

using namespace std;

 
//check whether target string contains pattern 
__global__ void strMatch(char* pattern, char* target,int c[],int n, int m)
{
    int index = blockIdx.x*blockDim.x + threadIdx.x;
    if(index > m-n)
        return;
    int i = index;
    int k = 0;        
    while (k < n)
    {
        if (pattern[k] == target[i+k])
        {
            k++;
        }
        else
           return;
    }
    c[i] = i;
    return;
}
 
int main(int argc, char* argv[])
{
    const int L = 40000000;
    const int S = 40000000;
    const int N = 40000;// num of blocks
    const int M = 1024;//num of threads

    int cSize = 4;//size of char is 1, but size of 'a' is 4

    char *tar;
    char *pat;
    tar = (char*)malloc(L*cSize);
    pat = (char*)malloc(S*cSize);

    ifstream f1;
    ofstream f2;

    f1.open(argv[1]);
    f2.open("output.txt");

    f1>>tar>>pat;

    int m = strlen(tar);
    int n = strlen(pat);
    int *c;
    c = new int[m];
    for(int i = 0;i<m; i++)
    {
        c[i] = -1;
    }   

    char *d_tar;
    char *d_pat;
    int *d_c;

    cudaMalloc((void **)&d_tar, m*cSize);
    cudaMalloc((void **)&d_pat, n*cSize);
    cudaMalloc((void **)&d_c, m*cSize);

    cudaMemcpy(d_tar, tar, m*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pat, pat, n*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, m*cSize, cudaMemcpyHostToDevice);

    strMatch<<<(m+M-1)/M,M>>>(d_pat, d_tar , d_c, n, m);

    cudaMemcpy(c, d_c, m*cSize, cudaMemcpyDeviceToHost);

    for(int i = 0;i<m; i++)
    { 
        if(c[i]!=-1)
        {
            f2<<i<<' '<<c[i]<<'\n';
        }
    }

    cudaFree(d_tar); cudaFree(d_pat);  cudaFree(d_c);
    return 0;
}