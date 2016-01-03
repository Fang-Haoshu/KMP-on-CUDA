#include <iostream>
#include <cstring>
#include <fstream>

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
__global__ void KMP(char* pattern, char* target,int f[],int c[],int m)
{

    int i = 1000 * blockIdx.x;
    int n = 1000 * (blockIdx.x + 2);
    int k = 0;        
    while (i < n)
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
            if (k == m)
            {
                c[blockIdx.x] = i-m;
                return;
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
    const int S = 4000;
    const int N = 40000;// num of blocks
    char tar[L];
    char pat[S];
    char *d_tar;
    char *d_pat;
    ifstream f1;
    ofstream f2;
    f1.open(argv[0]);
    f2.open("output.txt");

    f1>>tar>>pat;

    int m = strlen(tar);
    int n = strlen(pat);
    int f[m];
    int c[N];
    int *d_f;
    int *d_c;
    for(int i = 0;i<N; i++)
    {
        c[i] = -1;
    }     
    preKMP(pat, f);

    cudaMalloc((void **)&d_tar, L);
    cudaMalloc((void **)&d_pat, S);
    cudaMalloc((void **)&d_f, m);
    cudaMalloc((void **)&d_c, N);

    cudaMemcpy(d_tar, tar, L, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pat, pat, S, cudaMemcpyHostToDevice);
    cudaMemcpy(d_f, f, m, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, N, cudaMemcpyHostToDevice);
    KMP<<<N,1>>>(d_pat, d_tar ,d_f, d_c, n);

    cudaMemcpy(c, d_c, N, cudaMemcpyDeviceToHost);

    for(int i = 0;i<N; i++)
    {
        if(c[i]!=-1)
        {
            f2<<c[i]<<'\n';
        }
    }

    cudaFree(d_tar); cudaFree(d_pat); cudaFree(d_f); cudaFree(d_c);
    return 0;
}