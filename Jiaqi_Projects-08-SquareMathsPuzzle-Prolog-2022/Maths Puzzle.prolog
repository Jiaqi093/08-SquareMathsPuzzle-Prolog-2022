% Author: Jiaqi Zhuang <zhuanjz@student.unimelb.edu.au>
% Purpose: figure out all proper solutions for a N * N maths puzzle.

% There will be a N * N matrix where the top row and left column is provided 
% called heading.The program will start from the diagonal value, if there is a
% appropriate diagonal value (must be between 1..9) is found, then we are going
% to check whether the column heading is equal to the sum/product of the other
% column digits. If satisfied for all rows and columns, we then check whether
% every input digits are distinct in their row & column.Finally, the maths 
% puzzle is resolved.


% Library: --------------------------------------------------------------------
% use the library clpfd to resolve some equations with unbounded variables
% on both left hand side and right hand side, to improve the efficiency of
% the code.
:- ensure_loaded(library(clpfd)).


% puzzle solution: ------------------------------------------------------------
%% puzzle_solution(+list)
% puzzle_solution/1 allows the input of an list of list ---- "puzzle",
% and this predicate clearly states all essential predicates (constraints),
% to let program to find a proper solution.

% The whole process is explained below:
% Firstly, using maplist predicate to check the size of puzzle to be N * N.
% Then, apply different constraints to create the rule of maths puzzle.
% Constraints 1: check_single_digit/1, make sure the input value is 
% restricted in {1..9}.
% Constraints 2: check_diagonal/1, make sure the diagonal value in matrix are 
% the same (except the column heading).
% Next, apply the transpose, so all the rows are becoming the columns, so 
% later the other two constraints would apply on both rows and columns.
% After that, check_valid_head is used here to check whether the digits in 
% headings are greater than 0. If not, then no need to work for the solution.
% Constraints 3: check_distinct/1, make sure the matrix (without heading) in 
% every columns and rows are distinct.
% Constraints 4: check_product_sum/1: make sure that all columns and rows 
% satisfy the rule (row/column heading would be either the sum or the product 
% of the corresponding row/column.
% Last but not least, apply labelling so that the program would provide a 
% proper answer (no free variables).
puzzle_solution(Puzzle) :-
    maplist(same_length(Puzzle), Puzzle),
    check_single_digit(Puzzle),
    check_diagonal(Puzzle),   
    transpose(Puzzle, Colpuzzle),
    check_valid_head(Puzzle), check_valid_head(Colpuzzle),
    check_dinstinct(Puzzle), check_dinstinct(Colpuzzle),
    check_product_sum(Puzzle), check_product_sum(Colpuzzle),
    label_all(Puzzle).

%% remove_heading(+list0, -list1).
% remove_heading/2 takes any row/column and remove its first element (heading). 
% The rest of the element in a list will be stored in "RowTail" list.
remove_heading([_RowHead|RowTail], RowTail).


%% check_single_digit(+list), append(+pred, +list)
% check_single_digit/1 takes a puzzle as input, discard the column heading
% and call remove_heading predicate to remove heading of every rows, so a N * N
% matrix becomes a (N-1) * (N-1) matrix stored in CleanedRows. Then, a list "Vs"
% specifies that digits in CleanedRows are in the range of 1..9.
check_single_digit([_ColumnHead|Rows]) :-
    maplist(remove_heading, Rows, CleanedRows),
    append(CleanedRows, Vs), Vs ins 1..9.


%% check_diagonal(+list), nth0(+Integer, +list, -Integer)
% check_diagonal/1 takes a puzzle as input, and use nth0 predicate to pick up
% the top left diagonal value (i.e. diaValue), then call eq_diag/3 predicate to 
% ensure that all diagonal value are the same.
check_diagonal([_ColumnHead|[FirstRow|Rows]]) :-
    nth0(1, FirstRow, DiagValue), % 1st elem of 1st row stored as diagvalue
    eq_diag(Rows, 2, DiagValue).


%% eq_diag(+list, +Accumulator, -integer), nth0(+Integer, +list, -Integer)
% eq_diag/3 takes the puzzle (without column heading) as input, and use nth0/3
% to check the Nth element of Nth row has the same value with diagvalue.
eq_diag([], _, _).
eq_diag([CurrRow|Rows], N, DiagValue) :-
    nth0(N, CurrRow, DiagValue),
    N1 #= N + 1,
    eq_diag(Rows, N1, DiagValue).


%% check_valid_head(+list), maplist(+pred, +list)
% check_valid_head/1 takes the puzzle as input, and its function is to check
% whether every digits in heading are greater than zero through <(0) predicate. 
% If not, no need to proceed since there is no solution.
check_valid_head([[_|Head]|_Rows]):-
    maplist(<(0), Head).


%% check_distinct(+list), maplist(+pred, -list1)
% check_dinstinct/1 takes the puzzle as input, and call remove_heading/2
% to remove the row heading, forms the CleanedRows. Then, all_distinct predicate
% is called to check every digits in each rows are distinct. 
check_dinstinct([_ColumnHead|Rows]) :-
    maplist(remove_heading, Rows, CleanedRows),
    maplist(all_distinct, CleanedRows).


%% check_product_sum(+list)
% check_product_sum/1 takes the puzzle as input, disregard the column heading
% and check whether the row heading is either the sum or the product of the 
% digits in the row.Maplist checks that every rows satisfy this constraint.
check_product_sum([_ColumnHead|Rows]) :-
    maplist(is_product_sum, Rows).


%% is_product_sum(+list)
% is_product_sum/1 takes a specific row as input, which use is_product/2 
% to check the product of the row tail and use is_sum/2 to check the sum of 
% row tail. Either of them is true would gives a true value to check_product_sum 
is_product_sum([Head|Tail]) :- 
    is_product(Head, Tail).
is_product_sum([Head|Tail]) :- 
    is_sum(Head, Tail).


%% is_sum(+Integer, +list)
% is_sum/2 takes the row heading and row tail as input, to check whether sum of 
% the row tail is equal to the row head.
is_sum(Sum, List) :- is_sum(List, 0, Sum).
is_sum([], Sum, Sum).
is_sum([N | Ns], Sum0, Sum) :- 
    Sum1 #= N + Sum0,
    is_sum(Ns, Sum1, Sum).


%% is_product(+Integer, +list)
% is_product/2 takes the row heading and row tail as input, to check whether   
% the product of the row tail is equal to the row head.
is_product(Product, List) :- is_product(List, 1, Product).
is_product([], Product, Product).
is_product([N | Ns], Product0, Product) :-
    Product1 #= N * Product0,
    is_product(Ns, Product1, Product).


%% label_all(+list)
% label_all/1 takes the puzzle as input, disregard the column heading as usual,
% and ensure all the digits in the matrix are grounded integers.
label_all([_ColumnHead|Rows]) :-
    maplist(label, Rows).