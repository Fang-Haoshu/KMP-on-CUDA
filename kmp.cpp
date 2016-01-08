#include <iostream>
#include <cstring>
#include <fstream>
#include <time.h>
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
void KMP(char* pattern, char* target,int f[], int c[])
{
    int m = strlen(pattern);
    int n = strlen(target);
         
    int i = 0;
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
                    c[i-m] = i-m;
                     i = i - k + 1;

                }
        }
        else
            k = f[k];
    }
    return ;
}
 
int main(int argc, char* argv[])
{
    const int L = 40000000;
    const int S = 40000000;
    ifstream f1;
    ofstream fout;
    f1.open(argv[1]);
    fout.open("output.txt");
    int cSize = 4;//size of char is 1, but size of 'a' is 4

    char *tar;
    char *pat; 
    tar = new char[L];
    pat = new char[S];
    
    f1>>tar>>pat;

    int m = strlen(tar);
    int n = strlen(pat);
    printf("%d %d\n",m,n);
    int *f;
    int *c;
    f = new int[m];
    c = new int[m];
    for(int i = 0;i<m; i++)
    {
        c[i] = -1;
    }     

    clock_t start,end;
    start = clock();

    preKMP(pat, f);
    KMP(pat, tar,f,c);
    
    end = clock();
    printf("----String matching done---- Takes %f ms\n", (end - start) );  

    for(int i = 0;i<m; i++)
    { 
        if(c[i]!=-1)
        {

            fout<<i<<' '<<c[i]<<'\n';
        }
    }

    return 0;
}