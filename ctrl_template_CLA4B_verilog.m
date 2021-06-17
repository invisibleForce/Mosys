%------------- Log -----------
% SPEC: Template to generate the control logic 
% for synthesis
% Author: Lei
% Function list:
% Coefficient: 
% Voltages: 
% Date: 12-1-16
% 1. setup
%------------- Log -----------
clc
clear
close

%-----------  Script parameters -----------%
SEQ = 1;
PARA = 2;

%-----------  Design Information -----------%
DESIGN = '4BAdder_CLASeq'; % Design Name
NR = 53; % No. of Rows
NC = 34; % No. of Columns
NS = 2; % No. of Stages
MODE = SEQ; % seq = 1, para = 2;
NVDCTR = 3; % No. of control voltage signals
            % Three transistors:
            % 3 2 1
            % 0 0 1 W 1
            % 0 1 0 H 2
            % 1 0 0 G 4
            % 0 0 0 F 0
NIL = 1;
NBIT = 4; % No. of input bits
NIO = [18 6 10]; % No. of Inputs Outputs in each stage: IN, IM1, IM2, ..., OUT
                % It can be seen as IM0 = IN, IM1, IM2, ... IM(NS) = OUT
Block_info = [
1  1	19		17	1	9	0	0	0	0	;
2  1	21		17	1	9	3	11	0	0	;
3  1	23		17	1	9	3	11	5	13	;
1  2	25		23	7	15	0	0	0	0	;
4  2	27		17	18	1	2	9	10	0	;
4  2	29		19	20	3	4	11	12	0	;
4  2	31		21	22	5	6	13	14	0	;
4  2	33		23	24	7	8	15	16	0	  
];

Vdd = 0.9;
NSTATE = 4; % 1 CFG, 2 EVN, 3 EVA, 4 INR
INPUT = [0 1 2]; % C0, X and Y in decimal, the input width is 4 bit
C0_bin = dec2bin(INPUT(1),1);
X_bin = dec2bin(INPUT(2),NBIT);
Y_bin = dec2bin(INPUT(3),NBIT);

%-----------  Row and Column information -----------%
%----------- Lib Formation -----------%
% input: unit CMTs
% output: a table describing all CMTs
% Unit list
% u1: c1,4
% u2: c2
% u3: c3
% u4: si
unit_num = 4;

% c1,4
u1 = [
0	1	1	2	2	2	2	;
1	1	0	2	2	2	2	;
1	0	1	2	2	2	2	
];

% c2
u2 = [
0	0	0	1	1	2	2	;
0	1	1	1	0	2	2	;
0	1	1	0	1	2	2	;
1	1	0	1	0	2	2	;
1	1	0	0	1	2	2	;
1	0	1	1	0	2	2	;
1	0	1	0	1	2	2	
];

% c3
u3 = [
0	0	0	0	0	1	1	;
0	0	0	1	1	1	0	;
0	0	0	1	1	0	1	;
0	1	1	1	0	1	0	;
0	1	1	1	0	0	1	;
0	1	1	0	1	1	0	;
0	1	1	0	1	0	1	;
1	1	0	1	0	1	0	;
1	1	0	1	0	0	1	;
1	1	0	0	1	1	0	;
1	1	0	0	1	0	1	;
1	0	1	1	0	1	0	;
1	0	1	1	0	0	1	;
1	0	1	0	1	1	0	;
1	0	1	0	1	0	1		
];

% si
u4 = [
1	0	0	1	0	1	2	;
0	1	0	1	1	0	2	;
0	1	1	0	0	1	2	;
1	0	1	0	1	0	2		
];

% Merge all units into one lib
Lib = [u1; u2; u3; u4];
% Generate information of the lib
Lib_Info = [];
lib_sa = 1;
lib_row = 0;
lib_col = 0;
% info for unit 1
[lib_row lib_col] = size(u1);
Lib_Info = [Lib_Info; lib_sa lib_row];
lib_sa = lib_sa + lib_row;
% info for unit 2
[lib_row lib_col] = size(u2);
Lib_Info = [Lib_Info; lib_sa lib_row];
lib_sa = lib_sa + lib_row;
% info for unit 3
[lib_row lib_col] = size(u3);
Lib_Info = [Lib_Info; lib_sa lib_row];
lib_sa = lib_sa + lib_row;
% info for unit 4
[lib_row lib_col] = size(u4);
Lib_Info = [Lib_Info; lib_sa lib_row];
Lib_Info

