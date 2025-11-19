#include <stdio.h>
#include <math.h>

double __arg[32];

double t0 = 0.0;
int a = 0;
int b = 0;
double t1 = 0.0;
double result = 0.0;

double soma() {
  double a = __arg[0];
  double b = __arg[1];
  t0 = a + b;
  return t0;
}

double main() {
  __arg[0] = 3.000000;
  __arg[1] = 4.000000;
  t1 = soma();
  result = t1;
  return t1;
}

