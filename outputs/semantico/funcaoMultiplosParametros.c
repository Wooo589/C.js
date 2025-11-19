#include <stdio.h>
#include <math.h>

double __arg[32];

double t0 = 0.0;
int x = 0;
int y = 0;
double t1 = 0.0;
int z = 0;
double resultado = 0.0;

double calcular() {
  double x = __arg[0];
  double z = __arg[1];
  double y = __arg[2];
  t0 = x + y;
  t1 = t0 + z;
  resultado = t1;
  return t1;
}

