% LFR2MU       - LFR-objects adapted to the function mussv
%-----------------------------------------------------------------
% PURPOSE
% Generates  the  input  arguments of the function 'mussv' for mu-
% analysis of a given LFR-object.
%
%
% SYNOPSIS
% [M,blk] = lfr2mussv(sys,frequ[,K]);
%
% INPUT ARGUMENTS
% sys     Dynamic LFR-object.
% frequ   Real  number  = frequency at which M must be computed or
%         vector, in  this case, M is a set of frequency responses
%         as generated by 'frd'.
% K       Feedback:  matrix, ss-object, lfr-object (scheduled fb).
%
% OUTPUT ARGUMENTS
% M       Constant  matrix  (the  M-matrix of an M-Delta form). If
%         frequ  is  a  vector, M is the set of such matrices obt-
%         ained by using 'frsp' (called 'varying matrix').
% blk     Uncertainty  block  description  compatible with the mu-
%         Analysis and Design Toolbox.
%
% See also lfr2mubnd, lfr2mustab, lfr2mu
%#----------------------------------------------------------------
% % EXAMPLE
% % Uncertain system
%    lfrs a b c
%    A = [-1+5*a -10*(1+b);10*(1+c^2) -1-a*b*c];
%    B = [1+b;1*c]; C = [1 1];
%    sys = abcd2lfr([A B;C 0],2);
%
% % Computation of the arguments of mu
%    frequ = logspace(0,2,20);
%    [M,blk] = lfr2mussv(sys,frequ);
%
% % Mu-analysis
%    [bnds,muinfo] = mussv(M,blk); % = mussv(M,blk,'a')
%
% % Results (For comparison, see help lfr2mubnd)
%    plot(bnds); hold on;