% RUNS ON mzn20_fd
% RUNS ON mzn-fzn_fd
% Test forall/1 with multi-dimensional arrays.

bool: b = forall([|true, true | true \/ false, not false|]);
array[1..2,1..2,1..2] of var bool: bs;
constraint forall(bs);

solve satisfy;

output [
   "% b = ", show(b), ";\n",
   "bs = ", show(bs), ";\n"
];
