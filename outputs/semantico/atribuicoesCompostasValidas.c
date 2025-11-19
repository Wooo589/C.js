#include <stdio.h>
#include <math.h>

double __arg[32];

int x = 0;
double t2 = 0.0;

int main(){
  x = 10.000000;
  t2 = 10.000000 %= 3.000000;
  x = t2;
  return 0;
}
