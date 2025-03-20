module ifid (
    input clk,
    input reset,
    input [31:0] instruction,
    input [63:0] pc,
    input ifid_write,
    input flush,
    output reg [31:0] inst_out,
    output reg [63:0] pc_ifid
);

always @(posedge clk) begin
    if (reset || flush) begin
        inst_out <= 32'b0;
        pc_ifid <= 32'b0;
    end 
    else if(ifid_write==1'b1)
    begin
        inst_out <= instruction;
        pc_ifid <= pc;
    end

    $display("Inst_out=%h",inst_out);
end
endmodule
