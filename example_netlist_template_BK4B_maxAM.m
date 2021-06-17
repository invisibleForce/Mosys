%------------- Log -----------
% SPEC: Template to generate the netlist for multiple blocks
% Author: Lei
% Date: 8-1-16
% Function list:
% Coefficient: 
% Voltages: 
% Event: 1 setup
% Date: 11-1-16
% 1. Remove the Rs for INT rows which will form an erroneous function
% (outpout is always RL). See Logic Gate Space paper.
% 2. Modify the simulation time, it is not long enough. Add one more cycle
%------------- Log -----------
clc
clear
close

%-----------  Script parameters -----------%
SEQ = 1;

%-----------  Design Information -----------%
DESIGN = '4BAdder_BKSeq'; % Design Name
NR = 65; % No. of Rows
NC = 62; % No. of Columns
NS = 5; % No. of Stages: 1 gt, 2 & 3 prefix, 4 c, 5 s
NVDCTR = 2; % No. of control voltage signals
NIL = 1; % No. of IL
NINALL = 18; % Inputs for the design
NOUTALL = 10; % Outputs for the design
Vdd = 0.9;
NSTATE = 4; % 1 CFG, 2 EVN, 3 EVA, 4 INR
%-----------  Sim Paras -----------%
kilo = 1000;
fs = 100;
Vdd = 0.9;
RL = 100*kilo;
rR = fs*max([NR NC]);
rns = 0.1;
RH = rR*RL;
Rs = RL/rns;


%----------- Lib Formation -----------%
% input: unit CMTs
% output: a table describing all CMTs
% Unit list
% u1: AND, gi, t
% u2: OR, t
% u3: g
% u4: ci
% u5: si
unit_num = 4;

% AND, gi, t
u1 = [
1	1	2	2	2	2
];

% OR, t
u2 = [
1	1	2	2	2	2
];

% g
u3 = [
1	0	0	2	2	2	;
0	1	1	2	2	2		
];

% ci
u4 = [
0	1	0	2	2	2	;
1	0	1	2	2	2		
];

% si
u5 = [
1	0	0	1	0	1	;
0	1	0	1	1	0	;
0	1	1	0	0	1	;
1	0	1	0	1	0		
];



% Merge all units into one lib
Lib = [u1; u2; u3; u4; u5];
% Generate information of the lib
% Lib_Info: SA, Row, OL = Y/N
Lib_Info = [];
lib_sa = 1;
lib_row = 0;
lib_col = 0;
% info for unit 1
[lib_row lib_col] = size(u1);
Lib_Info = [Lib_Info; lib_sa lib_row 1];
lib_sa = lib_sa + lib_row;
% info for unit 2
[lib_row lib_col] = size(u2);
Lib_Info = [Lib_Info; lib_sa lib_row 0];
lib_sa = lib_sa + lib_row;
% info for unit 3
[lib_row lib_col] = size(u3);
Lib_Info = [Lib_Info; lib_sa lib_row 1];
lib_sa = lib_sa + lib_row;
% info for unit 4
[lib_row lib_col] = size(u4);
Lib_Info = [Lib_Info; lib_sa lib_row 1];
lib_sa = lib_sa + lib_row;
% info for unit 5
[lib_row lib_col] = size(u5);
Lib_Info = [Lib_Info; lib_sa lib_row 1];
Lib_Info

%----------- Block Info -----------%
% Item format
% Type | Output | OL | Inputs
%  1   |    1   | 1  |    7
% Design
% C1 - C2 - C3 - C4 - S0 - S1 - S2 - S3

Block_info = [
1	1	19	1	9	0	0	0	0	;
1	1	21	3	11	0	0	0	0	;
1	1	23	5	13	0	0	0	0	;
1	1	25	7	15	0	0	0	0	;
2	1	27	2	10	0	0	0	0	;
2	1	28	4	12	0	0	0	0	;
2	1	29	6	14	0	0	0	0	;
2	1	30	8	16	0	0	0	0	;
3	2	31	21	28	19	0	0	0	;
3	2	33	25	30	23	0	0	0	;
1	2	35	27	28	0	0	0	0	;
1	2	37	29	30	0	0	0	0	;
3	3	39	23	29	31	0	0	0	;
3	3	41	33	37	31	0	0	0	;
1	3	43	35	29	0	0	0	0	;
1	3	45	35	37	0	0	0	0	;
4	4	47	17	19	27	0	0	0	;
4	4	49	17	31	35	0	0	0	;
4	4	51	17	39	43	0	0	0	;
4	4	53	17	41	45	0	0	0	;
5	5	55	17	18	1	2	9	10	;
5	5	57	47	48	3	4	11	12	;
5	5	59	49	50	5	6	13	14	;
5	5	61	51	52	7	8	15	16	  
];
[blk_info_row blk_info_col] = size(Block_info);
% column info
% Stage | SA | LEN
% INDEX | 1  | 1
blk_cols = [
1 18;
19 12;
31 8;
39 8;
47 8;
55 8
]; 


