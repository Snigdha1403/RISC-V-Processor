`include "my_alu.v"

module execute (
    input clk,
    input [1:0] ALUOp,  
    input [6:0] funct7,
    input [2:0] funct3,
    input [63:0] read_data1,        
    input [63:0] alu_input,    
    input [63:0] pc,             
    input [63:0] imm,           
    output reg [63:0] valE, 
    output wire zero_flag,  
    output reg [63:0] pcb 
);

    wire [63:0] A_input;
    wire [63:0] B_input;
    assign A_input = read_data1;
    assign B_input = alu_input;

    wire [63:0] and_out, or_out, xor_out;
    wire [63:0] sum_add, sum_sub, sll_out, srl_out, sra_out;
    wire carry_add, carry_sub, ovf_add, ovf_sub;
    wire slt_a, sltu_a;
    wire borrow1;

    reg [3:0] alu_op;

    // ALU modules
    ADD addition(A_input, B_input, 1'b0, sum_add, carry_add, ovf_add);
    SUB subtraction(A_input, B_input, 1'b1, sum_sub, carry_sub, borrow1, ovf_sub);
    AND and_op(A_input, B_input, and_out);
    OR or_op(A_input, B_input, or_out);
    XOR xor_op(A_input, B_input, xor_out);
    SLT slt_op(A_input, B_input, slt_a);
    SLTU sltu_op(A_input, B_input, sltu_a);
    SLL sll_op(A_input, B_input[5:0], sll_out);
    SRL srl_op(A_input, B_input[5:0], srl_out);
    SRA sra_op(A_input, B_input[5:0], sra_out);

    // ALU operation selection (combinational)
    always @(*) begin
        alu_op = 4'b0000;
        case (ALUOp)
            2'b00: alu_op = 4'b0010;  // Addition (LW, SW)
            2'b01: alu_op = 4'b0110;  // Subtraction (Branch)
            2'b10: begin
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_op = 4'b0010; // ADD
                    {7'b0100000, 3'b000}: alu_op = 4'b0110; // SUB
                    {7'b0000000, 3'b111}: alu_op = 4'b0000; // AND
                    {7'b0000000, 3'b110}: alu_op = 4'b0001; // OR
                    default: alu_op = 4'b0000;
                endcase
            end
        endcase
    end

    // Compute ALU output (combinational)
    always @(*) begin
        case (alu_op)
            4'b0010: valE = sum_add;
            4'b0110: valE = sum_sub;
            4'b0000: valE = and_out; 
            4'b0001: valE = or_out;  
            4'b0011: valE = xor_out; 
            4'b0100: valE = slt_a;   
            4'b0101: valE = sltu_a;  
            4'b0111: valE = sll_out; 
            4'b1000: valE = srl_out;
            4'b1001: valE = sra_out;
            default: valE = 64'b0;
        endcase
         
    end

    // Branch handling (synchronous)
    always @(*) begin
        case (ALUOp)
            2'b01: begin 
                case (funct3)
                    3'b000: pcb <= (zero_flag) ? (pc + (imm << 1)) : (pc + 4); 
                    default: pcb <= pc + 4; 
                endcase
            end
            default: pcb <= pc + 4; 
        endcase
        //  $display("inside execute");
    end

    // Zero flag
     // Zero flag
    assign zero_flag = (valE == 0) ? 1'b1 : 1'b0;
    
    // Assign carry and overflow based on selected operation
    assign carry = (alu_op == 4'b0010) ? carry_add : 
                   (alu_op == 4'b0110) ? carry_sub : 1'b0;
                   
    assign overflow = (alu_op == 4'b0010) ? ovf_add : 
                      (alu_op == 4'b0110) ? ovf_sub : 1'b0;

    assign zero_flag = (valE == 0) ? 1'b1 : 1'b0;
    // always @(posedge clk) begin
    //     $display("Execute output ->   ALUOp: %b | funct7: %b | funct3: %b | read_data1: %h | alu_input: %h | pc: %h | imm: %h | valE: %h | zero_flag: %b | pcb: %h | Carry: %b | Overflow: %b",
    //          ALUOp, funct7, funct3, read_data1, alu_input, pc, imm, valE, zero_flag, pcb, carry, overflow);
    // end
endmodule
