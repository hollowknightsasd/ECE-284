// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a, b, c);

parameter bw = 4;
parameter psum_bw = 16;

input         [4*bw-1:0]  a;
input signed  [4*bw-1:0]  b;
input signed  [psum_bw-1:0] c;
output signed [psum_bw-1:0] out;

wire signed   [2*bw-1:0]    product1;
wire signed   [2*bw-1:0]    product2;
wire signed   [2*bw-1:0]    product3;
wire signed   [2*bw-1:0]    product4;

wire signed   [2*bw+1:0] add1;
wire signed   [2*bw+1:0] add2;

wire signed [bw:0] a1;
wire signed [bw:0] a2;
wire signed [bw:0] a3;
wire signed [bw:0] a4;

assign a1 = a[bw-1:0];
assign a2 = a[2*bw-1:bw];
assign a3 = a[3*bw-1:2*bw];
assign a4 = a[4*bw-1:3*bw];

assign product1 = a1 * {{bw{b[bw-1]}} , b[bw-1:0]};
assign product2 = a2 * {{bw{b[2*bw-1]}}, b[2*bw-1:bw]};
assign product3 = a3 * {{bw{b[3*bw-1]}}, b[3*bw-1:2*bw]};
assign product4 = a4 * {{bw{b[4*bw-1]}}, b[4*bw-1:3*bw]};

assign add1 = product1 + product2;
assign add2 = product3 + product4;

assign out = add1 + add2 +c;



endmodule
