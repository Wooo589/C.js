#include <stdio.h>
#include <math.h>

double __arg[32];

int x = 0;
double t2 = 0.0;
int z = 0;
int a = 0;

int main(){
  x = 10.000000;
  t2 = 10.000000 == 20.000000;
  if (!(t2)) goto L_main_L0;
  z = 30.000000;
  goto L_main_L1;
L_main_L0:
  a = 40.000000;
L_main_L1:
  return 0;
}
