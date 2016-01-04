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

    int i = m * blockIdx.x;
    int n = m * (blockIdx.x + 2)-1;
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
                c[i - m] = i-m;
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
    int *f;
    int *c;
    printf("5\n");
    f = new int[m];
    c = new int[m];
    printf("6\n");
    int *d_f;
    int *d_c;
    for(int i = 0;i<m; i++)
    {
        c[i] = -1;
    }     
    preKMP(pat, f);
    printf("6\n");
    cudaMalloc((void **)&d_tar, m*cSize);
    cudaMalloc((void **)&d_pat, n*cSize);
    cudaMalloc((void **)&d_f, m*cSize);
    cudaMalloc((void **)&d_c, m*cSize);

    cudaMemcpy(d_tar, tar, m*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_pat, pat, n*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_f, f, m*cSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, m*cSize, cudaMemcpyHostToDevice);
    printf("6\n");
    KMP<<<m/n,1>>>(d_pat, d_tar ,d_f, d_c, n);

    cudaMemcpy(c, d_c, m*cSize, cudaMemcpyDeviceToHost);

    for(int i = 0;i<m; i++)
    { 
        if(c[i]!=-1)
        {
            f2<<i<<' '<<c[i]<<'\n';
        }
    }

    cudaFree(d_tar); cudaFree(d_pat); cudaFree(d_f); cudaFree(d_c);
    return 0;
}