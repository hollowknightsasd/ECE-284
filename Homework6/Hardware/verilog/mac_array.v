// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;

  reg[row*2-1 : 0] inst_q;
  wire[col*row-1:0] valid_q;
  wire[col*(row+1)*psum_bw-1:0] temp;

  genvar i;

  //Last row of the valid signal
  assign valid = valid_q[col*row-1:col*(row-1)];
  assign temp[col*psum_bw-1:0] = in_n;

  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk),
        .reset(reset),
        .in_w(in_w[i*bw-1 : (i-1)*bw]),
        .inst_w(inst_q[i*2-1 : (i-1)*2]),
        .in_n(temp[i*col*psum_bw-1 : (i-1)*col*psum_bw]),
        .valid(valid_q[col*i-1 : col*(i-1)]),
        .out_s(temp[(i+1)*col*psum_bw-1 : i*col*psum_bw])
      );
  end

  always @ (posedge clk) begin
    // inst_w flows to row0 to row7

    if(reset == 1) begin
      inst_q <= 0;
    end

    else begin
      inst_q <= {inst_q[13:12] , inst_w};
    end

  end

endmodule
