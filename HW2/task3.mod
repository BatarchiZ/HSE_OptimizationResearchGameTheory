reset;

param M;
param T;
param K;

param fp{1..T};
param mc{1..K};
param pcd{1..K};

var I{1..M,1..T} >= 0;
var X{1..M,1..T} >= 0;
var Y{1..M,1..T,1..K} binary;

maximize Profit:
	sum{t in 1..T, i in 1..M} X[i, t] * fp[t]
	- sum{t in 1..T, i in 1..M, k in 1..K} Y[i,t,k] * mc[i];
	
subject to
	one_mill_maint{t in 1..T, k in 1..K}:
		sum{i in 1..M} Y[i,t,k] <= 1;
	one_main_dec{i in 1..M, t in 1..T}: 
		sum{k in 1..K} Y[i,t,k] <= 1;
		
	main_activation1{i in 1..M, t in 1..T}:
		Y[i, t, 1] <= 1500 - I[i, t];
	main_activation2{i in 1..M, t in 1..T}:
		Y[i, t, 2] <= 2500 - I[i, t];
	main_activation3{i in 1..M, t in 1..T}:
		Y[i, t, 3] <= 4000 - I[i, t];
	
	mill_capacity_balance1{i in 1..M, t in 1..(T - 1)}:
		I[i,t + 1] <= 4000 * ( 1 - sum{k in 1..K} Y[i,t,k]);
	mill_capacity_balance2{i in 1..M, t in 1..(T - 1)}:
		I[i,t + 1] >= I[i, t] + X[i,t] - 10000 * ( sum{k in 1..K} Y[i,t,k]);
	mill_capacity_balance3{i in 1..M, t in 1..(T - 1)}:
		I[i,t + 1] <= I[i, t] + X[i,t] + 10000 * ( sum{k in 1..K} Y[i,t,k]);
	
	lower_bound{t in 1..T}:
		sum{i in 1..M} X[i, t] >= 2000;
	upper_bound{t in 1..T}:
		sum{i in 1..M} X[i, t] <= 3000;
	
	produciton_cap{i in 1..M, t in 1..T}:
		X[i,t] <= 1000 - sum{ k in 1..K} pcd[k] * Y[i,t,k];
		
	init1:
		I[1,1] = 600;
	init2:
		I[2,1] = 400;
	init3:
		I[3,1] = 1000;
	
data;
param T := 6;
param M := 3;
param K := 3;

param fp := 
	1	100
	2	120
	3	110
	4	140
	5	90
	6	100;
	
param: mc pcd :=
	1	1000	20
	2	2000	30
	3	4000	50;

option solver cplex;
solve;
display Y;
display I;
display X;