% Input 
Block_info = [
1  1	19		17	1	9	0	0	0	0	;
2  1	21		17	1	9	3	11	0	0	;
3  1	23		17	1	9	3	11	5	13	;
1  2	25		23	7	15	0	0	0	0	;
4  2	27		17	18	1	2	9	10	0	;
4  2	29		19	20	3	4	11	12	0	;
4  2	31		21	22	5	6	13	14	0	;
4  2	33		23	24	7	8	15	16	0	  
];
% Row info
% Stage | SA | LEN
% 1     | 1  | 1
blk_rows = []; 
blk_stage = 0;
row_cnt = NIL + 1;
blk_sa = 0;
blk_len = 0;
BLKTYPE = 1;
BLKSTAGE = 2;
LIBINFOLEN = 2;
[blk_num blk_width] = size(Block_info);
for i = 1:blk_num,
    blk_stage = Block_info(i,BLKSTAGE);
    blk_sa = row_cnt;
    blk_len = Lib_Info(Block_info(i,BLKTYPE),LIBINFOLEN);
    blk_rows = [blk_rows; blk_stage blk_sa blk_len]; 
    % update row cnt
    row_cnt = row_cnt + blk_len + 1;
end
blk_rows

% column info
% Stage | SA | LEN
% INDEX | 1  | 1
blk_cols = [
1 18;
19 6;
25 10
]; 

%-----------  Print Control -----------% 
filenanme = ['ctrl','_',DESIGN,'.','v'];
% t = clock;
% date = datestr(t);
fid1 = fopen(filenanme,'w');
fprintf(fid1,'//-------------------- Log -------------------\n');
fprintf(fid1,'// Date:\n'); 
fprintf(fid1,'// Version: \n');
fprintf(fid1,'// Event: \n');
fprintf(fid1,'//-------------------- Log -------------------\n');
fprintf(fid1,'\n');
fprintf(fid1,'/**********************************************\n');
fprintf(fid1,'//          Module Declaration \n');
fprintf(fid1,'**********************************************/\n');
fprintf(fid1,'`timescale 1ns/1ps\n');
fprintf(fid1,'\n');
fprintf(fid1,'module ctrl_%s(en,rst,clk,state,ctrlh,ctrlv);\n',DESIGN); 
fprintf(fid1,'\n');
%---------- Parameters
fprintf(fid1,'// Parameters\n');
fprintf(fid1,'// Circuit\n');
fprintf(fid1,'parameter integer NR = %d;                   // number of voltage drivers in row\n',NR);
fprintf(fid1,'parameter integer NC = %d;                   // number of voltage drivers in column\n',NC);
fprintf(fid1,'parameter integer NVDCTRLW = %d;   // each voltage driver has 9 states, bit width of control signal\n',NVDCTR);
fprintf(fid1,'parameter integer NRCTRLW = NR*NVDCTRLW;  // %d voltage driver\n', NR);
fprintf(fid1,'parameter integer NCCTRLW = NC*NVDCTRLW;  // %d voltage drivers\n', NC);
fprintf(fid1,'// state machnie\n');
% State number parameters
fprintf(fid1,'parameter integer SIDLE = 0;    // idle state\n');
fprintf(fid1,'parameter integer SINI = 1;       // all latches open\n');
fprintf(fid1,'parameter integer SRI = 2;        // all receive inputs\n');
cnt = 0;
for i = 1:NS,
    fprintf(fid1,'parameter integer SCFG_%d = %d;      // Configure all NANDs\n',i,3 + NSTATE*(i - 1));
    fprintf(fid1,'parameter integer SEVN_%d = %d;      // Evaluate NAND\n',i,4 + NSTATE*(i - 1));
    fprintf(fid1,'parameter integer SEVA_%d = %d;      // Evaulate AND\n',i,5 + NSTATE*(i - 1));
    fprintf(fid1,'parameter integer SINR_%d = %d;      // Evaulate INV\n',i,6 + NSTATE*(i - 1));
