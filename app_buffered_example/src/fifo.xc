// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "fifo.h"

void init_fifo(fifo_t &fifo) {
  fifo.rdptr = 0;
  fifo.wrptr = 0;
}

void add_to_fifo(fifo_t &fifo, int data[]) {
  int new_wrptr;

  new_wrptr = fifo.wrptr + 1;
  if (new_wrptr >= FIFOSIZE)
    new_wrptr = 0;

  if (new_wrptr != fifo.rdptr) {
    for (int i=0;i<DATASIZE;i++) {
      fifo.buf[fifo.wrptr][i] = data[i];
      fifo.wrptr = new_wrptr;
    }
  } else {
    // fifo is full, drop the data

  }

}

int get_from_fifo(fifo_t &fifo, int data[])
{
  if (fifo.rdptr == fifo.wrptr) {
    //buffer is empty
    return 0;
  }

  for (int i=0;i<DATASIZE;i++)
    data[i] = fifo.buf[fifo.rdptr][i];

  fifo.rdptr += 1;

  if (fifo.rdptr >= FIFOSIZE)
    fifo.rdptr = 0;

  return 1;
}

int fifo_empty(fifo_t &fifo) {
  return (fifo.rdptr == fifo.wrptr);
}
