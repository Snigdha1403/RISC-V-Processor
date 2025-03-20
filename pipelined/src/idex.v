module idex (
    input clk,
    input reset,
    input Branch,
    input MemRead,
    input MemtoReg,
    input MemWrite,
    input RegWrite,
    input ALUSrc,
    input [1:0] ALUOp,
    input [63:0] pc_decode,
    input [63:0] readdata1_decode, 
    input [63:0] readdata2_decode,
    input [63:0] imm,
    input [2:0] funct3,
    input [6:0] funct7,
    input [4:0] ifid_rs1,
    input [4:0] ifid_rs2, 
    input [4:0] ifid_rd, 
    output reg [63:0] pc_idex, 
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [2:0] funct3_idex,
    output reg [6:0] funct7_idex,
    output reg [63:0] imm_idex,
    output reg [63:0] readdata1_idex, 
    output reg [63:0] readdata2_idex, 
    output reg branch_idex,
    output reg Memread_idex,
    output reg Memtoreg_idex, 
    output reg Memwrite_idex, 
    output reg Regwrite_idex,
    output reg ALUSrc_idex,
    output reg [1:0] ALUOp_idex,
    input flush,
    input bubble
);

always @(posedge clk) begin
    if (reset|| flush) begin
        pc_idex <= 32'b0;
        rs1 <= 5'b0;
        rs2 <= 5'b0;
        rd <= 5'b0;
        funct3_idex <= 3'b0;
        funct7_idex <= 7'b0;
        imm_idex <= 64'b0;
        readdata1_idex <= 64'b0;
        readdata2_idex <= 64'b0;
        branch_idex <= 1'b0;
        Memread_idex <= 1'b0;
        Memtoreg_idex <= 1'b0;
        Memwrite_idex <= 1'b0;
        Regwrite_idex <= 1'b0;
        ALUSrc_idex <= 1'b0;
        ALUOp_idex <= 2'b0;
    end 
    else begin
        pc_idex <= pc_decode;
        rs1 <= ifid_rs1;
        rs2 <= ifid_rs2;
        rd <= ifid_rd;
        funct3_idex <= funct3;
        funct7_idex <= funct7;
        imm_idex <= imm;
        readdata1_idex <= readdata1_decode;
        readdata2_idex <= readdata2_decode;
        branch_idex <= Branch;
        Memread_idex <= MemRead;
        Memtoreg_idex <= MemtoReg;
        Memwrite_idex <= MemWrite;
        Regwrite_idex <= RegWrite;
        ALUSrc_idex <= ALUSrc;
        ALUOp_idex <= ALUOp;
       
    end

    $display("ouput rs1 = %b, rs2 = %b , rd = %b",ifid_rs1,ifid_rs2,ifid_rd);
    // $display("pc id = %b pc ex = %b",pc_decode,pc_idex);
end

endmodule
