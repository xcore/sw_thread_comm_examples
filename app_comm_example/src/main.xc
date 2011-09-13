// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <print.h>

int gen_data(int &x) {
  const unsigned a=1664525;
  const unsigned c=1013904223;
  x = a * ((unsigned) x) + c;
  return x;
}

void thread1(chanend c) {
  int st = 1234;
  int x;

  c <: gen_data(st);

  c :> x;

  printstr("thread1 received: ");
  printintln(x);
}

void thread2(chanend c) {
  int st = 5678;
  int x;

  c :> x;

  printstr("thread2 received: ");
  printintln(x);

  c <: gen_data(st);


}

int main() {
  chan c;
  par {
    thread1(c);
    thread2(c);
  }
  return 0;
}

