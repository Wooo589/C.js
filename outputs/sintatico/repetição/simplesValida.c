#include <stdio.h>
#include <math.h>

double __arg[32];

int a = 0;
int i = 0;
double t4 = 0.0;
double  = 0.0;
double t5 = 0.0;
double t7 = 0.0;
double t8 = 0.0;
double t9 = 0.0;
double t10 = 0.0;
double t11 = 0.0;
double t12 = 0.0;

int main(){
  a = 10.000000;
  i = 0.000000;
  t4 = 0.000000 ++ ;
  i = t4;
  t5 = 10.000000 ++ ;
  a = t5;
L_main_L0:
  t7 = t4 < 10.000000;
  t8 = t4 ++ ;
  i = t8;
  t9 = t5 ++ ;
  a = t9;
  if (!(t7)) goto L_main_L1;
  t10 = t9 ++ ;
  a = t10;
L_main_L2:
  t11 = t8 ++ ;
  i = t11;
  t12 = t10 ++ ;
  a = t12;
  goto L_main_L0;
L_main_L1:
  return 0;
}