%----------- Generate CMT -----------%
CMT = zeros(NR,NC);
row_cnt = 1;
% Update IL
CMT(1,1:NINALL) = 1;
row_cnt = row_cnt + 1;
% Update LBs
% input
% blk_num: number of blocks
% blk_row: number of rows for each block
% blk_col: number of columns for each block
blk_num = blk_info_row; 
blk_col = lib_col; % 6
% Addr for Lib Info
LIBBLKSA = 1;
LIBBLKLEN = 2;
LIBBLKOL = 3;
% Addr for Block info
BLKTYPE = 1;
BLKSTAGE = 2;
BLKOUT = 3;
BLKSIG = 4;
% Update CMT
for i = 1:blk_num,
    blk_row = Lib_Info(Block_info(i, BLKTYPE), LIBBLKLEN);
    blk_sa = Lib_Info(Block_info(i, BLKTYPE), LIBBLKSA);
    blk_ol = Lib_Info(Block_info(i, BLKTYPE), LIBBLKOL);
    blk_CMT = Lib(blk_sa:blk_sa + blk_row - 1, 1:end);
    % Build Partial results and output latches
    % Partial results
    if (blk_ol == 1)
        CMT(row_cnt: (row_cnt + blk_row - 1), Block_info(i, BLKOUT) + 1) = 1;
    else
        CMT(row_cnt: (row_cnt + blk_row - 1), Block_info(i, BLKOUT)) = 1;
    end
    % LB
    for j = 1:blk_row,
        for k = 1:blk_col,
            if (blk_CMT(j,k) == 1)
                CMT(row_cnt, Block_info(i, BLKSIG - 1 + k)) = 1;
            end
        end
        row_cnt = row_cnt + 1;
    end
    % OL
    if (blk_ol == 1)
        CMT((row_cnt), Block_info(i, BLKOUT) : Block_info(i, BLKOUT) + 1) = 1;
        row_cnt = row_cnt + 1;  
    end
end

