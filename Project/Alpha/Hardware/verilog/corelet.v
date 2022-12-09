module corelet(clk, reset, reset1, redisual, xdata, inst, psum, out, pmem_in, pmem_inst);
/*
inst_q[33] = acc_q;        inst_q[32] = CEN_pmem_q;
inst_q[31] = WEN_pmem_q;   inst_q[30:20] = A_pmem_q;
inst_q[19]   = CEN_xmem_q; inst_q[18]   = WEN_xmem_q;
inst_q[17:7] = A_xmem_q;   inst_q[6]   = ofifo_rd_q;
inst_q[5]   = ififo_wr_q;  inst_q[4]   = ififo_rd_q;
inst_q[3]   = l0_rd_q;     inst_q[2]   = l0_wr_q;
inst_q[1]   = execute_q;   inst_q[0]   = load_q; 
*/
parameter bw = 4;
parameter col = 8;
parameter row = 8;
parameter psum_bw = 16;
parameter nij = 36;

input clk, reset, reset1;
input [psum_bw*row-1 : 0] psum;
input [row*bw-1 : 0] xdata;
input [61:0] inst;
input [psum_bw*col-1 : 0] redisual;
output [psum_bw*col-1 : 0] out;
output [psum_bw*col-1 : 0] pmem_in;
output [13:0] pmem_inst;


//l0 instance, severed as Input fifo
wire l0_wr, l0_rd;
wire [row*bw-1:0] l0_out;
wire l0_full; 
wire l0_ready;

//mac array, load weight into the array
wire [1 : 0] inst_w; 
wire [col-1 : 0] valid; //mac_array provide valid signal to ofifo wr, last row signal
wire [psum_bw*col-1 : 0] mac_out; // final row of psum to ofifo
wire [psum_bw*col-1 : 0] in_n_temp;

//ofifo instance
wire [col-1 : 0] ofifo_wr; 
wire [col*psum_bw-1 : 0] ofifo_in;
wire [col*psum_bw-1 : 0] ofifo_out;
wire ofifo_full;
wire ofifo_ready;
wire ofifo_valid;

//SFP instance
wire sfp_acc;
wire sfp_relu;
wire [psum_bw-1:0] sfp_thres;
wire [psum_bw*col-1 : 0] sfp_in;
wire [psum_bw*col-1 : 0] sfp_out;



//////////////////////////////////////////////////////
wire signed[psum_bw-1 : 0] sfp_signed0;
wire signed[psum_bw-1 : 0] sfp_signed1;
wire signed[psum_bw-1 : 0] sfp_signed2;
wire signed[psum_bw-1 : 0] sfp_signed3;
wire signed[psum_bw-1 : 0] sfp_signed4;
wire signed[psum_bw-1 : 0] sfp_signed5;
wire signed[psum_bw-1 : 0] sfp_signed6;
wire signed[psum_bw-1 : 0] sfp_signed7;
wire signed[psum_bw-1 : 0] res_signed0;
wire signed[psum_bw-1 : 0] res_signed1;
wire signed[psum_bw-1 : 0] res_signed2;
wire signed[psum_bw-1 : 0] res_signed3;
wire signed[psum_bw-1 : 0] res_signed4;
wire signed[psum_bw-1 : 0] res_signed5;
wire signed[psum_bw-1 : 0] res_signed6;
wire signed[psum_bw-1 : 0] res_signed7;

wire [psum_bw*row-1 : 0] result;

assign sfp_signed0 = sfp_out[15:0]; assign sfp_signed1 = sfp_out[31:16]; assign sfp_signed2 = sfp_out[47:32]; assign sfp_signed3 = sfp_out[63:48];
assign sfp_signed4 = sfp_out[79:64]; assign sfp_signed5 = sfp_out[95:80]; assign sfp_signed6 = sfp_out[111:96]; assign sfp_signed7 = sfp_out[127:112];

assign res_signed0 = redisual[15:0]; assign res_signed1 = redisual[31:16]; assign res_signed2 = redisual[47:32]; assign res_signed3 = redisual[63:48];
assign res_signed4 = redisual[79:64]; assign res_signed5 = redisual[95:80]; assign res_signed6 = redisual[111:96]; assign res_signed7 = redisual[127:112];

assign result[15:0] = sfp_signed0 + res_signed0; assign result[31:16] = sfp_signed1 + res_signed1; assign result[47:32] = sfp_signed2 + res_signed2; assign result[63:48] = sfp_signed3 + res_signed3; 
assign result[79:64] = sfp_signed4 + res_signed4; assign result[95:80] = sfp_signed5 + res_signed5; assign result[111:96] = sfp_signed6 + res_signed6; assign result[127:112] = sfp_signed7 + res_signed7;
//////////////////////////////////////////////////////

assign l0_wr = inst[2];
assign l0_rd = inst[3];

assign out = (inst[61]) ? result : sfp_out;
assign pmem_in = ofifo_out;

//Controll unit
CTRL #(.nij(nij)) CTRL_instance(
    .clk(clk),
    .reset(reset1),
    .valid(ofifo_valid),
    .accmu(inst[60]),   //Accumulation start
    .Add_pmem(pmem_inst[10:0]),
    .CEN(pmem_inst[11]),
    .WEN(pmem_inst[12]),
    .REN(pmem_inst[13]),
    .ofifo_rd(ofifo_rd)
)
;
//L0 instance
l0 #(.bw(bw), .row(row)) l0_instance(
    .clk(clk),
    .reset(reset),
    .wr(l0_wr),
    .rd(l0_rd),
    .in(xdata),
    .out(l0_out),
    .o_full(l0_full), 
    .o_ready(l0_ready)
);


assign inst_w = inst[1:0];
assign in_n_temp = 128'b0;

mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance(
    .clk(clk),
    .reset(reset),
    .in_w(l0_out),
    .in_n(in_n_temp), 
    .inst_w(inst_w),
    .out_s(mac_out),
    .valid(valid)
);


assign ofifo_in = mac_out;
assign ofifo_wr = valid;

ofifo #(.bw(psum_bw), .col(col)) ofifo_instance(
    .clk(clk),
    .reset(reset),
    .wr(ofifo_wr),
    .rd(ofifo_rd),
    .in(ofifo_in),
    .o_full(ofifo_full),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid),
    .out(ofifo_out)
);

genvar i;

assign sfp_in = psum;
assign sfp_acc = inst[33];
assign sfp_relu = 1'b0;
assign sfp_thres = 16'b0;

//SFP receive data from psum_mem
generate
for (i=1; i < col+1 ; i=i+1) begin : col_num
    sfp #(.psum_bw(psum_bw), .bw(bw)) sfp_instance(
        .clk(clk),
        .reset(reset),
        .relu(sfp_relu),
        .acc(sfp_acc),
        .in(sfp_in[i*psum_bw-1 : (i-1)*psum_bw]), 
        .thres(sfp_thres),
        .out(sfp_out[i*psum_bw-1 : (i-1)*psum_bw])
    );
end
endgenerate

endmodule
