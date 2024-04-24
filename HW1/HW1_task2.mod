
reset; 
option solver minos;

param Days;
param Shifts;
param Lags;
param Demand{1..6, 1..7};

# Decision Variables
var FC{1..Shifts, 1..Days} >= 0;
var PC{1..Shifts, 1..Days} >= 0;

minimize TotalCost:
 sum{ i in 1..Shifts, j in 1..Days } (1000*FC[i, j] + 600*PC[i, j]);

subject to c1 {j in 1..Days}:
    sum{l in 0..Lags} (
        FC[1, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[1, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[1, j];

subject to c2 { j in 1..Days}:
 sum{l in 0..Lags} (
        FC[1, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[1, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[2, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[2, j];

subject to c3 { j in 1..Days}:
 sum{l in 0..Lags} (
        FC[1, if j - l <= 0 then 7 + (j - l) else j - l] +
        FC[2, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[2, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[3, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[3, j];
    
subject to c4 { j in 1..Days}:
 sum{l in 0..Lags} (
        FC[1, if j - l <= 0 then 7 + (j - l) else j - l] +
        FC[2, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[3, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[4, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[4, j];

subject to c5 { j in 1..Days}:
 sum{l in 0..Lags} (
        FC[2, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[4, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[5, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[5, j];

subject to c6 { j in 1..Days}:
 sum{l in 0..Lags} (
        FC[2, if j - l <= 0 then 7 + (j - l) else j - l] +
        PC[5, if j - l <= 0 then 7 + (j - l) else j - l]
    ) >= Demand[6, j];
  
data;
param Days := 7;
param Shifts := 6;
param Lags := 4;

param Demand :
1 2 3 4 5 6 7 :=
1 2 1 1 1 1 1 1
2 2 1 1 1 1 2 3
3 2 2 2 2 2 4 5
4 2 2 2 2 2 4 5
5 3 3 3 3 5 8 8
6 4 3 3 3 4 6 6
;

solve;
display FC;
display PC;
