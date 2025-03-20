module mux_2x1_1 (
    input wire I0,   // Input 0
    input wire I1,   // Input 1
    input wire S,    // Select signal
    output wire O    // Output
);

    wire nS, and0_out, and1_out;

    not (nS, S);               // nS = NOT S
    and (and0_out, I0, nS);    // and0_out = I0 AND (NOT S)
    and (and1_out, I1, S);     // and1_out = I1 AND S
    or  (O, and0_out, and1_out); // O = and0_out OR and1_out

endmodule

module decoder_7x7 (
    input wire branch_id, memread_id, memtoreg_id, memwrite_id, regwrite_id, alusrc_id,
    input wire [1:0] aluop_id,  // ALUOp is 2-bit
    input wire bubble,
    output wire branch_bubble, memread_bubble, memtoreg_bubble, memwrite_bubble, regwrite_bubble, alusrc_bubble,
    output wire [1:0] aluop_bubble
);

    // Using the 2x1 multiplexer for each signal
    mux_2x1_1 mux_branch   (.I0(1'b0), .I1(branch_id), .S(~bubble), .O(branch_bubble));
    mux_2x1_1 mux_memread  (.I0(1'b0), .I1(memread_id), .S(~bubble), .O(memread_bubble));
    mux_2x1_1 mux_memtoreg (.I0(1'b0), .I1(memtoreg_id), .S(~bubble), .O(memtoreg_bubble));
    mux_2x1_1 mux_memwrite (.I0(1'b0), .I1(memwrite_id), .S(~bubble), .O(memwrite_bubble));
    mux_2x1_1 mux_regwrite (.I0(1'b0), .I1(regwrite_id), .S(~bubble), .O(regwrite_bubble));
    mux_2x1_1 mux_alusrc   (.I0(1'b0), .I1(alusrc_id), .S(~bubble), .O(alusrc_bubble));
    
    assign aluop_bubble = bubble ? 2'b00 : aluop_id;  // Multiplexer logic for 2-bit ALUOp

endmodule

module decode (
    input clk,
    input reset,
    input [31:0] instruction,
    input [63:0] write_data,
    input regwrite,
    input [4:0] rdin,
    output reg [63:0] ReadData1,
    output reg [63:0] ReadData2,
    output reg [63:0] imm,
    output wire branch_b,      // Changed from reg to wire
    output wire memread_b,     // Changed from reg to wire
    output wire memtoreg_b,    // Changed from reg to wire
    output wire [1:0] aluop_b, // Changed from reg to wire
    output wire memwrite_b,    // Changed from reg to wire
    output wire alusrc_b,      // Changed from reg to wire
    output wire regwrite_b,    // Changed from reg to wire
    output [4:0] rd,
    output [4:0] rs1,
    output [4:0] rs2,
    output [2:0] funct3,
    output [6:0] funct7,
    input bubble
);

    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15]; 
    assign rs2 = instruction[24:20];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    wire [63:0] reg_data1, reg_data2;
    reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    reg [1:0] ALUOp;  // ALUOp is a 2-bit register

    reg_file regfile (
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rdin),
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
                $display("Hi from decode");
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
            
            default: begin // Default c to avoid latches
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
            7'b0000011, 7'b1100111: // I-type (Load, JALR)
                imm = {{52{instruction[31]}}, instruction[31:20]};  
            7'b0100011: // S-type (Store)
                imm = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type (Branch)
                imm = {{52{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default: 
                imm = 64'b0;
        endcase
    end

    // wire bubble = 0; // Default to no bubble, this should be connected to the hazard detection unit

    decoder_7x7 decoder_inst (
        .branch_id(Branch),
        .memread_id(MemRead),
        .memtoreg_id(MemtoReg),
        .memwrite_id(MemWrite),
        .regwrite_id(RegWrite),
        .alusrc_id(ALUSrc),
        .aluop_id(ALUOp),
        .bubble(bubble),
        .branch_bubble(branch_b),
        .memread_bubble(memread_b),
        .memtoreg_bubble(memtoreg_b),
        .memwrite_bubble(memwrite_b),
        .regwrite_bubble(regwrite_b),
        .alusrc_bubble(alusrc_b),
        .aluop_bubble(aluop_b)
    );

    always @(*) begin
       $display("Inside decode Branch = %b | MemRead = %b | MemtoReg = %b | MemWrite = %b | RegWrite = %b , ",
              Branch,  MemRead,  MemtoReg,  MemWrite,  RegWrite );
    end

endmodule