%----------- Find max no. of active memristors in rows and columns -----------%
% Matlab: 
% sum(A) returns a vector containing the sums of each column
% sum(A') returns a vector containing the sums of each row
% Max(A): 
% If A is a vector, then max(A) returns the largest element of A.
% If A is a matrix, then max(A) is a row vector containing the maximum value of each column.
n_AM_col = sum(CMT)
n_AM_row = sum(CMT')

total_AVD_col_Am = sum(n_AM_col)*6
total_AVD_row_Am = sum(n_AM_row)*6
total_AVD_Am = total_AVD_col_Am + total_AVD_row_Am

total_AVD_Am = sum(sum(CMT))*6*2 % each memristor requires two VDs
total_Am = sum(sum(CMT))

total_AVD_Am/total_Am

%----------- Netlist print -----------%
ctrller_file_name = ['ctrl_',DESIGN,'.','va'];
volDriver_name = 'voltage_driver';
volDriver_file_name = [volDriver_name,'.','va'];
mrModel_name = 'memristor_digital_th';
mrModel_file_name = [mrModel_name,'.','va'];
%-----------  Print Control -----------% 
filenanme = [DESIGN,'.','sp'];
% t = clock;
% date = datestr(t);
fid1 = fopen(filenanme,'w');
%-----------  Print Title -----------% 
fprintf(fid1,'%s.CIR\n',DESIGN);
fprintf(fid1,'* ------------ Log ------------\n');
fprintf(fid1,'* SPEC: \n');
fprintf(fid1,'* Date: \n');
fprintf(fid1,'* Author: Lei\n');
fprintf(fid1,'* Version: \n');
fprintf(fid1,'* Modification: \n');
fprintf(fid1,'* Date: \n');
fprintf(fid1,'* \n');
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* -------------Params ---------\n');
fprintf(fid1,'.param Vdd = %.1fV\n',Vdd);
fprintf(fid1,'.param RL = %d\n',RL);
fprintf(fid1,'.param rR = %d\n',rR);
fprintf(fid1,'.param rns = %.1f\n',rns);
fprintf(fid1,'.param RH = %d\n',RH);
fprintf(fid1,'.param Rs = %d\n',Rs);
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* ------------ VA files ------------\n');
fprintf(fid1,'.hdl %s\n',ctrller_file_name);
fprintf(fid1,'.hdl %s\n',volDriver_file_name);
fprintf(fid1,'.hdl %s\n',mrModel_file_name);
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* ------------ Include ------------\n');
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* ------------ SUBCKT ------------\n');
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* ------------ CKT Schematic ------------\n');
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

%-----------  Print Controller -----------% 
fprintf(fid1,'* ------------ CKT ------------\n');
fprintf(fid1,'* Control logic\n');
fprintf(fid1,'X1 en clk state clk_edge\n');
% Rows
for i = 1:NR,
    fprintf(fid1,'+ ctrlh%d ctrlh%d\n',2*(i-1),2*(i-1)+1); 
end
% Columns
for i = 1:NC,
    fprintf(fid1,'+ ctrlv%d ctrlv%d\n',2*(i-1),2*(i-1)+1); 
end
fprintf(fid1,'+ ctrl_%s\n',DESIGN);
fprintf(fid1,'* \n');

%-----------  Print Voltage Driver -----------% 
fprintf(fid1,'* Voltage driver\n');
fprintf(fid1,'*module voltage_driver(vd_ctrl,out); vd_ctrl [0:%d]\n',NVDCTR);
fprintf(fid1,'* Rows\n');
for i = 1:NR,
    fprintf(fid1,'XVDR%d ctrlh%d ctrlh%d LH%d %s\n',i,2*(i-1),2*(i-1)+1,i,volDriver_name); 
end
fprintf(fid1,'\n');

fprintf(fid1,'* Columns\n');
for i = 1:NC,
    fprintf(fid1,'XVDC%d ctrlv%d ctrlv%d LV%d %s\n',i,2*(i-1),2*(i-1)+1,i,volDriver_name); 
end
fprintf(fid1,'* \n');

%-----------  Print Crossbar -----------% 

fprintf(fid1,'* Xbar\n');
for i = 1:NR,
  fprintf(fid1,'* LH%d\n',i);  
  for j = 1:NC,
      if (CMT(i,j) == 1)
          fprintf(fid1,'XMH%dV%d LV%d LH%d mrxH%dV%d 0 %s\n',i,j,j,i,i,j,mrModel_name);
      else
          fprintf(fid1,'RH%dV%d LV%d LH%d RH\n',i,j,j,i);
      end
  end
  fprintf(fid1,'\n');
end

%-----------  Print Rs -----------% 
fprintf(fid1,'* Rs\n');
fprintf(fid1,'* Rows\n');
% Rows
for i = 1:NR,
	fprintf(fid1,'RSH%d LH%d 0 Rs\n',i,i);
end
fprintf(fid1,'\n');

fprintf(fid1,'* Columns\n');
for i = 1:NC,
    fprintf(fid1,'RSC%d LV%d 0 Rs\n',i,i); 
end


fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');


fprintf(fid1,'* ------------ STI ------------\n');
clk_T = 2;
skew_ratio = 0.01;
NSTATE_ONCE = 4;  % IDLE, INI, RI, CFG
fprintf(fid1,'Ven en 0 PWL(0 0 %.2fs 0 %.2fs Vdd %.2fs Vdd %.2fs 0)\n',clk_T*skew_ratio,clk_T*skew_ratio + clk_T*skew_ratio,(2 + 2 + NS*NSTATE)*clk_T,(2 + 2 + NS*NSTATE + skew_ratio)*clk_T);
fprintf(fid1,'Vclk clk 0 PULSE(0 Vdd 0 %.2fs %.2fs %.2fs %.2fs)\n',clk_T*skew_ratio,clk_T*skew_ratio,clk_T/2,clk_T);
fprintf(fid1,'* -----------------------------\n');
fprintf(fid1,'* \n');

fprintf(fid1,'* ------------ SIM CFG ------------\n');
fprintf(fid1,'.options post\n');
fprintf(fid1,'.tran %.2fs %.2fs\n', clk_T*skew_ratio, (2 + 2 + NS*NSTATE + skew_ratio)*clk_T);
fprintf(fid1,'.end\n');

fclose(fid1);



% % fprintf(fid1,'-ES2AS\n');
% % fprintf(fid1,'v1\tv2\tv3\n');
% % fprintf(fid1,[repnmat('%1.4f\t', 1, size(vlh_eae, 2)) '\n'], vlh_eae');
% % fprintf(fid1,[repnmat('%1.4f\t', 1, size(pvlh_eae, 2)) '\n'], pvlh_eae');

