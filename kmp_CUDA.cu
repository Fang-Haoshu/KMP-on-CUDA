#include <iostream>
#include <cstring>
#include <fstream>
#include "time.h"

using namespace std;

void preKMP(char* pattern, int f[])
{
    int m = strlen(pattern), k;
    f[0] = -1;
    for (int i = 1; i < m; i++)
    {
        k = f[i - 1];
        while (k >= 0)
        {
            if (pattern[k] == pattern[i - 1])
                break;
            else
                k = f[k];
        }
        f[i] = k + 1;
    }
}
 
//check whether target string contains pattern 
__global__ void KMP(char* pattern, char* target,int f[],int c[],int n, int m)
{
    int index = blockIdx.x*blockDim.x + threadIdx.x;
    int i = n * index;
    int j = n * (index + 2)-1;
    if(i>m)
        return;
    if(j>m)
        j=m;
    int k = 0;        
    while (i < j)
    {
        if (k == -1)
        {
            i++;
            k = 0;
        }
        else if (target[i] == pattern[k])
        {
            i++;
            k++;
            if (k == n)
            {
                c[i - n] = i-n;
                i = i - k + 1;
            }
        }
        else
            k = f[k];
    }
    return;
}
 
int main(int argc, char* argv[])
{
    const int L = 40000000;
    const int S = 40000000;
    int M = 1024;//num of threads

    int cSize = 4;//size of char is 1, but size of 'a' is 4

    char *tar;
    char *pat;
    tar = (char*)malloc(L*cSize);
    pat = (char*)malloc(S*cSize);
    char *d_tar;
    char *d_pat;
    ifstream f1;
    ofstream f2;

    f1.open(argv[1]);
    f2.open("output.txt");

    f1>>tar>>pat;

    int m = strlen(tar);
    int n = strlen(pat);
    printf("%d %d\n",m,n);
    int *f;
    int *c;

    f = new int[m];
    c = new int[m];

    int *d_f;
    int *d_c;
    for(int i = 0;i<m; i++)
    {
        c[i] = -1;
    }     
    preKMP(pat, f);
    printf("----Start copying data to GPU----\n");
    time_t rawtime1;
    time ( &rawtime1 );
    cudaMalloc((void **)&d_tar, m*cSize);
    cudaMalloc((void **)&d_pat, n*cSize);
    cudaMalloc((void **)&d_f, m*cSize);
    cudaMalloc((void **)&d_c, m*cSize);

    cudaMemcpy(d_tar, tar, m*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pat, pat, n*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_f, f, m*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, m*cSize, cudaMemcpyHostToDevice);
    time_t rawtime2;
    time ( &rawtime2 );
    printf("----Data copied to GPU successfully---- Takes %f seconds\n", difftime(rawtime2,rawtime1));
    if(n>10000000)
        M = 128;

//使用event计算时间
    float time_elapsed=0;
    cudaEvent_t start,stop;
    cudaEventCreate(&start);    //创建Event
    cudaEventCreate(&stop);

    cudaEventRecord( start,0);    //记录当前时间
    KMP<<<(m/n+M)/M,M>>>(d_pat, d_tar ,d_f, d_c, n, m);
    cudaEventRecord( stop,0);    //记录当前时间
 
    cudaEventSynchronize(start);    //Waits for an event to complete.
    cudaEventSynchronize(stop);    //Waits for an event to complete.Record之前的任务
    cudaEventElapsedTime(&time_elapsed,start,stop);    //计算时间差


    printf("----String matching done---- Takes %f s\n", time_elapsed/1000);  
    
    cudaMemcpy(c, d_c, m*cSize, cudaMemcpyDeviceToHost);

    for(int i = 0;i<m; i++)
    { 
        if(c[i]!=-1)
        {
            f2<<i<<' '<<c[i]<<'\n';
        }
    }
    time_t rawtime4;
    time ( &rawtime4 );
    printf("----Task done---- Takes %f seconds in total\n", difftime(rawtime4,rawtime1));
    cudaFree(d_tar); cudaFree(d_pat); cudaFree(d_f); cudaFree(d_c);
    return 0;
}