end
fprintf(fid1,'parameter integer SSO = %d;        // Send outputs\n', 2 + NS*NSTATE + 1);
STCNT = 3 + NS*NSTATE + 1;
BITST = ceil(log2(STCNT));
fprintf(fid1,'parameter integer BITST = %d;        // state bits\n',BITST);
fprintf(fid1,'// ctrl line states\n');
fprintf(fid1,'// Used for 3T voltage driver\n');
fprintf(fid1,'parameter integer CF = 0;      // voltage driver is floating\n');
fprintf(fid1,'parameter integer CW = 1;     // voltage driver is Vw\n');
fprintf(fid1,'parameter integer CH = 2;     // voltage driver is Vh\n');
fprintf(fid1,'parameter integer CG = 4;    // voltage driver is GND\n');
fprintf(fid1,'\n');
%---------- IO and variables
fprintf(fid1,'// IO\n');
fprintf(fid1,'input en;\n');
fprintf(fid1,'input rst;\n');
fprintf(fid1,'input clk;\n');
fprintf(fid1,'output reg [0:NRCTRLW-1] ctrlh;\n');
fprintf(fid1,'output reg [0:NCCTRLW-1] ctrlv;\n');
fprintf(fid1,'output [0: BITST - 1] state;\n');
fprintf(fid1,'// Variables\n');
fprintf(fid1,'reg [0: BITST-1] st;\n');
fprintf(fid1,'// Other Variables\n');
%fprintf(fid1,'integer f;\n');
fprintf(fid1,'\n');
%---------- Print result ini
sim_clk = 10;
sim_time = (2 + 2 + NS*NSTATE + 1)*sim_clk;
% fprintf(fid1,'// File print initialization\n');
% fprintf(fid1,'initial\n');
% fprintf(fid1,'begin \n');
% fprintf(fid1,'f = $fopen("output_nsyn.txt");\n');
% fprintf(fid1,'  #%d $fclose(f);\n',sim_time);
% fprintf(fid1,'  $stop;\n');
% fprintf(fid1,'end\n');
%---------- Always
fprintf(fid1,'always @ (posedge clk or negedge rst)\n');
fprintf(fid1,'  if(!rst)\n');
fprintf(fid1,'  begin\n');
fprintf(fid1,'    st<=SIDLE;\n');
fprintf(fid1,'  end\n');
fprintf(fid1,'  else\n');
fprintf(fid1,'    begin      \n');  
fprintf(fid1,'//State mechine\n'); 
% Case
fprintf(fid1,'case(st)\n');
% SIDLE
% Print Item
fprintf(fid1,'SIDLE: \n');
fprintf(fid1,'begin\n');
fprintf(fid1,'//update state\n');
fprintf(fid1,'if((en == 1)) st <= SINI;\n');
fprintf(fid1,'else st <= SIDLE;\n');
fprintf(fid1,'//update output\n');
fprintf(fid1,'//horizontal\n');
% INI & Determine CVs
CVR_INI = 'CF';
CVC_INI = 'CF';
ctrlh = [];
ctrlv = [];
% Row
for i = 1:NR,
    ctrlh = [ctrlh;CVR_INI];
end
% Column
for i = 1:NC,
    ctrlv = [ctrlv;CVC_INI];
end
% Print CVs
for i = 1:NR,
    fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', i - 1, i, ctrlh(i,:));
end
fprintf(fid1,'\n');
fprintf(fid1,'// vertical\n');
for i = 1:NC,
    fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', i - 1, i, ctrlv(i,:));
end
fprintf(fid1,'end\n');
fprintf(fid1,'\n');

