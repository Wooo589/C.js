#include <stdio.h>
#include <math.h>

double __arg[32];

double t0 = 0.0;
int a = 0;
int b = 0;
double resultado = 0.0;

double soma() {
  double a = __arg[0];
  double b = __arg[1];
  t0 = a + b;
  resultado = t0;
  return t0;
}

