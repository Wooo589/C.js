#include <stdio.h>
#include <math.h>

double __arg[32];

int x = 0;
double t1 = 0.0;
int y = 0;

int main(){
  x = 10.000000;
  __arg[0] = 10.000000;
  __arg[1] = 5.000000;
  t1 = calcular();
  y = t1;
  return 0;
}
