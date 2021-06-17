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
NS = 14:25;
NSTATE = 4; % 1 CFG, 2 NAND, 3 AND, 4 INV
NCTRL = 2; % No. of control voltage signals
for i = 1:length(NS) % for a specific Ns
    ctrlFileName = ['.\ctrl\ctrl_',num2str(NS(i)),'.v']; % Ctrl name
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
    fprintf(fid1,'module ctrl_%d(en,rst,clk,state,rIL,rLB,rOL,cIN,cIMN,cIM);\n',NS(i)); 
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
    fprintf(fid1,'parameter integer SIN = 2;        // receive inputs\n');
    fprintf(fid1,'parameter integer SCFG = 3;       // Configure all NANDs\n');
    fprintf(fid1,'parameter integer SNAND = 4;      // Evaluate NAND\n');
    fprintf(fid1,'parameter integer SAND = 5;       // Evaulate AND\n');
    fprintf(fid1,'parameter integer SINV = 6;       // Evaulate INV\n');
    fprintf(fid1,'parameter integer SOUT = 6;       // Send outputs\n');
    STATECNT = 3 + NSTATE + 1;
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
    fprintf(fid1,'output reg [NCTRL-1:0] rIL;    // IL\n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] rLB; // LB \n');
    fprintf(fid1,'output reg [NCTRL*NS-1:0] rOL; // OL\n');
    fprintf(fid1,'// Cols\n');
    fprintf(fid1,'output reg [NCTRL-1:0] cIN;     // IN \n');
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
    fprintf(fid1,'      SINI: ns = SIN;\n');
    % SIN
    fprintf(fid1,'      SIN: ns = SCFG;\n');
    % SCFG
    fprintf(fid1,'      SCFG: ns = SNAND;\n');
    % SNAND
    fprintf(fid1,'      SNAND: ns = SAND;\n');
    % SAND
    fprintf(fid1,'      SAND: ns = SINV;\n');
    % SINV
    fprintf(fid1,'      SINV: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          if((cnt < NS)) ns = SCFG;\n');
    fprintf(fid1,'          else ns = SOUT;\n');    
    fprintf(fid1,'          end\n');
    % SOUT
    fprintf(fid1,'      SOUT: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'              if((en == 1)) ns = SINI;\n');                                
    fprintf(fid1,'              else ns = SIDLE;\n'); 
    fprintf(fid1,'          end\n');
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
    % SCFG
    fprintf(fid1,'      SCFG: cnt <= cnt + 1;\n');
    % default
    fprintf(fid1,'      default: cnt <= cnt; \n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
    
    % -----------
    % output signals
    % -----------
    fprintf(fid1,'//-------------------- Row -------------------\n');
    % -----------
    % rIL
    % -----------
    fprintf(fid1,'//-------------------- rIL -------------------\n');
    fprintf(fid1,'always @ (cs or cnt)\n');
    % Case
    fprintf(fid1,'      case(cs)\n');
    % SIDLE
    fprintf(fid1,'      SIDLE: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIL[0] = CF0; \n');
    fprintf(fid1,'          rIL[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SINI
    fprintf(fid1,'      SINI: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIL[0] = CW0; \n');
    fprintf(fid1,'          rIL[1] = CW1; \n');
    fprintf(fid1,'          end\n');
    % SIN
    fprintf(fid1,'      SIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIL[0] = CG0; \n');
    fprintf(fid1,'          rIL[1] = CG1; \n');
    fprintf(fid1,'          end\n');
    % SCFG
    fprintf(fid1,'      SIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIL[0] = CW0; \n');
    fprintf(fid1,'          rIL[1] = CW1; \n');
    fprintf(fid1,'          end\n');    
    % default
    fprintf(fid1,'      default:\n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          rIL[0] = CH0; \n');
    fprintf(fid1,'          rIL[1] = CH1; \n');
    fprintf(fid1,'          end\n');
    fprintf(fid1,'      endcase\n');
    fprintf(fid1,'\n');
       
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
        fprintf(fid1,'              if(cnt < %d)\n',j); % current and downstream stages
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
        fprintf(fid1,'                      if(cnt < %d)\n',j); % downstream stages
        fprintf(fid1,'                      begin\n');        
        fprintf(fid1,'                          rLB[0 + (%d - 1)*NCTRL] = CG0; \n',j);
        fprintf(fid1,'                          rLB[1 + (%d - 1)*NCTRL] = CG1; \n',j);
        fprintf(fid1,'                      end\n'); 
        fprintf(fid1,'                      else\n');        
        fprintf(fid1,'                      begin\n');
        fprintf(fid1,'                          rLB[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                          rLB[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                      end\n');         
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');            
        % SOUT
        fprintf(fid1,'      SOUT: \n');
        fprintf(fid1,'      	begin\n');
        fprintf(fid1,'              rLB[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'              rLB[1 + (%d - 1)*NCTRL] = CW1; \n',j);
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
        % SCFG
        fprintf(fid1,'      SCFG: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % current stage
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  rOL[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  rOL[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
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
        fprintf(fid1,'          rOL[0 + (%d - 1)*NCTRL] = CW0; \n',j);
        fprintf(fid1,'          rOL[1 + (%d - 1)*NCTRL] = CW1; \n',j);
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
    % SIN
    fprintf(fid1,'      SIN: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'          cIN[0] = CF0; \n');
    fprintf(fid1,'          cIN[1] = CF1; \n');
    fprintf(fid1,'          end\n');
    % SCFG
    fprintf(fid1,'      SCFG: \n');
    fprintf(fid1,'          begin\n');
    fprintf(fid1,'              if(cnt == 0)\n'); % current stage
    fprintf(fid1,'                  begin\n');
    fprintf(fid1,'                  cIN[0] = CF0; \n');
    fprintf(fid1,'                  cIN[1] = CF1; \n');
    fprintf(fid1,'                  end\n');        
    fprintf(fid1,'              else\n');
    fprintf(fid1,'                  begin\n');
    fprintf(fid1,'                  cIN[0] = CH0; \n');
    fprintf(fid1,'                  cIN[1] = CH1; \n');
    fprintf(fid1,'                  end\n');    
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
        fprintf(fid1,'          cIMN[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIMN[1 + (%d - 1)*NCTRL] = CF1; \n',j);
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
        % SIN
        fprintf(fid1,'      SIN: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');
        % SCFG
        fprintf(fid1,'      SCFG: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % the downstream stages
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'                  end\n');        
        fprintf(fid1,'              else\n');
        fprintf(fid1,'                  begin\n');
        fprintf(fid1,'                  cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'                  cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'                  end\n');   
        fprintf(fid1,'          end\n');
        % SNAND
        fprintf(fid1,'      SNAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');              
        % SAND
        fprintf(fid1,'      SAND: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CH0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CH1; \n',j);
        fprintf(fid1,'          end\n');   
        % SINV
        fprintf(fid1,'      SINV: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'              if(cnt == %d)\n',j); % the downstream stages
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
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');          
        % default
        fprintf(fid1,'      default: \n');
        fprintf(fid1,'          begin\n');
        fprintf(fid1,'          cIM[0 + (%d - 1)*NCTRL] = CF0; \n',j);
        fprintf(fid1,'          cIM[1 + (%d - 1)*NCTRL] = CF1; \n',j);
        fprintf(fid1,'          end\n');
        fprintf(fid1,'      endcase\n');
        fprintf(fid1,'\n');         
    end
    fprintf(fid1,'assign state = cs;\n');
    fprintf(fid1,'endmodule\n');
    fclose(fid1);
end






