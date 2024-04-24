reset;

option solver minos;

set Time;

set J;

set Nodes ordered;            
set Routes within {Nodes cross Nodes};

param TransportationCost{Routes};
param Capacity{Routes};                         
param LeadTime{Routes};   
param MaxStorage{Nodes};
param HoldingCost{Nodes};

set DistributionNodes ordered;
param Demand{Nodes, Time};

set Products ordered;

param StartingInventory{J, Products} default 0;

# Objective varaibles
var x{Routes, Products, Time} >= 0;
var I{Products, J, Time} >= 0;

minimize TotalCost:
	sum{ p in Products, j in J, t in Time} HoldingCost[j] * I[p, j, t] +
	sum{ (i,j) in Routes,p in Products, t in Time} TransportationCost[i,j] * x[i,j,p,t]
	;

#subject to CB1{t in Time}:
#	sum{ (i,v) in Routes} (2 * x[i,'F01','RM01', t] + x[i, 'F01', 'RM01', t] = x['F01',v,'IG01',t];
subject to CB1 {t in Time}:
    sum {(i, j) in Routes: j == 'F01'} (2 * x[i, j, 'RM01', t] + x[i, j, 'RM02', t]) = sum{(u,v) in Routes : u == 'F01'} x[u, v, 'IG01', t];

subject to CB2 {t in Time}:
    sum {(i, j) in Routes: j == 'F02'} (2 * x[i, j, 'RM01', t] + x[i, j, 'RM02', t]) = sum{(u,v) in Routes : u == 'F02'} x[u, v, 'IG01', t];
    
subject to CB3 {t in Time}:
	sum {(i, j) in Routes: j == 'F03'} x[i,j,'IG01',t] = sum{(u, v) in Routes : u == 'F03' }x[u, v,'FG01', t];
	
#subject to D{ d in DistributionNodes}:
#	sum{t in Time} I['FG01',d, t] >= sum{t in Time} Demand[d, t];
	
subject to InventoryBalance{p in Products, t in Time, cur in J}:
	( if t == 1 then StartingInventory[cur, p] else I[p, cur, t - 1] ) 
	+ sum{ (i, j) in Routes: j == cur} (if t > LeadTime[i, j] then x[i, j, p, t - LeadTime[i, j]] else 0) 
	= sum{(i,j) in Routes : i == cur} x[i, j, p, t]
	+ I[p, cur, t];

subject to RouteCapacity{ (u, v) in Routes, t in Time}:
	sum{p in Products} x[u, v, p, t] <= Capacity[u,v];

subject to StorageLimit{ i in J, t in Time}:
	sum{p in Products} I[p, i, t] <= MaxStorage[i];

subject to Dem{ d in DistributionNodes, t in Time}:
	x[d, 'DEMAND_NODE','FG01', t] >= Demand[d, t];
	
	
	

	
data;  
set Time := 1 2 3;

set DistributionNodes := DC01, DC02, DC03;

param Demand :
1 2 3 :=
DC01 50 10 10
DC02 10 20 10
DC03 10 20 10
; 

# Uncomment to get the big version --- it did not work on my device because too many variables

#set Time := 1 2 3 4 5 6 7 8 9 10;
#param Demand :
#1 2 3 4 5 6 7 8 9 10 :=
#DC01 50 10 10 20 10 20 10 50 50 120
#DC02 10 20 10 20 10 20 10 20 50 120
#DC03 10 20 10 20 10 20 10 20 50 110; 

set Nodes := S01, S02, WH01, WH02, WH03, WH04, WH05, DC01, DC02, DC03, F01, F02, F03, DEMAND_NODE;
set J := S01, S02, WH01, WH02, WH03, WH04, WH05, DC02, DC03, DC01;
;                   

set Products := RM01, RM02, IG01, FG01; 
set Routes :=
# Part 1
	(S01, WH01)
	(S02, WH02)
	(WH01, WH03)
	(WH02, WH03)
	(WH02, F02)
	(WH01, F01)
	(WH03, F01)
	(WH03, F02)

# Part 2
	(F01, WH04)
	(F01, F03)
	(F02, WH04)
	(WH04, F03)
	
# Part 3
    (F03, DC01)
    (F03, WH05)
    (F03, DC03)
    (WH05, DC01)
    (WH05, DC02)
    (DC01, DC02)
    (DC02, DC03)
    (DC01, DEMAND_NODE)
    (DC02, DEMAND_NODE)
    (DC03, DEMAND_NODE)
    
;

param: TransportationCost Capacity LeadTime :=
	S01		WH01	11	400	1
	S02		WH02	21	350	1
	WH01	F01		8	500	1
	WH01	WH03	11	500	1
	WH02	WH03	6	500	1
	WH02	F02		8	500	1
	WH03	F01		13	500	1
	WH03	F02		7	500	1
	
	F01 WH04 11 200 1
	F01 F03 19 200 1
	F02 WH04 6 800 1
	WH04 F03 15 2000 1


    F03 DC01 18 2000 1
    F03 WH05 11 2000 1
    F03 DC03 10 2000 1
    WH05 DC01 17 200 1
    WH05 DC02 9 100 1
    DC01 DC02 5 100 0
    DC02 DC03 8 100 0
    
    DC01 DEMAND_NODE 0 1000 0
    DC02 DEMAND_NODE 0 1000 0
    DC03 DEMAND_NODE 0 1000 0
;

param: MaxStorage HoldingCost :=
	S01 10000 0
	S02 10000 0
	WH01 100 2
	WH02 100 3
	WH03 250 5
	
	WH04 500 10
	
	WH05   500  15
    DC01   100  30
    DC02   100  50
    DC03   100  30
    
    DEMAND_NODE 10000 0
;

param StartingInventory :=

    WH05 FG01  0
    DC01 FG01 70
    DC02 FG01 100
    DC03 FG01 70
    WH04 IG01 0
    S01 RM01 1000
	S02 RM02 1000
	WH01 RM01 100
	WH02 RM02 100
	WH03 RM01 0
	WH03 RM02 0
	
;


solve;

display x;
display I;