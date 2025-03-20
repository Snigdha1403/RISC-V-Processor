`include "mux.v"
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "writeback.v"
`include "reg_file.v"

module pc_update (
    input clk,
    input reset,
    input branch,
    input [63:0] pcb, 
    output reg [63:0] pc
);
    always @(negedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (branch)
            pc <= pcb; 
        else
            pc <= pc + 4;
    end
endmodule


module processor(
    input clk,
    input reset,
    output [63:0] pc_out,
    output [63:0] ReadData1,
    output [63:0] ReadData2,
    output Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output [1:0] ALUOp,
    output [63:0] valE,
    output zero_flag,
    output [63:0] write_data,
    output [63:0] read_data,
    output BranchZero,
    output [63:0] pcb
);
    reg [31:0] data_memory [0:1023];
    wire [63:0] pc;
    wire [31:0] instruction;
    wire [63:0] imm;
    wire [63:0] alu_input;
    
    // PC propagation through pipeline stages
    reg [63:0] pc_fetch, pc_decode, pc_execute, pc_memory, pc_writeback;
    assign pc_out = pc;
    
    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         pc_fetch <= 64'b0;
    //         pc_decode <= 64'b0;
    //         pc_execute <= 64'b0;
    //         pc_memory <= 64'b0;
    //         pc_writeback <= 64'b0;
    //     end else begin
    //         pc_fetch <= pc;
    //         pc_decode <= pc_fetch;
    //         pc_execute <= pc_decode;
    //         pc_memory <= pc_execute;
    //         pc_writeback <= pc_memory;
    //     end
    // end
    
    fetch IF (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction)
    );
    
    decode ID (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .write_data(write_data),
        .regwrite(RegWrite),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .imm(imm),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );
    
    mux_2x1 alu_mux (
    .I0(ReadData2),  
    .I1(imm),       
    .S0(ALUSrc),    
    .O(alu_input)    
    );

    execute EX (
        .clk(clk),
        .ALUOp(ALUOp),
        .funct7(instruction[31:25]),
        .funct3(instruction[14:12]),
        .read_data1(ReadData1),
        .alu_input(alu_input),
        .pc(pc),
        .imm(imm),
        .valE(valE),
        .zero_flag(zero_flag),
        .pcb(pcb)
    );
    
    pc_update PC_UPDATE (
        .clk(clk),
        .reset(reset),
        .branch(BranchZero),
        .pcb(pcb),
        .pc(pc)
    );
    
    and(BranchZero,Branch,zero_flag);
    data_memory M (
        .clock(clk),
        .reset(reset),
        .memwrite(MemWrite),
        .memread(MemRead),
        .add(valE),
        .write_data(ReadData2),
        .read_data(read_data)
    );
    
    write_back WB (
        .clk(clk),
        .reset(reset),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .rd(instruction[11:7]),
        .alu_output(valE),
        .mem_data(read_data),
        .write_data(write_data)
    );
endmodule

