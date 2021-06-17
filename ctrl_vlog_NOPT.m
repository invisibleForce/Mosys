%------------- Log -----------
% SPEC: Template to generate the control logic for Mon-OP in SEQ mode
% Author: Lei
% Function list:
% Coefficient: 
% Voltages: 
% Date: 24-1-16
% 1 Setup 
%------------- Log -----------
clc
clear all
close all


%-----------  Design Information -----------%
NS = 1:13;
NSTATE = 7; % 1 RIN, 2 CFM, 3 EVM, 4 GER, 5  INR, 6 SOU, 7 TRD
NCTRL = 2; % No. of control voltage signals
for i = 1:length(NS) % for a specific Ns
    ctrlFileName = ['.\ctrl\NOPT_ctrl_',num2str(NS(i)),'.v']; % Ctrl name
    fid1 = fopen(ctrlFileName,'w');
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
    fprintf(fid1,'module ctrl_%d(en,rst,clk,state,rIN,rINT,rIL,rLB,rOL,cIN,cIL,cIMN,cIM);\n',NS(i)); 
    fprintf(fid1,'\n');
    %---------- Parameters
    fprintf(fid1,'// Parameters\n');
    fprintf(fid1,'// Circuit\n');
    fprintf(fid1,'parameter integer NS = %d;                   // number of stages\n',NS(i));
    fprintf(fid1,'parameter integer NCTRL = %d;   // each voltage driver has 4 states, bit width of control signal\n',NCTRL);
    fprintf(fid1,'// state machnie\n');
    % State number parameters
    fprintf(fid1,'parameter integer SIDLE = 0;      // idle state\n');
    fprintf(fid1,'parameter integer SINI = 1;       // initial all memristors\n');
    fprintf(fid1,'parameter integer SGIN = 2;       // Receive global inputs\n');
    fprintf(fid1,'parameter integer SGTR = 3;       // Spread global inputs\n');
    fprintf(fid1,'parameter integer SIN = 4;        // receive inputs\n');
    fprintf(fid1,'parameter integer SCFG = 5;       // Configure all NANDs\n');
    fprintf(fid1,'parameter integer SNAND = 6;      // Evaluate NAND\n');
    fprintf(fid1,'parameter integer SAND = 7;       // Evaulate AND\n');
    fprintf(fid1,'parameter integer SINV = 8;       // Evaulate INV\n');
    fprintf(fid1,'parameter integer SOUT = 9;       // Send Output\n');
    fprintf(fid1,'parameter integer STRD = 10;       // Transfer in INT\n');
    STATECNT = 4 + NSTATE;
    BITSTATE = ceil(log2(STATECNT));
    fprintf(fid1,'parameter integer BITSTATE = %d;        // state bits\n',BITSTATE);
    STAGECNT = NS(i);
    BITSTAGE = ceil(log2(STAGECNT) + 1);
    fprintf(fid1,'parameter integer BITSTAGE = %d;        // stage bits\n',BITSTAGE);
    fprintf(fid1,'// ctrl line states\n');
    fprintf(fid1,'// Used for voltage driver\n');
    fprintf(fid1,'parameter integer CF0 = 0;      // voltage driver is floating\n');
    fprintf(fid1,'parameter integer CF1 = 0;      // voltage driver is floating\n');
    fprintf(fid1,'parameter integer CW0 = 1;      // voltage driver is Vw\n');
    fprintf(fid1,'parameter integer CW1 = 0;      // voltage driver is Vw\n');
    fprintf(fid1,'parameter integer CH0 = 0;      // voltage driver is Vh\n');
    fprintf(fid1,'parameter integer CH1 = 1;      // voltage driver is Vh\n');
    fprintf(fid1,'parameter integer CG0 = 1;      // voltage driver is GND\n');
    fprintf(fid1,'parameter integer CG1 = 1;      // voltage driver is GND\n');
    fprintf(fid1,'\n');
    %---------- IO and variables
    fprintf(fid1,'// IO\n');
    fprintf(fid1,'input en;\n');
    fprintf(fid1,'input rst;\n');
    fprintf(fid1,'input clk;\n');
    fprintf(fid1,'// Rows\n');
    fprintf(fid1,'output reg [NCTRL-1:0] rIN;      // IN\n');
    fprintf(fid1,'output reg [NCTRL-1:0] rINT;    // INT\n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] rIL; // IL \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] rLB; // LB \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] rOL; // OL\n');
    fprintf(fid1,'// Cols\n');
    fprintf(fid1,'output reg [NCTRL-1:0] cIN;     // IN \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] cIL; // IL \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] cIMN; // IMN \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] cIM;  // IM \n');
    fprintf(fid1,'output [0: BITSTATE - 1] state;\n');
    fprintf(fid1,'// Variables\n');
    fprintf(fid1,'reg [0: BITSTATE-1] cs;   // current state  \n');
    fprintf(fid1,'reg [0: BITSTATE-1] ns;   // next state  \n');
    if(BITSTAGE == 1)
        fprintf(fid1,'reg cnt;  // stage \n');
    else
        fprintf(fid1,'reg [0: BITSTAGE-1] cnt;  // stage \n');
    end
    
    
    %fprintf(fid1,'integer f;\n');
    fprintf(fid1,'\n');
    % state machine
    % -----------
    % cs: current state
    % -----------
    fprintf(fid1,'//-------------------- Current state -------------------\n');
    fprintf(fid1,'always @ (posedge clk or negedge rst)\n');
    fprintf(fid1,'  if(!rst)\n');
    fprintf(fid1,'    cs <= SIDLE;\n');
    fprintf(fid1,'  else\n');
    fprintf(fid1,'    cs <= ns;\n');
    fprintf(fid1,'\n');
    % -----------
    % ns: next state
    % -----------
    fprintf(fid1,'//-------------------- Next state -------------------\n');
    fprintf(fid1,'always @ (cs or en or cnt)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SIDLE
    fprintf(fid1,'      SIDLE: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          if((en == 1)) ns = SINI;\n');
    fprintf(fid1,'          else ns = SIDLE;\n');
    fprintf(fid1,'          end\n');
    % SINI
    fprintf(fid1,'      SINI: ns = SGIN;\n');
    % SGIN
    fprintf(fid1,'      SGIN: ns = SGTR;\n');
    % SGTR
    fprintf(fid1,'      SGTR: ns = SIN;\n');
    % SIN
    fprintf(fid1,'      SIN: ns = SCFG;\n');
    % SCFG
    fprintf(fid1,'      SCFG: ns = SNAND;\n');
    % SNAND
    fprintf(fid1,'      SNAND: ns = SAND;\n');
    % SAND
    fprintf(fid1,'      SAND: ns = SINV;\n');
    % SINV
    fprintf(fid1,'      SINV: ns = SOUT;\n');
    % SOUT
    fprintf(fid1,'      SOUT: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          if((cnt < NS)) ns = STRD;\n');
    fprintf(fid1,'          else \n');    
    fprintf(fid1,'              begin\n');
    fprintf(fid1,'                  if((en == 1)) ns = SINI;\n');                                
    fprintf(fid1,'                  else ns = SIDLE;\n');
    fprintf(fid1,'              end\n'); 
    fprintf(fid1,'          end\n');    
    % STRD
    fprintf(fid1,'      STRD:  ns = SIN;\n');
    % default
    fprintf(fid1,'      default: ns = SIDLE;\n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
    % -----------
    % stage cnt
    % -----------
    fprintf(fid1,'//-------------------- Stage counter -------------------\n');
    fprintf(fid1,'always @ (posedge clk)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SINI
    fprintf(fid1,'      SINI: cnt <= 0;\n');
    % SIN
    fprintf(fid1,'      SIN: cnt <= cnt + 1;\n');
    % default
    fprintf(fid1,'      default: cnt <= cnt; \n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
    
    % -----------
    % output signals
    % -----------
    fprintf(fid1,'//-------------------- Row -------------------\n');
    % -----------
    % rIN
    % -----------
    fprintf(fid1,'//-------------------- rIN -------------------\n');
    fprintf(fid1,'always @ (cs or cnt)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SIDLE
    fprintf(fid1,'      SIDLE: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CF0; \n');
    fprintf(fid1,'          rIN[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SINI
    fprintf(fid1,'      SINI: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CW0; \n');
    fprintf(fid1,'          rIN[1] = CW1; \n');
    fprintf(fid1,'          end\n');
    % SGIN
    fprintf(fid1,'      SGIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CG0; \n');
    fprintf(fid1,'          rIN[1] = CG1; \n');
    fprintf(fid1,'          end\n');
    % SGTR
    fprintf(fid1,'      SGTR: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CF0; \n');
    fprintf(fid1,'          rIN[1] = CF1; \n');
    fprintf(fid1,'          end\n');    
    % SIN
    fprintf(fid1,'      SIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CW0; \n');
    fprintf(fid1,'          rIN[1] = CW1; \n');
    fprintf(fid1,'          end\n');
    % default
    fprintf(fid1,'      default:\n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIN[0] = CH0; \n');
    fprintf(fid1,'          rIN[1] = CH1; \n');
    fprintf(fid1,'          end\n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
    
    % -----------
    % rINT
    % -----------
    fprintf(fid1,'//-------------------- rINT -------------------\n');
    fprintf(fid1,'always @ (cs or cnt)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SIDLE
    fprintf(fid1,'      SIDLE: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CF0; \n');
    fprintf(fid1,'          rINT[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SINI
    fprintf(fid1,'      SINI: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CW0; \n');
    fprintf(fid1,'          rINT[1] = CW1; \n');
    fprintf(fid1,'          end\n');
    % SIN
    fprintf(fid1,'      SIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CW0; \n');
    fprintf(fid1,'          rINT[1] = CW1; \n');
    fprintf(fid1,'          end\n');
    % SOUT
    fprintf(fid1,'      SOUT: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CG0; \n');
    fprintf(fid1,'          rINT[1] = CG1; \n');
    fprintf(fid1,'          end\n');
    % STRD
    fprintf(fid1,'      STRD: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CF0; \n');
    fprintf(fid1,'          rINT[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % default
    fprintf(fid1,'      default:\n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rINT[0] = CH0; \n');
    fprintf(fid1,'          rINT[1] = CH1; \n');
    fprintf(fid1,'          end\n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
    
    % -----------
    % rIL
    % -----------
    fprintf(fid1,'//-------------------- rIL -------------------\n');    
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rIL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          rIL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rIL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'          rIL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'          end\n');
        % SIN
        fprintf(fid1,'      SIN: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j-1); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rIL[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                  rIL[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');  
        fprintf(fid1,'          end\n');
        % SCFG
        fprintf(fid1,'      SCFG: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rIL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  rIL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');        
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          rIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');   
        fprintf(fid1,'\n');                  
    end
    
    % -----------
    % rLB
    % -----------
    fprintf(fid1,'//-------------------- rLB -------------------\n');    
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rLB[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          rLB[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rLB[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'          rLB[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'          end\n');
        % SCFG
        fprintf(fid1,'      SCFG: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');
        % SNAND
        fprintf(fid1,'      SNAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');        
        % SAND
        fprintf(fid1,'      SAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');            
        % SOUT
        fprintf(fid1,'      SOUT: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rLB[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  rLB[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  if(cnt == %d)\n',NS(i)); % current stage
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      rLB[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                      rLB[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  else\n');        
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                      rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  end\n');
        fprintf(fid1,'          end\n');          
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');   
        fprintf(fid1,'\n');                  
    end
        
    % -----------
    % rOL
    % -----------
    fprintf(fid1,'//-------------------- rOL -------------------\n');     
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rOL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          rOL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rOL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'          rOL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'          end\n');           
        % SAND
        fprintf(fid1,'      SAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');        
        % SINV
        fprintf(fid1,'      SINV: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');       
        % SOUT
        fprintf(fid1,'      SOUT: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  if(cnt == %d)\n',(i)); % current stage
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      rOL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                      rOL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  else\n');        
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      rOL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                      rOL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'          end\n');          
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          rOL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          rOL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');   
        fprintf(fid1,'\n');          
    end
     
    %-----------------------------------------------------------------------
    fprintf(fid1,'//-------------------- Column -------------------\n');            
    % -----------
    % cIN
    % -----------
    fprintf(fid1,'//-------------------- cIN -------------------\n');        
    fprintf(fid1,'always @ (cs or cnt)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SIDLE
    fprintf(fid1,'      SIDLE: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CF0; \n');
    fprintf(fid1,'          cIN[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SINI
    fprintf(fid1,'      SINI: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CG0; \n');
    fprintf(fid1,'          cIN[1] = CG1; \n');
    fprintf(fid1,'          end\n');
    % SGIN
    fprintf(fid1,'      SGIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CF0; \n');
    fprintf(fid1,'          cIN[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SGTR
    fprintf(fid1,'      SGTR: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CG0; \n');
    fprintf(fid1,'          cIN[1] = CG1; \n');
    fprintf(fid1,'          end\n');
    % default
    fprintf(fid1,'      default:\n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CH0; \n');
    fprintf(fid1,'          cIN[1] = CH1; \n');
    fprintf(fid1,'          end\n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n'); 

    % -----------
    % cIL
    % -----------
    fprintf(fid1,'//-------------------- cIL -------------------\n');       
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIL[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'          cIL[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'          end\n');
        % SGTR
        fprintf(fid1,'      SGTR: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'          cIL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'          end\n');
        % SIN
        fprintf(fid1,'      SIN: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j-1); % current
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n'); 
        fprintf(fid1,'          end\n');
        % SCFG
        fprintf(fid1,'      SCFG: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');
        % STRD
        fprintf(fid1,'      STRD: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt < %d)\n',j); % the downstream stages
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');                
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');   
        fprintf(fid1,'\n');         
    end
    
    % -----------
    % cIMN
    % -----------
    fprintf(fid1,'//-------------------- cIMN -------------------\n');       
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIMN[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIMN[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIMN[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'          cIMN[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'          end\n');
        % SNAND
        fprintf(fid1,'      SNAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');        
        % SAND
        fprintf(fid1,'      SAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');            
        % SOUT
        fprintf(fid1,'      SOUT: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  if(cnt == %d)\n',NS(i)); % current stage
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      cIMN[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                      cIMN[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  else\n');        
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      cIMN[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                      cIMN[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  end\n');
        fprintf(fid1,'          end\n');    
        % STRD
        fprintf(fid1,'      STRD: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIMN[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIMN[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');
        fprintf(fid1,'          end\n');   
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIMN[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIMN[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');   
        fprintf(fid1,'\n');         
    end
    
    % -----------
    % cIM
    % -----------
    fprintf(fid1,'//-------------------- cIM -------------------\n');     
    for j = 1:NS(i)
        fprintf(fid1,'always @ (cs or cnt)\n');
        % Case
        fprintf(fid1,'      case(cs)\n');
        % SIDLE
        fprintf(fid1,'      SIDLE: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        % SINI
        fprintf(fid1,'      SINI: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'          end\n');
        % SINV
        fprintf(fid1,'      SINV: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');       
        % SOUT
        fprintf(fid1,'      SOUT: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  if(cnt == %d)\n',NS(i)); % current stage
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                      cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  else\n');        
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                      cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                      cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                  end\n');
        fprintf(fid1,'          end\n');          
        % STRD
        fprintf(fid1,'      STRD: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n'); 
        fprintf(fid1,'          end\n');           
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');
        fprintf(fid1,'\n');         
    end
    fprintf(fid1,'assign state = cs;\n');
    fprintf(fid1,'endmodule\n');
    fclose(fid1);
end






