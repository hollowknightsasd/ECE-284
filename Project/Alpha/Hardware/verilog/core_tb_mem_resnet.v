// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 8;
parameter col = 8;
parameter row = 8;
parameter len_nij = 30; //?

reg clk = 0;
reg reset = 1;
reg reset1 = 1;

wire [61:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;
reg CEN_wmem_0_q = 1;
reg WEN_wmem_0_q = 1;
reg [10:0] wmem_A_0_q = 0;
reg CEN_wmem_1_q = 1;
reg WEN_wmem_1_q = 1;
reg [10:0] wmem_A_1_q = 0;
reg CEN_wmem_0 = 1;
reg WEN_wmem_0 = 1;
reg [10:0] wmem_A_0 = 0;
reg CEN_wmem_1 = 1;
reg WEN_wmem_1 = 1;
reg [10:0] wmem_A_1 = 0;
reg Start_acc_q = 0;
reg Start_acc = 0;

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;
reg [psum_bw*col-1:0] redisual;
reg Choice=1;
reg Choice_q=1;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer res_file, res_scan_file;
integer captured_data; 
integer t, i, j, k, kij;
integer error;

assign inst_q[61] = Choice;
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


core  #(.bw(bw), .col(col), .row(row), .nij(len_nij)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
  .D_xmem(D_xmem_q), 
  .sfp_out(sfp_out), 
  .redisual(redisual),
	.reset(reset),
  .reset1(reset1)); 


