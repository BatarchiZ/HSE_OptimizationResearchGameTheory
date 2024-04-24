reset;

param I;
param P;
param rental_cost{1..5};
param production_cost{1..5};
param production_capacity{1..5};
param demand{1..P};
param bin{1..I, 1..P} binary; 

var x{1..I, 1..P} >= 0;
var y{1..I} binary;

minimize TotalCost: 
	sum{i in 1..I} rental_cost[i] * y[i]
	+ sum{i in 1..I, p in 1..P} production_cost[i] * x[i, p];

subject to
	demand_condition{p in 1..P}:
		sum{i in 1..I} x[i, p] * bin[i,p] >= demand[p];
	cap_lim{i in 1..I}:
		sum{p in 1..P} x[i,p] <= production_capacity[i]*y[i];
	
data;

param I := 5;
param P := 4;

param bin: 1 2 3 4:=
	1 1	1 1 0
	2 1 0 1 1
	3 0 1 0 1
	4 0 0 1 1
	5 1 0 0 1
	;

param demand :=
	1 200
	2 100
	3 50
	4 100
;

param: rental_cost production_cost production_capacity:= 
    1 2000 17 250
    2 2500 15 200
    3 1500 20 100
    4 1400 18 300
    5 1700 14 150;

option solver cplex;
solve;
display y;
display x;
