#include <iostream>
#include <cstring>
#include <fstream>

using namespace std;

 
//check whether target string contains pattern 
void strMatch(char* pattern, char* target,int c[],int n, int m)
{
    for(int i = 0;i<m-n;i++)
    {
    int k = 0;        
    while (k < n)
    {
        if (pattern[k] == target[i+k])
        {
            k++;
        }
        else
           continue;
    }
    c[i] = i;
    }
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
    tar = new char[L];
    pat = new char[S];

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

    clock_t start,end;
    start = clock();
    strMatch(pat, tar,c, n, m);
    end = clock();

    printf("----String matching done---- Takes %f s\n", (end - start)/1000);  

    for(int i = 0;i<m; i++)
    { 
        if(c[i]!=-1)
        {
            f2<<i<<' '<<c[i]<<'\n';
        }
    }
    
    return 0;
}