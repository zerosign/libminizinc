% RUNS ON mzn20_fd
% RUNS ON mzn-fzn_fd
% RUNS ON mzn20_fd_linear
% RUNS ON mzn20_mip
% A regression test for G12 bug #52.
%
array[1..3,1..3] of var int: x;
array[1..9] of var int: x1d = [x[w,h] | w in 1..3, h in 1..3];
var int: x1d1 = x1d[1];
var int: x1d9 = x1d[9];

constraint x[1, 1] = 3;

constraint x[3, 3] = 10;

solve satisfy;

output [
   "x1d1 = ", show(x1d1), ";\n",
   "x1d9 = ", show(x1d9), ";\n"
];