% SINI
% Print Item
fprintf(fid1,'SINI: \n');
fprintf(fid1,'begin\n');
fprintf(fid1,'//update state\n');
fprintf(fid1,'st <= SRI;\n');
fprintf(fid1,'// update output\n');
fprintf(fid1,'// horizontal\n');
% INI & Determine CVs
CVR_INI = 'CW';
CVC_INI = 'CG';
ctrlh = [];
ctrlv = [];
% Row
for i = 1:NR,
    ctrlh = [ctrlh;CVR_INI];
end
% Column
for i = 1:NC,
    ctrlv = [ctrlv;CVC_INI];
end
% Print CVs
for i = 1:NR,
    fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', i - 1, i, ctrlh(i,:));
end
fprintf(fid1,'\n');
fprintf(fid1,'// vertical\n');
for i = 1:NC,
    fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', i - 1, i, ctrlv(i,:));
end
fprintf(fid1,'end\n');
fprintf(fid1,'\n');

% --------- SRI ---------%
% Print Item
fprintf(fid1,'SRI: \n');
fprintf(fid1,'begin\n');
fprintf(fid1,'//update state\n');
fprintf(fid1,'st <= SCFG_%d;\n',1);
% NIO = [18 6 10]; % No. of Inputs Outputs in each stage: IN, IM1, IM2, ..., OUT
                % It can be seen as IM0 = IN, IM1, IM2, ... IM(NS) = OUT
% INI CVs
CVR_INI = 'CH';
CVC_INI = 'CH';
ctrlh = [];
ctrlv = [];
% Row
for j = 1:NR,
	ctrlh = [ctrlh;CVR_INI];
end
% Column
for j = 1:NC,
	ctrlv = [ctrlv;CVC_INI];
end
    
% Determine CVs
% Columns
for j = 1:blk_cols(1,2),
    ctrlv(j,:) = 'CF';
end

% Rows
% IL
ctrlh(NIL,:) = 'CG';

% Print CVs
% Row
for j = 1:NR,
	fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j, ctrlh(j,:));
end
% Column
fprintf(fid1,'// vertical\n');
for j = 1:NC,
	fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j, ctrlv(j,:));
end
fprintf(fid1,'end\n');
fprintf(fid1,'\n'); 


for i = 1:NS,
% --------- SCFG ---------%
% Print Item
fprintf(fid1,'SCFG_%d: \n',i);
fprintf(fid1,'begin\n');
fprintf(fid1,'//update state\n');
fprintf(fid1,'st <= SEVN_%d;\n',i);
% INI CVs
CVR_INI = 'CH';
CVC_INI = 'CH';
ctrlh = [];
ctrlv = [];
% Row
for j = 1:NR,
    ctrlh = [ctrlh;CVR_INI];
end
% Column
for j = 1:NC,
    ctrlv = [ctrlv;CVC_INI];
end
    
% Determine CVs
% Rows
% IL or OL
[m n] = size(blk_rows);
if (i == 1)
    ctrlh(NIL,:) = 'CW';
else
    for k = 1:m,
        if (blk_rows(k,1) == (i - 1)) % check stage
            ctrlh( blk_rows(k,2) + blk_rows(k,3), : ) = 'CW'; % OL is W
        end 
    end
end

% LBs
for k = 1:m,
    if (blk_rows(k,1) >= i)
        for j = 1:blk_rows(k,3),
            ctrlh(blk_rows(k,2) + j - 1, : ) = 'CG';
        end   
    end
end 

% Columns
% IN columns 
if (i == 1)
    for j = 1:blk_cols(i,2),
        ctrlv(blk_cols(i,1) + j - 1,:) = 'CF';
    end
else
    for j = 1:blk_cols(i,2)/2,
        ctrlv(blk_cols(i,1) + 2*(j - 1),:) = 'CF';
    end
end


% Print CVs
% Row
for j = 1:NR,
    fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
end
% Column
fprintf(fid1,'// vertical\n'); 
for j = 1:NC,
    fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
end
fprintf(fid1,'end\n');
fprintf(fid1,'\n');

