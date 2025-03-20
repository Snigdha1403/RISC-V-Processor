module memwb( 
    input clk,
    input reset,
    input MemtoReg_exmem,
    input RegWrite_exmem,
    input [63:0] pc_execute,
    input [63:0] readdata_mem,
    input [63:0] alu_result_mem,
    input [4:0] rd_execute, 

    output reg [4:0] rd_memwb, 
    output reg Memtoreg_memwb, 
    output reg Regwrite_memwb,
    output reg [63:0] readdata_memwb,
    output reg [63:0] alu_result_memwb
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_memwb <= 5'b0;
        Memtoreg_memwb <= 1'b0;
        Regwrite_memwb <= 1'b0;
        readdata_memwb <= 64'b0;
        alu_result_memwb <= 64'b0;
    end 
    else begin
        rd_memwb <= rd_execute;
        Memtoreg_memwb <= MemtoReg_exmem;
        Regwrite_memwb <= RegWrite_exmem;
        readdata_memwb <= readdata_mem;
        alu_result_memwb <= alu_result_mem;
    end
end

endmodule
