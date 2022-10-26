// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 


module mac_tb;

parameter bw = 4;
parameter psum_bw = 16;

reg clk = 0;

reg  [4*bw-1:0] a;
reg  [4*bw-1:0] b;
reg  [psum_bw-1:0] c;


wire [psum_bw-1:0] out;
reg  [psum_bw-1:0] expected_out = 0;

reg  [psum_bw-1:0] expected_out1 = 0;
reg  [psum_bw-1:0] expected_out2 = 0;
reg  [psum_bw-1:0] expected_out3 = 0;
reg  [psum_bw-1:0] expected_out4 = 0;

integer   a_q[19:0];
integer   b_q[19:0];

integer w_file ; // file handler
integer w_scan_file ; // file handler

integer x_file ; // file handler
integer x_scan_file ; // file handler

integer x_dec;
integer w_dec;
integer i; 
integer u; 

function [3:0] w_bin ;
  input integer  weight ;
  begin

    if (weight>-1)
     w_bin[3] = 0;
    else begin
     w_bin[3] = 1;
     weight = weight + 8;
    end

    if (weight>3) begin
     w_bin[2] = 1;
     weight = weight - 4;
    end
    else 
     w_bin[2] = 0;

    if (weight>1) begin
     w_bin[1] = 1;
     weight = weight - 2;
    end
    else 
     w_bin[1] = 0;

    if (weight>0) 
     w_bin[0] = 1;
    else 
     w_bin[0] = 0;

  end
endfunction



function [3:0] x_bin ;
  input integer x;
  begin
    if(x > 7) begin
      x_bin[3] = 1;
      x = x - 8;
    end
    else
      x_bin[3] = 0;

    if(x > 3) begin
      x_bin[2] = 1;
      x = x - 4;
    end
    else
      x_bin[2] = 0;

    if(x > 1) begin
      x_bin[1] = 1;
      x = x - 2;
    end
    else 
      x_bin[1] = 0;
    
    if(x > 0)
      x_bin[0] = 1;
    else
      x_bin[0] = 0;
  end
endfunction


// Below function is for verification
function [psum_bw-1:0] mac_predicted;
  input       [bw-1 : 0]      a;
  input signed[bw-1 : 0]      b;
  input signed[psum_bw-1 : 0] c;
  reg signed  [bw : 0] a_q;
  reg signed  [2*bw-1 : 0] multi;

  begin
    a_q = a;
    multi = a_q*b;
    mac_predicted = multi + c;
  end

endfunction



mac_wrapper #(.bw(bw), .psum_bw(psum_bw)) mac_wrapper_instance (
	.clk(clk), 
        .a(a), 
        .b(b),
        .c(c),
	.out(out)
); 
 

initial begin 

  w_file = $fopen("b_data.txt", "r");  //weight data
  x_file = $fopen("a_data.txt", "r");  //activation

  $dumpfile("mac_tb.vcd");
  $dumpvars(0,mac_tb);
 
  #1 clk = 1'b0;  
  #1 clk = 1'b1;  
  #1 clk = 1'b0;

  $display("-------------------- Computation start --------------------");
  

  for (i=0; i<20; i=i+1) begin  // Data lenght is 20 in the data files

     w_scan_file = $fscanf(w_file, "%d\n", w_dec);
     x_scan_file = $fscanf(x_file, "%d\n", x_dec);

     a_q[i] = x_dec; // unsigned number
     b_q[i] = w_dec; // signed number
     $display("a = %d",a_q[i]);
     $display("b = %d",b_q[i]);
  end


  for (i=0; i<5; i=i+1) begin  // Data lenght is 20 in the data files

     #1 clk = 1'b1;
     #1 clk = 1'b0;

     a = {x_bin(a_q[i*4+3]), x_bin(a_q[i*4+2]), x_bin(a_q[i*4+1]), x_bin(a_q[i*4])};
     b = {w_bin(b_q[i*4+3]), w_bin(b_q[i*4+2]), w_bin(b_q[i*4+1]), w_bin(b_q[i*4])};

     c = expected_out;

     expected_out1 = mac_predicted(x_bin(a_q[i*4]), w_bin(b_q[i*4]), 0);
     expected_out2 = mac_predicted(x_bin(a_q[i*4+1]), w_bin(b_q[i*4+1]), 0);
     expected_out3 = mac_predicted(x_bin(a_q[i*4+2]), w_bin(b_q[i*4+2]), 0);
     expected_out4 = mac_predicted(x_bin(a_q[i*4+3]), w_bin(b_q[i*4+3]), 0);

     expected_out = expected_out1 + expected_out2 +  expected_out3 + expected_out4 + c;

  end


  #1 clk = 1'b1;
  #1 clk = 1'b0;

  $display("-------------------- Computation completed --------------------");

  #10 $finish;


end

endmodule




