module exmem (
    input clk,
    input reset,
    input Branch_execute,
    input MemRead_execute,
    input MemtoReg_execute,
    input MemWrite_execute,
    input RegWrite_execute,
    input flush,
    input [63:0] pc_execute,
    input [63:0] alu_result,
    input zero_flag_execute,
    input [4:0] rd_execute, 
    input [63:0] B_input,
    output reg [63:0] B_input_out,
    output reg [63:0] pc_exmem, 
    output reg [4:0] rd_exmem, 
    output reg branch_exmem,
    output reg Memread_exmem,
    output reg Memtoreg_exmem, 
    output reg Memwrite_exmem, 
    output reg Regwrite_exmem,
    output reg [63:0] alu_result_exmem,
    output reg zero_flag_exmem,
    input [63:0] readdata2_ex,
    output reg [63:0] readdata2_mem
);

always @(posedge clk) begin
    if (reset||flush) begin
        pc_exmem <= 64'b0;
        rd_exmem <= 5'b0;
        branch_exmem <= 1'b0;
        Memread_exmem <= 1'b0;
        Memtoreg_exmem <= 1'b0;
        Memwrite_exmem <= 1'b0;
        Regwrite_exmem <= 1'b0;
        alu_result_exmem <= 64'b0;
        zero_flag_exmem <= 1'b0;
        readdata2_mem <= 64'b0;
        B_input_out <=0;
    end 
    else begin
        pc_exmem <= pc_execute;
        rd_exmem <= rd_execute;
        branch_exmem <= Branch_execute;
        Memread_exmem <= MemRead_execute;
        Memtoreg_exmem <= MemtoReg_execute;
        Memwrite_exmem <= MemWrite_execute;
        Regwrite_exmem <= RegWrite_execute;
        alu_result_exmem <= alu_result;
        zero_flag_exmem <= zero_flag_execute;
        readdata2_mem<=readdata2_ex;
        B_input_out <=B_input;
    end
end

endmodule
