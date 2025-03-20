    `include "mux.v"
    `include "fetch.v"
    `include "decode.v"
    `include "execute.v"
    `include "memory.v"
    `include "writeback.v"
    `include "reg_file.v"
    `include "ifid.v"
    `include "idex.v"
    `include "exmem.v"
    `include "memwb.v"
    `include "forward.v"
    `include  "hazard.v"

    module branch_hazard(
        input branch,
        input zero_flag,
        output reg flush
    );
    initial begin
        flush <=0;
    end
    always @(*) begin

        if(branch&zero_flag)
        begin
            flush<=1'b1;
        end
        else begin
            flush<=0;
        end
    end

    endmodule

    module pc_update (
    input clk,
    input reset,
    input branch,
    input [63:0] pcb, 
    input pc_write,
    output reg [63:0] pc
    );

    always @(posedge clk or posedge reset) begin
        $display("pcb=%b",pcb);
        if (reset)
            pc <= 64'b0; // Fixed reset value to 64 bits
        else if(branch) begin
            pc<=pcb;
        end
        else if (pc_write) begin  // Corrected pc_write condition
                pc <= pc + 4; // Increment PC normally
        end
        
    end

    endmodule



    module processor (
        input clk,
        input reset
    );
    // Program Counter
        wire [63:0] pcb;
        reg branch = 0; // Set branch to always 0

        // Pipeline Registers
        wire [31:0] instruction_if, instruction_id;
        wire [63:0] pc_if, pc_id, pc_ex, pc_mem,pc_wb;
        wire [63:0] imm_id, imm_ex;
        wire [63:0] readdata1_id, readdata2_id, readdata1_ex, readdata2_ex,readdata2_mem,readdata_wb,B_input;
        wire [4:0] rs1_id, rs2_id, rd_id, rs1_ex, rs2_ex, rd_ex, rd_wb,rd_mem;
        wire [2:0] funct3_id, funct3_ex;
        wire [6:0] funct7_id, funct7_ex;
        wire memread_id, memtoreg_id, memwrite_id, regwrite_id, alusrc_id;
        wire [1:0] aluop_id;
        wire regwrite_wb;
        wire [63:0] write_data;
        
        // Execute Stage Wires
        wire [63:0] alu_result_ex, alu_result_mem,alu_result_wb;
        wire zero_flag;

        // EXMEM Register Wires
        wire branch_ex, memread_ex, memtoreg_ex, memwrite_ex, regwrite_ex, alusrc_ex;
        wire [1:0] aluop_ex;
        wire branch_mem, memread_mem, memtoreg_mem, memwrite_mem, regwrite_mem;
        wire zero_flag_mem;
        wire [63:0] readdata;

        wire[1:0]forwardA,forwardB;
        wire pc_write,bubble;
        wire flush;
        
         branch_hazard bh(
         .branch(branch_mem),
         .zero_flag(zero_flag_mem),
        .flush(flush)
         );

        // Instruction Fetch Stage
        
        fetch IF (
            .clk(clk),
            .reset(reset),
            .pc(pc_if),
            .instruction(instruction_if)
        );
        
        ifid IFID (
            .clk(clk),
            .reset(reset),
            .instruction(instruction_if),
            .pc(pc_if),
            .inst_out(instruction_id),
            .pc_ifid(pc_id),
            .ifid_write(ifid_write),
            .flush(flush)
        );

    
        // Instruction Decode Stage
        decode ID (
            .clk(clk),
            .reset(reset),
            .instruction(instruction_id),
            .write_data(write_data),
            .regwrite(regwrite_wb),
            .rdin(rd_wb),
            .ReadData1(readdata1_id),
            .ReadData2(readdata2_id),
            .imm(imm_id),
            .branch_b(branch_id),
            .memread_b(memread_id),
            .memtoreg_b(memtoreg_id),
            .aluop_b(aluop_id),
            .memwrite_b(memwrite_id),
            .alusrc_b(alusrc_id),
            .regwrite_b(regwrite_id),
            .rd(rd_id),
            .rs1(rs1_id),
            .rs2(rs2_id),
            .funct3(funct3_id),
            .funct7(funct7_id),
            .bubble(bubble)
        );

            idex IDEX (
            .clk(clk),
            .reset(reset),
            .Branch(branch_id),
            .MemRead(memread_id),
            .MemtoReg(memtoreg_id),
            .MemWrite(memwrite_id),
            .RegWrite(regwrite_id),
            .ALUSrc(alusrc_id),
            .ALUOp(aluop_id),
            .pc_decode(pc_id),
            .readdata1_decode(readdata1_id),
            .readdata2_decode(readdata2_id),
            .imm(imm_id),
            .funct3(funct3_id),
            .funct7(funct7_id),
            .ifid_rs1(rs1_id),
            .ifid_rs2(rs2_id),
            .ifid_rd(rd_id),
            .pc_idex(pc_ex),
            .rs1(rs1_ex),
            .rs2(rs2_ex),
            .rd(rd_ex),
            .funct3_idex(funct3_ex),
            .funct7_idex(funct7_ex),
            .imm_idex(imm_ex),
            .readdata1_idex(readdata1_ex),
            .readdata2_idex(readdata2_ex),
            .branch_idex(branch_ex),
            .Memread_idex(memread_ex),
            .Memtoreg_idex(memtoreg_ex),
            .Memwrite_idex(memwrite_ex),
            .Regwrite_idex(regwrite_ex),
            .ALUSrc_idex(alusrc_ex),
            .ALUOp_idex(aluop_ex),
            .flush(flush),
            .bubble(bubble)
        );


        execute EX (
            .clk(clk),
            .ALUOp(aluop_ex),
            .funct7(funct7_ex),
            .funct3(funct3_ex),
            .read_data1(readdata1_ex),
            .read_data2(readdata2_ex),
            .pc(pc_ex),
            .imm(imm_ex),
            .ALUSrc(alusrc_ex),
            .valE(alu_result_ex),
            .zero_flag(zero_flag),
            .pcb(pcb),
            .meminput(alu_result_mem),
            .wbinput(write_data),
            .forwardA(forwardA),
            .forwardB(forwardB),
            .b_input(B_input)
            
        );


        exmem EXMEM (
            .clk(clk),
            .reset(reset),
            .Branch_execute(branch_ex),
            .MemRead_execute(memread_ex),
            .MemtoReg_execute(memtoreg_ex),
            .MemWrite_execute(memwrite_ex),
            .RegWrite_execute(regwrite_ex),
            .pc_execute(pcb),
            .alu_result(alu_result_ex),
            .zero_flag_execute(zero_flag),
            .rd_execute(rd_ex),
            .pc_exmem(pc_mem),
            .rd_exmem(rd_mem),
            .branch_exmem(branch_mem),
            .Memread_exmem(memread_mem),
            .Memtoreg_exmem(memtoreg_mem),
            .Memwrite_exmem(memwrite_mem),
            .Regwrite_exmem(regwrite_mem),
            .alu_result_exmem(alu_result_mem),
            .zero_flag_exmem(zero_flag_mem),
            .readdata2_ex(B_input),
            .readdata2_mem(readdata2_mem),
            .flush(flush)
        );

         pc_update PC_UPDATE (
            .clk(clk),
            .reset(reset),
            .branch(branch_mem&zero_flag_mem),
            .pcb(pc_mem),
            .pc_write(pc_write),
            .pc(pc_if)
        );

        // // Memory Stage
        data_memory MEM (
            .clock(clk),
            .reset(reset),
            .memwrite(memwrite_mem),
            .memread(memread_mem),
            .add(alu_result_mem),
            .write_data(readdata2_mem),
            .read_data(readdata)
        );

         ForwardingUnit fo (
        .ID_EX_Rs1(rs1_ex),
        .ID_EX_Rs2(rs2_ex),
        .EX_MEM_Rd(rd_mem),
        .MEM_WB_Rd(rd_wb),
        .EX_MEM_RegWrite(regwrite_mem),
        .MEM_WB_RegWrite(regwrite_wb),
        .ForwardA(forwardA),
        .ForwardB(forwardB)
    );

        memwb MEMWB (
            .clk(clk),
            .reset(reset),
            .MemtoReg_exmem(memtoreg_mem),
            .RegWrite_exmem(regwrite_mem),
            .pc_execute(pc_mem),
            .readdata_mem(readdata),
            .alu_result_mem(alu_result_mem),
            .rd_execute(rd_mem),
            .rd_memwb(rd_wb),
            .Memtoreg_memwb(memtoreg_wb),
            .Regwrite_memwb(regwrite_wb),
            .readdata_memwb(readdata_wb),
            .alu_result_memwb(alu_result_wb)
        );

        // Write Back Stage
        write_back WB (
            .clk(clk),
            .reset(reset),
            .RegWrite(regwrite_wb),
            .MemtoReg(memtoreg_wb),
            .rd(rd_wb),
            .alu_output(alu_result_wb),
            .mem_data(readdata_wb),
            .write_data(write_data)
        );

        
        hazard_unit hu(
            .instruction_id(instruction_id),
            .Memread(memread_ex),
            .idex_rd(rd_ex),
            .pc_write(pc_write),
            .ifid_write(ifid_write),
            .bubble(bubble)
        );

    endmodule
