#include <iostream>
#include <cstring>
#include <fstream>
using namespace std;
void preKMP(string pattern, int f[])
{
    int m = pattern.length(), k;
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
bool KMP(string pattern, string target,int f[])
{
    int m = pattern.length();
    int n = target.length();
         
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
                return 1;
        }
        else
            k = f[k];
    }
    return 0;
}
 
int main(int argc, char* argv[])
{
    ifstream f1,f2;
    f1.open(argv[0]);
    fout.open(argv[1]);
    string tar,pat;
    f1>>tar>>pat;
    

    int m = pat.length();
    int f[m];     
    preKMP(pat, f);

    if (KMP(pat, tar,f))
        fout<<"'"<<pat<<"' found in string '"<<tar<<"'"<<endl;
    else
        fout<<"'"<<pat<<"' not found in string '"<<tar<<"'"<<endl;

    return 0;
}