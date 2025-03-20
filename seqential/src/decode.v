module decode (
    input clk,
    input reset,
    input [31:0] instruction,
    input [63:0] write_data,
    input regwrite,
    output reg [63:0] ReadData1,
    output reg [63:0] ReadData2,
    output reg [63:0] imm,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output [4:0] rd
);

    assign rd = instruction[11:7];
    wire [4:0] rs1 = instruction[19:15]; 
    wire [4:0] rs2 = instruction[24:20];


    wire [63:0] reg_data1, reg_data2;


    reg_file regfile (
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(write_data),
        .ReadData1(reg_data1),
        .ReadData2(reg_data2),
        .regwrite(regwrite),
        .clock(clk),
        .reset(reset)
    );

   always @(*) begin
    ReadData1 = reg_data1;
    ReadData2 = reg_data2;
end


    always @(*) begin
   
        case (instruction[6:0])
            7'b1100011: begin // Branch (BEQ)
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b01;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end
            7'b0000011: begin // Load (LW)
                Branch = 0;
                MemRead = 1;
                MemtoReg = 1;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
            end
            7'b0100011: begin // Store (SW)
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b00;
                MemWrite = 1;
                ALUSrc = 1;
                RegWrite = 0;
            end
            7'b0110011: begin // R-type (ADD, SUB, etc.)
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b10;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 1;
            end
            default: begin // Default case to avoid latches
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
            end
        endcase
    end


    always @(*) begin
        case (instruction[6:0])
            7'b0000011, 7'b1100111: 
                imm = {{32{instruction[31]}},{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: 
                imm = {{32{instruction[31]}},{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: 
                imm = {{32{instruction[31]}},{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default: 
                imm = 32'b0;
        endcase
    end


//     always @(*) begin
//    $display("inside decode block clock = %b ReadData1 = %h, ReadData2 = %h, Imm = %h, ALUOp = %b memtoreg = %b", 
//                  clk,ReadData1, ReadData2, imm, ALUOp,MemtoReg);
// end


endmodule
