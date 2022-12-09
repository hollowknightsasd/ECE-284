module sram_128b_w2048 (CLK, D, Q, CEN, WEN, REN, A1, A2);

  input  CLK;

  input  REN; //Read enable signal,low signal enable
  input  WEN; //Write enable signal, low signal enable
  input  CEN; //Chip select signal
  input  [10:0] A1; //Read address;
  input  [10:0] A2; //Write address;

  input  [127:0] D;

  output [127:0] Q;
  parameter num = 2048;

  reg [127:0] memory [num-1:0];
  reg [10:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin
   if (!WEN && !CEN) begin // write
      memory[A2] <= D; 
   end
  end

  always @(posedge CLK) begin
   if(!REN && !CEN) begin //Read
      add_q <= A1;
   end
  end
  

endmodule