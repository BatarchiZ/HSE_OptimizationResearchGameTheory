













reset;

param C;
param M;
param T;


param d{1..C, 1..T};

param rcap{1..M};
param rtap{1..M};
param rcpa{1..M};
param rtpa{1..M};

param pt{1..C, 1..M};
param pc{1..C, 1..M};

param inv_c;


var I{1..C, 1..T} >= 0;
var X{1..C, 1..M, 1..T} >= 0;
var S{1..C, 1..M, 0..T} binary;
var switch{1..C, 1..M, 1..T} binary;


minimize Cost:
	sum{t in 1..T, j in 1..M, i in 1..C} X[i,j,t] * pc[i,j]
	+ sum{t in 1..T, j in 1..M} (switch[1,j,t] * rcpa[j] + switch[2,j,t] * rcap[j])
	+ sum{t in 1..T, i in 1..C} inv_c * I[i,t];

subject to
	inv_balance{i in 1..C, t in 1..(T - 1)}:
		I[i, t + 1] = I[i,t] + sum{j in 1..M} X[i,j,t] - d[i, t];
		
	state_balance1{i in 1..C, j in 1..M, t in 1..T}:
		S[1,j,t] = S[1,j,t - 1] + switch[1,j,t] - switch[2,j,t];
	state_balance2{i in 1..C, j in 1..M, t in 1..T}:
		S[2,j,t] = S[2,j,t - 1] - switch[1,j,t] + switch[2,j,t];
		
	switch_balance{j in 1..M, t in 1..T}:
		switch[1,j,t] + switch[2,j,t] <= 1;
	state_balance{j in 1..M, t in 1..T}:
		S[1,j,t] + S[2,j,t] = 1;
		
	production_limit{c in 1..C, j in 1..M, t in 1..T}:
		X[c,j,t] * pt[c,j] <= 160 - rtpa[j] * switch[1,j,t] - rtap[j] * switch[2,j,t];
		
	production_limit2{c in 1..C, j in 1..M, t in 1..T}:
		X[c,j,t] <= 160 * S[c,j,t];
	
	init_inv1:
		I[1, 1] = 20;
	init_inv2:
		I[2, 1] = 10;
		
	init_state{j in 1..M}:
		S[1, j, 0] = 1;

data;
param inv_c:= 5;
param C:= 2;
param T:= 5;
param M:= 3;

param: rcap rtap rcpa rtpa:=
	1 100 20 150 15
	2 90 15 180 10
	3 110 18 120 12;
	
	
param d : 1 2 3 4 5:=
	1 30 20 20 20 30
	2 10 30 35 15 10
	;
param pt: 1 2 3:=
	1 10 12 8
	2 12 14 16
	;
param pc: 1 2 3:=
	1 90 80 120
	2 120 110 130
	;


option solver cplex;
solve;
display I;
display S;
display switch;



