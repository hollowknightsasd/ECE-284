module  CTRL(clk, reset, valid, accmu, Add_pmem,CEN, WEN, REN, ofifo_rd);

parameter nij = 36;
input clk;
input reset;
input valid;
input accmu;
output CEN;
output WEN;
output REN;
output[10:0] Add_pmem;
output ofifo_rd;

reg CEN_q;
reg WEN_q;
reg REN_q;
reg ofifo_rd_q;
reg[6:0] counter;
reg[10:0] Add_pmem_q;

assign CEN = CEN_q;
assign WEN = WEN_q;
assign REN = REN_q;
assign Add_pmem = Add_pmem_q;
assign ofifo_rd = ofifo_rd_q;

always @(posedge clk) begin
    if(reset) begin
        CEN_q <= 1;
        WEN_q <= 1;
        REN_q <= 1;
        Add_pmem_q <= 0;
        counter <= 0;
        ofifo_rd_q <= 0;
    end

    else if(valid && counter <= nij+1) begin
        ofifo_rd_q <= 1;
        counter <= counter + 1;
        if(counter > 0) begin
            CEN_q <= 0;
            WEN_q <= 0;
        end
        if(counter > 1) begin
            Add_pmem_q <= Add_pmem_q + 1;
        end
    end

    else if(accmu) begin
        CEN_q <= 0;
        REN_q <= 0;
    end

    else begin
        CEN_q <= 1;
        WEN_q <= 1;
        ofifo_rd_q <= 0;
        Add_pmem_q <= Add_pmem_q;
        counter <= 0;
    end

end
    
endmodule