module core(clk, inst, ofifo_valid, redisual, D_xmem, sfp_out, reset, reset1);
//Only contain corelet and SRAM in this file
/*
assign inst_q[60]    = Start_acc_q;
assign inst_q[59:49] = wmem_A_1_q;
assign inst_q[48:38] = wmem_A_0_q;
assign inst_q[37] = CEN_wmem_1_q;
assign inst_q[36] = WEN_wmem_1_q;
assign inst_q[35] = CEN_wmem_0_q;
assign inst_q[34] = WEN_wmem_0_q;
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 

*/
parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;
parameter nij = 36;

input clk, reset, reset1;
input [61:0] inst;
input [bw*row-1:0] D_xmem;
input [psum_bw*col-1 : 0] redisual;

output [col*psum_bw-1:0] sfp_out;
output ofifo_valid;

wire [psum_bw*row-1 : 0] pmem_in;
wire [bw*row-1:0] xmem_out;
wire [bw*row-1:0] processor_data_in;
wire [psum_bw*col-1 : 0] psum_out;
wire [10:0] xmem_A;
wire [10:0] pmem_A;
wire WEN_xmem;
wire CEN_xmem;
wire WEN_pmem;
wire CEN_pmem;
wire WEN_wmem_0;
wire WEN_wmem_1;
wire CEN_wmem_0;
wire CEN_wmem_1;
wire [10:0] wmem_A_0;
wire [10:0] wmem_A_1;
wire [bw*row-1:0] wmem_out_0;
wire [bw*row-1:0] wmem_out_1;
wire [13:0] pmem_inst;
reg WEN_wmem_0_q;
reg WEN_wmem_1_q;
reg CEN_xmem_q;
genvar i;

//Instruction
assign xmem_A   = inst[17:7];
assign WEN_xmem = inst[18];
assign CEN_xmem = inst[19];
assign pmem_A   = inst[30:20];
assign WEN_pmem = inst[31];
assign CEN_pmem = inst[32];
assign WEN_wmem_0 = inst[34];
assign CEN_wmem_0 = inst[35];
assign WEN_wmem_1 = inst[36];
assign CEN_wmem_1 = inst[37];
assign wmem_A_0   = inst[48:38];
assign wmem_A_1   = inst[59:49];

//Select data in
assign processor_data_in = (!CEN_xmem_q) ? xmem_out : ((WEN_wmem_0_q) ? wmem_out_0 : wmem_out_1);
always @(posedge clk) begin
    WEN_wmem_0_q <= WEN_wmem_0;
    WEN_wmem_1_q <= WEN_wmem_1;
    CEN_xmem_q   <= CEN_xmem;
end
//Corelet
corelet  #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) corelet_instance(
    .clk(clk),
    .reset(reset),
    .reset1(reset1),
    .xdata(processor_data_in),
    .psum(psum_out),
    .inst(inst),
    .out(sfp_out),
    .redisual(redisual),
    .pmem_in(pmem_in),
    .pmem_inst(pmem_inst)
);


//Activation & Weight SRAM
sram_32b_w2048 #(.num(1024)) xmem_sram(
    .CLK(clk),
    .WEN(WEN_xmem),
    .CEN(CEN_xmem),
    .D(D_xmem),
    .A(xmem_A),
    .Q(xmem_out)
);

//Memory double buffering
sram_32b_w2048 #(.num(256)) wmem_sram_0(
    .CLK(clk),
    .WEN(WEN_wmem_0),
    .CEN(CEN_wmem_0),
    .D(D_xmem),
    .A(wmem_A_0),
    .Q(wmem_out_0)
);

sram_32b_w2048 #(.num(256)) wmem_sram_1(
    .CLK(clk),
    .WEN(WEN_wmem_1),
    .CEN(CEN_wmem_1),
    .D(D_xmem),
    .A(wmem_A_1),
    .Q(wmem_out_1)
);

//Psum SRAM
sram_128b_w2048 #(.num(2048)) pmem_sram(
    .CLK(clk),
    .WEN(pmem_inst[12]),
    .CEN(pmem_inst[11]),
    .REN(pmem_inst[13]),
    .D(pmem_in),
    .A1(pmem_A), //Read address
    .A2(pmem_inst[10:0]),       //Write address
    .Q(psum_out)
);

endmodule
