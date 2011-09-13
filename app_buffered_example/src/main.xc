// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <print.h>
#include <xs1.h>
#include "fifo.h"

/** The interval in timer ticks that thread1 will generate data at */
#define DATA_GEN_INTERVAL 10000

/** A simple random data generation function */
int gen_data(int &x) {
  const unsigned a=1664525;
  const unsigned c=1013904223;
  x = a * ((unsigned) x) + c;
  return x;
}

/** thread 1.
 *
 *  This thread periodically generates data and places it in a fifo. It signals
 *  to thread 2 when data is ready and responds when thread 2 asks for data.
 *
 */
void thread1(chanend c) {
  int st = 1234;
  int data[DATASIZE];
  fifo_t fifo;
  timer tmr;
  int t;
  int notified = 0;

  init_fifo(fifo);

  tmr :> t;
  while (1) {
    select
      {
      case tmr when timerafter(t) :> void:
        // Periodically this thread generates some data
        // This case fires from a timer when it is time to generate some

        // Generate the data
        for (int i=0;i<DATASIZE;i++) {
          data[i] = gen_data(st);
        }

        // Put the data into the fifo
        printstrln("Thread1: Putting data into fifo");
        add_to_fifo(fifo, data);

        // If we haven't notified the other thread already then send a
        // token into the channel to say that data is ready
        if (!notified) {
          printstrln("Thread1: Notifying thread2 that data is available.");
          outct(c, XS1_CT_END);
          notified = 1;
        }

        // Set the time for the next data generation
        t += DATA_GEN_INTERVAL;
        break;

      case c :> int request:
        // The other side has received our notification and responded
        printstrln("Thread1: Received data request.");

        // Get some data and send it back
        get_from_fifo(fifo, data);
        printstrln("Thread1: Sending data.");
        master {
          for (int i=0;i<DATASIZE;i++) {
            c <: data[i];
          }
        }

        // If we have more data to send then renotify
        if (fifo_empty(fifo)) {
          notified = 0;
        }
        else {
          printstrln("Thread1: Notifying thread2 that data is available.");
          outct(c, XS1_CT_END);
          notified = 1;
        }
        break;
      }
  }
}

/** Thread 2
 *
 * This thread responds to data notifications provided by thread1 and pulls
 * the data from thread1.
 *
 * Periodically it enters a busy state where it does not respond to
 * notifiations. In this state the fifo in thread1 will start to back up and
 * will by emptied when this thread comes out of the busy state.
 *
 */
void thread2(chanend c) {
  int data[DATASIZE];
  char ct;
  timer tmr;
  unsigned t;
  tmr :> t;
  t += (DATA_GEN_INTERVAL*3)/2;
  while (1) {
    select {
    case inct_byref(c, ct):
      // The other thread has notified us that data is ready
      printstrln("Thread2:                                                Received notification.");
      printstrln("Thread2:                                                Sending data request.");

      // Signal that we wish to consume the data
      c <: 0;

      // Receive the data
      slave {
        for (int i=0;i<DATASIZE;i++) {
          c :> data[i];
        }
      }
      printstrln("Thread2:                                                Received data.");
      break;

    case tmr when timerafter(t) :> void:
      // The timer case is a periodic case that enters the "busy" period
      printstrln("Thread2:                                                Busy.");

      // wait for DATA_GEN_INTERVAL*3 ticks
      t += DATA_GEN_INTERVAL*3;
      tmr when timerafter(t) :> void;

      printstrln("Thread2:                                                Not Busy.");

      // Set up the time for the next busy case
      t += (DATA_GEN_INTERVAL*3)/2;
      break;
    }
  }

}

/** The main function
 *
 *  This function sets thread1 and thread2 off in parallel connected by a
 *  channel.
 */
int main() {
  chan c;
  par {
    thread1(c);
    thread2(c);
  }
  return 0;
}

