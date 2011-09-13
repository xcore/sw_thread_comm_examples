// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __fifo_h__
#define __fifo_h__

/*************************************************************************
 * A very simple fifo library.
 *
 * This library provides a simple fifo to use in example code.
 * The fifo stores FIFOSIZE members where each member is an array
 * of DATASIZE words.
 *
 *************************************************************************/

/** The amount of data in each element of the fifo */
#define DATASIZE 10

/** The size of the fifo */
#define FIFOSIZE 5

/** The datatype representing a fifo */
typedef struct fifo_t {
  int rdptr;
  int wrptr;
  int buf[FIFOSIZE][DATASIZE];
} fifo_t;

/** Initialize a fifo
 *
 * This function should be called before the first use of the fifo to
 * initialize its internal state.
 *
 * \param fifo   the fifo to initialize
 *
 */
void init_fifo(fifo_t &fifo);

/** Push an element into the fifo.
 *
 * This function pushes an element into a fifo. If the fifo is full the
 * data is discarded.
 *
 *
 * \param fifo   the fifo to push into
 * \param data   the data element to add to the fifo
 *
 */
void add_to_fifo(fifo_t &fifo, int data[]);

/** Get and element from a fifo.
 *
 * This pops an element out of the fifo.
 *
 *
 * \param fifo   the fifo
 * \param data   the data element to fill with the fifo data
 *
 * \returns      0 if the fifo is empty, 1 otherwise
 */
int get_from_fifo(fifo_t &fifo, int data[]);

/** Check if a fifo is empty.
 *
 *  \returns     1 if the fifo is empty, 0 otherwise
 */
int fifo_empty(fifo_t &fifo);

#endif // __fifo_h__