initial begin 

  inst_w   = 0; // inst[1:0] load execute 
  D_xmem   = 0; 
  CEN_xmem = 1; // inst[19] CEN_xmem
  WEN_xmem = 1; // inst[18] WEN_xmem
  A_xmem   = 0; 
  ofifo_rd = 0; // inst[6] ofifo_rd
  ififo_wr = 0; // inst[5] ififo_wr
  ififo_rd = 0; // inst[4] ififo_rd
  l0_rd    = 0; // inst[3] l0_rd
  l0_wr    = 0; // inst[2] l0_wr
  execute  = 0;
  load     = 0;
  CEN_wmem_0 = 1;
  WEN_wmem_0 = 1;
  wmem_A_0 = 0;
  CEN_wmem_1 = 1;
  WEN_wmem_1 = 1;
  wmem_A_1 = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen("activation_tile0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1; reset1 = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0; reset1 = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////

  /////// Kernel data writing to memory ///////

  wmem_A_0 = 11'b00000000000;  

  w_file = $fopen("w0.txt", "r");
  // Following three lines are to remove the first three comment lines of the file
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);
  w_scan_file = $fscanf(w_file,"%s", captured_data);

  #0.5 clk = 1'b0;   reset = 1; reset1 = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0; reset1 = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   

  for(t=0;t<col;t=t+1) begin
    #0.5 clk = 1'b0; w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_wmem_0 = 0; CEN_wmem_0 = 0; if (t>0) wmem_A_0 = wmem_A_0 + 1; 
    #0.5 clk = 1'b1;
  end
  #0.5 clk = 1'b0; WEN_wmem_0 = 1; CEN_wmem_0 = 1; wmem_A_0 = 11'b00000000000;  
  #0.5 clk = 1'b1;
  $fclose(w_file);

  for (kij=1; kij<10; kij=kij+1) begin  // kij loop

    case(kij)
     1: w_file_name = "w1.txt";
     2: w_file_name = "w2.txt";
     3: w_file_name = "w3.txt";
     4: w_file_name = "w4.txt";
     5: w_file_name = "w5.txt";
     6: w_file_name = "w6.txt";
     7: w_file_name = "w7.txt";
     8: w_file_name = "w8.txt";
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   

    if (kij%2 == 0) begin
      for (t=0;t<col;t=t+1) begin
        #0.5 clk = 1'b0; if (kij<9) begin w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_wmem_0 = 0; CEN_wmem_0 = 0; if (t>0) wmem_A_0 = wmem_A_0 + 1; end
        if (t==0) begin WEN_wmem_1 = 1; CEN_wmem_1 = 0; end
        else begin l0_rd = 0; l0_wr = 1; WEN_wmem_1 = 1; CEN_wmem_1 = 0; wmem_A_1 = wmem_A_1 + 1; end
        #0.5 clk = 1'b1;
      end
      #0.5 clk = 1'b0; if (kij<9) begin WEN_wmem_0 = 1; CEN_wmem_0 = 1; wmem_A_0 = 11'd0; end 
      CEN_wmem_1 = 1; wmem_A_1 = 11'd0; l0_wr = 1;
      #0.5 clk = 1'b1;
      #0.5 clk = 1'b0; l0_wr = 0;
      #0.5 clk = 1'b1;
    end
    else begin
      for (t=0;t<col;t=t+1) begin
        #0.5 clk = 1'b0; if(kij<9) begin w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_wmem_1 = 0; CEN_wmem_1 = 0; if (t>0) wmem_A_1 = wmem_A_1 + 1; end
        if (t==0) begin WEN_wmem_0 = 1; CEN_wmem_0 = 0; end
        else begin l0_rd = 0; l0_wr = 1; WEN_wmem_0 = 1; CEN_wmem_0 = 0; wmem_A_0 = wmem_A_0 + 1; end
        #0.5 clk = 1'b1;
      end
      #0.5 clk = 1'b0; if(kij<9) begin WEN_wmem_1 = 1; CEN_wmem_1 = 1; wmem_A_1 = 11'd0; end
      CEN_wmem_0 = 1; wmem_A_0 = 11'd0; l0_wr = 1;
      #0.5 clk = 1'b1;
      #0.5 clk = 1'b0; l0_wr = 0;
      #0.5 clk = 1'b1;
    end

    /////// Kernel loading to PEs ///////
    for (j=0; j<col; j=j+1) begin
      #0.5 clk = 1'b0; l0_rd = 1; load = 1;
      #0.5 clk = 1'b1;
    end
    /////////////////////////////////////

    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  
  

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////

    /////// Activation data writing to L0 ///////
    #0.5 clk = 1'b0; WEN_xmem = 1; CEN_xmem = 0;
    #0.5 clk = 1'b1;
    for (k=0; k<len_nij-1; k=k+1) begin
      #0.5 clk = 1'b0; l0_wr = 1; WEN_xmem = 1; CEN_xmem = 0; A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; CEN_xmem = 1; A_xmem = 0; l0_wr = 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0; l0_wr = 0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////

    ///////////Below need to be changed///////////

    /////// Execution & OFIFO Read ///////
    for (i=0; i<len_nij; i=i+1) begin
      #0.5 clk = 1'b0; l0_rd = 1; execute = 1;
      #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0; l0_rd = 0; execute = 0;
    #0.5 clk = 1'b1;

    for (i=0; i<36; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;
    end 

    end  // end of kij loop

      ////////// Accumulation /////////
  acc_file = $fopen("acc_address.txt", "r");
  out_file = $fopen("answer.txt", "r");  /// out.txt file stores the address sequence to read out from psum memory for accumulation
                                      /// This can be generated manually or in
                                      /// pytorch automatically
  res_file = $fopen("residual.txt", "r");
  

  // Following three lines are to remove the first three comment lines of the file
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 
  out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (sfp_out == answer)
         $display("%2d-th output featuremap Data matched! :D", i); 
       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", sfp_out);
         $display("answer: %128b", answer);
         error = 1;
       end
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  

    #0.5 clk = 1'b0; Start_acc = 1;
    #0.5 clk = 1'b1;

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<len_kij)       begin Start_acc = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
                       else  begin Start_acc = 0; res_scan_file = $fscanf(res_file,"%128b", redisual);end

        if (j>0)  acc = 1;   
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1; 
  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
   CEN_wmem_0_q <= CEN_wmem_0;
   WEN_wmem_0_q <= WEN_wmem_0;
   wmem_A_0_q <= wmem_A_0;
   CEN_wmem_1_q <= CEN_wmem_1;
   WEN_wmem_1_q <= WEN_wmem_1;
   wmem_A_1_q <= wmem_A_1;
   Start_acc_q <= Start_acc;
   Choice_q <= Choice;
end


endmodule