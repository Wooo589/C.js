#include <stdio.h>
#include <math.h>

double __arg[32];

double t0 = 0.0;
int a = 0;
int b = 0;

double max() {
  double a = __arg[0];
  double b = __arg[1];
  t0 = a > b;
  if (!(t0)) goto L0;
  return a;
  goto L1;
L0:
  return b;
L1:
}

