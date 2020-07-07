（Original version - F:\2 Work\2 Mosaic_TCAD\Mosaic 2\Mosaic 2_02）
Mosaic flow of V2.2
	1 Parse the blif file: blifParser.m
	2 Rank the stage of the singals: stageRanker.m
	3 reorder the signals by their stages: sigReorder.m
	4 rewrite lib file by replacing the signal name with their order: libRewrite.m
	5 Map the circuit to xbar: xbarMapper.m
	6 Propagate the signal probility to be 1: sigProp.m
	7 Estimate the performance: perfEstimator.m

Mosaic flow 
    1 Parse the blif file: blifParser.m
    2 Rank the stage of the singals: stageRanker.m
    3 Map the circuit to xbar: xbarMapper.m
    4 Estimate the performance: perfEstimator.m




1: blifParser
Parse the blif file and generate the intermediate files
input: 
    .blif
output: 
    .si: signal names of each lut; names of signals are renamed by a number
    .sa: singal name
    .su: number of inputs, outputs and intermediate signals
    .so: signal output types
    .sn: number of signals of each lut including its input and output
    .mi: number of minterms of each lut
    .lib: the mapping matrix of each lut; it has been transformed to the format which can be directly mapped in xbar

# read the inputs 
# process blif file during the following phases:
    0: process input signals
    1: process output signals
    2: process luts signals
    3: process luts table

2: stageRanker
rank the signals to a specific stage
input: 
    .si: signal names of each lut; names of signals are renamed by a number
    .su: number of inputs, outputs and intermediate signals
output: 
    .ss: the stage number of each signal

3: xbarMapper/NoOpt.m    
map the luts onto the xbar with or without optimization
    input:
        .lib
        .ss
        .su
        .so
        .mi
        
    output:
        .xl: xbar layout of the complete mapping
        .st: statistics 
        .png: mosaic graph

4: perfEstimater/perfEstimater_NoOpt.m
Estimate the performance of the design with or without optimization
    input:
        .ss
        .mi
        .st
        .si
    output:
        .pe
5: cmos ctrl verilog and testbench generator
ctrl_vlog_OPT/NOPT.m
script used generate the CMOS controllers with / without optimization

tb_ctrl_vlog/_NOPT.m / 
Template to generate the control logic for Mon-OP in SEQ mode 
for optimized and non-optimized versions.

They dont need any input from the xbar. They are generated only based on the stage number.
We can link it to the stage number. 
---------------
Auxilary files
---------------
example_netlist_template_BK4B_maxAM.m
script used to generate a spice netlist based on a template


---------------
PLUM - FPGA
---------------
extract_vpr_log - Copy.m
Script to extract information from vpr route logs

gen_run_abc.m
Template to generate run.do for ABC Synthesis

lutLibGen.m
Generate the lut lib for abc


PLUM_gen_clb_area_delay.m
Generate the area of each arch and tech
