------------------------------------------------------------------------------------------------
Alpha expansion for Robust P^N potentials (fixed weights)
------------------------------------------------------------------------------------------------

Authors: Pushmeet Kohli, Lubor Ladicky, Philip H.S.Torr
Oxford Brookes University

------------------------------------------------------------------------------------------------
Matlab wrapper for Robust P^N Potentials (varying weights)
------------------------------------------------------------------------------------------------

Author: Shai Bagon
Weizmann Institute of Science, Israel.

------------------------------------------------------------------------------------------------
Licence
------------------------------------------------------------------------------------------------

This software library implements the alpha expansion for robust P^N potentials described in

P. Kohli, L. Ladicky, and P. Torr. Graph cuts for minimizing robust higher order potentials.
Technical report, Oxford Brookes University, UK., 2008.

P. Kohli, L. Ladicky, and P. Torr. Robust higher order potentials for enforcing label
consistency. In CVPR, 2008.

------------------------------------------------------------------------------------------------

The library uses max-flow code described in

Yuri Boykov and Vladimir Kolmogorov. An Experimental Comparison of Min-Cut/Max-Flow Algorithms
for Energy Minimization in Vision. In IEEE Transactions on Pattern Analysis and Machine
Intelligence (PAMI), September 2004

------------------------------------------------------------------------------------------------

The alpha expansion algorithm is explained in

Y. Boykov, O. Veksler, and R. Zabih. Fast approximate energy minimization via graph cuts.
PAMI, 23(11):1222–1239, 2001.

------------------------------------------------------------------------------------------------

The code is free to use for research purposes. If you use this software for research purposes,
you should cite above papers in any resulting publication.

------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
Files included
------------------------------------------------------------------------------------------------

README.txt        - this readme file

robustpn_mex.cpp    - source file interfacing to Matlab

robustpn_compile.m    - compiling library for Matlab

robustpn_test.m - tests for the wrapper

energy.h          - header file with energy class definition

expand.h         - header file with alpha expansion code

graph.h, block.h  - header files containg max-flow code

------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
Installation
------------------------------------------------------------------------------------------------

1. Extract all files in this package into a directory (e.g., /home/bagon/robustpn, or d:\matlab\robustpn)

2. Open Matlab

3. Set mex compiler for matlab
>> mex -setup

3. Go to robustpn directory
>> cd /home/bagon/robustpn

4. Compile the wrapper using
>> robustpn_compile

5. Run the tests (you can look at this file to see examples of how to use the wrapper)
   NOTE: this test code requires ANN class:
   http://www.wisdom.weizmann.ac.il/~bagon/matlab.html#ann
>> robustpn_test

6. Type 
>> doc robustpn_mex
   for some brief help and usage of the function.

7. That's it - you are done.

------------------------------------------------------------------------------------------------
Using the wrapper
------------------------------------------------------------------------------------------------
 
  [L E] = robustpn_mex(sparseG, Dc, hop)
 
  Inputs:
   sparseG - sparse adjecency matrix defining graph structure and pair-wise potentials
       sparseG(i,j) !=0 means i,j share a pair-wise potntial with value sparseG(i,j)
       sparseG is of size (#nodes)x(#nodes)
   Dc - unary potential, i.e., data term of size (#labels)x(#nodes)
   hop - higher order potential array of structs with (#higher) entries, each entry:
       .ind - indices of nodes belonging to this hop
       .w - weights w_i for each participating node
       .gamma - #labels + 1 entries for gamma_1..gamma_max
       .Q - truncation value for this potential (assumes one Q for all labels)
 
  Outputs:
   L - optimal labels
   E - obtained minimal energy

------------------------------------------------------------------------------------------------
Contact Information
------------------------------------------------------------------------------------------------

Email:
    shai.bagon@weizmann.ac.il   (Shai Bagon)

------------------------------------------------------------------------------------------------