% --------- SEVN_%d ---------%
    % SEVN_%d
    % Print Item
    fprintf(fid1,'SEVN_%d: \n',i);
    fprintf(fid1,'begin\n');
    fprintf(fid1,'//update state\n');
    fprintf(fid1,'st <= SEVA_%d;\n',i);
    % INI CVs
    CVR_INI = 'CH';
    CVC_INI = 'CH';
    ctrlh = [];
    ctrlv = [];
    % Row
    for j = 1:NR,
        ctrlh = [ctrlh;CVR_INI];
    end
    % Column
    for j = 1:NC,
        ctrlv = [ctrlv;CVC_INI];
    end
    
    % Determine CVs
% Rows
% IL or OL
[m n] = size(blk_rows);
% LBs
for k = 1:m,
    if (blk_rows(k,1) == i) % stage check
        for j = 1:blk_rows(k,3), % all rows
            ctrlh(blk_rows(k,2) + j - 1, : ) = 'CF';
        end
    end
end

% Columns
% OUT columns 

    for j = 1:blk_cols(i + 1,2)/2,
        ctrlv(blk_cols(i + 1,1) + 2*(j - 1) + 1,:) = 'CW';
    end

    
    
    
    % Print CVs
    % Row
    for j = 1:NR,
        fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
    end
    % Column
    fprintf(fid1,'// vertical\n');
    for j = 1:NC,
        fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
    end
    fprintf(fid1,'end\n');
    fprintf(fid1,'\n');

% --------- SEVA_%d ---------%
    % Print Item
    fprintf(fid1,'SEVA_%d: \n',i);
    fprintf(fid1,'begin\n');
    fprintf(fid1,'//update state\n');
    fprintf(fid1,'st <= SINR_%d;\n',i);
    
    % INI CVs
    CVR_INI = 'CH';
    CVC_INI = 'CH';
    ctrlh = [];
    ctrlv = [];
    % Row
    for j = 1:NR,
        ctrlh = [ctrlh;CVR_INI];
    end
    % Column
    for j = 1:NC,
        ctrlv = [ctrlv;CVC_INI];
    end
    
    % Determine CVs
% Rows
[m n] = size(blk_rows);
% LBs
for k = 1:m,
    if (blk_rows(k,1) == i) % stage check
        % Current stage LBs
        for j = 1:blk_rows(k,3), % all rows
            ctrlh(blk_rows(k,2) + j - 1, : ) = 'CW';
        end
        % Current stage OLs
        ctrlh(blk_rows(k,2) + blk_rows(k,3), : ) = 'CG';
    elseif(blk_rows(k,1) > i)
        % Downstream LBs
        for j = 1:blk_rows(k,3), % all rows
            ctrlh(blk_rows(k,2) + j - 1, : ) = 'CG';
        end
    end
end

% Columns
% Complementary OUT columns 
    for j = 1:blk_cols(i + 1,2)/2, 
        ctrlv(blk_cols(i + 1,1) + 2*(j - 1) + 1,:) = 'CF';
    end    
    
    % Print CVs
    % Row
    for j = 1:NR,
        fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
    end
    % Column
    fprintf(fid1,'// vertical\n');
    for j = 1:NC,
        fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
    end
    fprintf(fid1,'end\n');
    fprintf(fid1,'\n');

    % --------- SEVA_%d ---------%
    % Print Item
    fprintf(fid1,'SINR_%d: \n',i);
    fprintf(fid1,'begin\n');
    fprintf(fid1,'//update state\n');
    if (i < NS)
        fprintf(fid1,'st <= SCFG_%d;\n',i + 1);
    else
        fprintf(fid1,'st <= SSO;\n');
    end
    % INI CVs
    CVR_INI = 'CH';
    CVC_INI = 'CH';
    ctrlh = [];
    ctrlv = [];
    % Row
    for j = 1:NR,
        ctrlh = [ctrlh;CVR_INI];
    end
    % Column
    for j = 1:NC,
        ctrlv = [ctrlv;CVC_INI];
    end
    
    % Determine CVs
% Rows
[m n] = size(blk_rows);
% Current OLs
for k = 1:m,
    if (blk_rows(k,1) == i) % stage check
        % Current stage OLs
        ctrlh(blk_rows(k,2) + blk_rows(k,3), : ) = 'CF';
    end
