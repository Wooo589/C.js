#include <stdio.h>
#include <math.h>

double __arg[32];

int x = 0;
double t2 = 0.0;
double t4 = 0.0;
double t5 = 0.0;
int z = 0;

int main(){
  x = 10.000000;
  t2 = 10.000000 == 10.000000;
  t4 = 20.000000 == 20.000000;
  t5 = t2 && t4;
  if (!(t5)) goto L_main_L0;
  z = 30.000000;
L_main_L0:
  return 0;
}
