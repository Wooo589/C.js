#include <stdio.h>
#include <math.h>

double __arg[32];

int x = 0;
double t2 = 0.0;
int z = 0;
double t5 = 0.0;
int a = 0;
double t8 = 0.0;

int main(){
  x = 10.000000;
  t2 = 10.000000 == 20.000000;
  if (!(t2)) goto L_main_L0;
  z = 30.000000;
  t5 = 10.000000 == 10.000000;
  if (!(t5)) goto L_main_L1;
  a = 40.000000;
L_main_L1:
L_main_L0:
  t8 = 10.000000 == 10.000000;
  if (!(t8)) goto L_main_L2;
  a = 40.000000;
L_main_L2:
  return 0;
}
