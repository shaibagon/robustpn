% Robust Higher-Order Potentials energy minimization:
%
% Usage:
%  [L E] = robustpn_mex(sparseG, Dc, hop, init_labels)
%
% Inputs:
%  sparseG - sparse adjecency matrix defining graph structure and pair-wise potentials
%      sparseG(i,j) !=0 means i,j share a pair-wise potntial with value sparseG(i,j)
%      sparseG is of size (#nodes)x(#nodes). The matrix must be symmetric (undirected graph)
%  Dc - unary potential, i.e., data term of size (#labels)x(#nodes)
%  hop - higher order potential array of structs with (#higher) entries, each entry:
%      .ind - indices of nodes belonging to this hop
%      .w - weights w_i for each participating node
%      .gamma - #labels + 1 entries for gamma_1..gamma_max
%      .Q - truncation value for this potential (assumes one Q for all labels)
%  init_labels - (optional) initial guess of labeling (range 1..(#labels))
%
% Outputs:
%  L - optimal labels (range 0..(#labels-1))
%  E - obtained minimal energy [Unary Pairs HO Tot]
%
%
%  This wrapper for Matlab was written by Shai Bagon (shai.bagon@weizmann.ac.il).
%  Department of Computer Science and Applied Mathmatics
%  Wiezmann Institute of Science
%  http://www.wisdom.weizmann.ac.il/~bagon
%   
%	The core cpp application was written by Pushmeet Kohli, Lubor Ladicky and Philip H.S.Torr
%  It is described in
%
%  P. Kohli, L. Ladicky, and P. Torr. Graph cuts for minimizing robust higher order potentials.
%  Technical report, Oxford Brookes University, UK., 2008.
%  
%  P. Kohli, L. Ladicky, and P. Torr. Robust higher order potentials for enforcing label
%  consistency. In CVPR, 2008.
% 
%  Yuri Boykov and Vladimir Kolmogorov. An Experimental Comparison of Min-Cut/Max-Flow Algorithms
%  for Energy Minimization in Vision. In IEEE Transactions on Pattern Analysis and Machine
%  Intelligence (PAMI), September 2004
%  
%  Matlab Wrapper for Robust P^N Potentials.
%  Shai Bagon.
%  in www.wisdom.weizmann.ac.il/~bagon, January 2009.
% 
%   This software can be used only for research purposes, you should  cite ALL of
%   the aforementioned papers in any resulting publication.
%   If you wish to use this software (or the algorithms described in the
%   aforementioned paper)
%   for commercial purposes, you should be aware that there is a US patent:
%
%       R. Zabih, Y. Boykov, O. Veksler,
%       "System and method for fast approximate energy minimization via
%       graph cuts",
%       United Stated Patent 6,744,923, June 1, 2004
%
%
%   The Software is provided "as is", without warranty of any kind.
%
%
%
%
%
% mex implementation