end

% Columns
% Primary OUT columns 
    for j = 1:blk_cols(i + 1,2)/2, 
        ctrlv(blk_cols(i + 1,1) + 2*(j - 1),:) = 'CW';
    end    

    
    % Print CVs
    % Row
    for j = 1:NR,
        fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
    end
    % Column
    fprintf(fid1,'// vertical\n');
    for j = 1:NC,
        fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
    end
    fprintf(fid1,'end\n');
    fprintf(fid1,'\n');
    
end

% --------- SSO ---------%
    % Print Item
    fprintf(fid1,'SSO: \n');
    fprintf(fid1,'begin\n');
    fprintf(fid1,'//update state\n');
    fprintf(fid1,'st <= SIDLE;\n');
    
    % INI CVs
    CVR_INI = 'CH';
    CVC_INI = 'CH';
    ctrlh = [];
    ctrlv = [];
    % Row
    for j = 1:NR,
        ctrlh = [ctrlh;CVR_INI];
    end
    % Column
    for j = 1:NC,
        ctrlv = [ctrlv;CVC_INI];
    end
    
    % Determine CVs
% Rows
[m n] = size(blk_rows);
% Current LBs
for k = 1:m,
    if (blk_rows(k,1) == NS) % stage check
        for j = 1:blk_rows(k,3),
            ctrlh(blk_rows(k,2) + j - 1, : ) = 'CW';
        end
    end
end
% Current OLs
for k = 1:m,
    if (blk_rows(k,1) == NS) % stage check
        ctrlh(blk_rows(k,2) + blk_rows(k,3), : ) = 'CW';
    end
end

% Columns
% Primary OUT columns 
    for j = 1:blk_cols(NS + 1,2), 
        ctrlv(blk_cols(NS + 1,1) + j - 1,:) = 'CF';
    end    

    
    % Print CVs
    % Row
    for j = 1:NR,
        fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
    end
    % Column
    fprintf(fid1,'// vertical\n');
    for j = 1:NC,
        fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
    end
    fprintf(fid1,'end\n');
    fprintf(fid1,'\n');

% Default
% Print Item
fprintf(fid1,'default: \n');
fprintf(fid1,'begin\n');
fprintf(fid1,'//update state\n');
fprintf(fid1,'st <= SIDLE;\n');
% INI CVs
CVR_INI = 'CF';
CVC_INI = 'CF';
ctrlh = [];
ctrlv = [];
% Row
for j = 1:NR,
    ctrlh = [ctrlh;CVR_INI];
end
% Column
for j = 1:NC,
    ctrlv = [ctrlv;CVC_INI];
end
% Print CVs
% Row
for j = 1:NR,
    fprintf(fid1,'    ctrlh[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlh(j,:));
end
% Column
fprintf(fid1,'// vertical\n');
for j = 1:NC,
    fprintf(fid1,'    ctrlv[%d*NVDCTRLW : %d*NVDCTRLW - 1]  <= %s;  \n', j - 1, j,ctrlv(j,:));
end
fprintf(fid1,'end\n');
fprintf(fid1,'endcase\n');
fprintf(fid1,'\n');

% fprintf(fid1,'// State\n');
% fprintf(fid1,'  $fstrobe(f,"time: %%f\\tstate %%d\\n" , $time, st);\n');
% fprintf(fid1,'  // Ctrlh 0 - %d                    \n', NR);
% fprintf(fid1,'  $fstrobe(f,"time: %%f\\tCTRL_H %%o\\n" , $time, ctrlh);\n');
% fprintf(fid1,'  // Ctrlv 0 - %d\n', NC);
% fprintf(fid1,'  $fstrobe(f,"time: %%f\\tCTRL_V %%o\\n" , $time, ctrlv);\n');
fprintf(fid1,'    end //clk_pedge_s \n');
fprintf(fid1,'assign state = st; \n');
fprintf(fid1,'\n');
fprintf(fid1,'endmodule\n');
fclose(fid1);
