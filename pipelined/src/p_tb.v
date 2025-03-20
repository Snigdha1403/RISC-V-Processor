// Testbench
module processor_tb;
    reg clk;
    reg reset;
    
    processor uut (
        .clk(clk),
        .reset(reset)
    );
    
    initial begin
        $dumpfile("processor_tb.vcd"); // VCD file for GTKWave
        $dumpvars(0, processor_tb);    // Dump all variables in the testbench
        
        clk = 0;
        reset = 1;
        #5 reset = 0;
    end
    
    always #5 clk = ~clk;
    
    initial begin
        #150 $finish;
    end
    
    always @(posedge clk) begin
        $display("==================================================================================================================================");
        $display("Time: %0t", $time);

        // Instruction Fetch (IF) Stage
        $display("IF Stage: PC_if = %h | instruction_if = %h\n", uut.pc_if, uut.instruction_if);
        
        // Instruction Decode (ID) Stage
        $display("ID Stage: PC_id = %h | instruction_id = %h\n", uut.pc_id, uut.instruction_id);

        $display("Decode Stage: ReadData1 = %h | ReadData2 = %h | imm = %d", uut.readdata1_id, uut.readdata2_id, uut.imm_id);
        $display("Decode Control Signals: Branch = %b | MemRead = %b | MemtoReg = %b | ALUOp = %b | MemWrite = %b | ALUSrc = %b | RegWrite = %b\n", 
                 uut.branch_id, uut.memread_id, uut.memtoreg_id, uut.aluop_id, uut.memwrite_id, uut.alusrc_id, uut.regwrite_id);
        
        $display("Instruction=%h", uut.instruction_id);
        $display("Rs1=%d, Rs2=%d, MemRead=%b, idex_rd=%b, pc_write: %d, ifid_write=%b, bubble=%b\n", uut.instruction_id[19:15], uut.instruction_id[24:20], uut.memread_ex, uut.rd_ex, uut.pc_write, uut.ifid_write, uut.bubble);

        // IDEX Register Inputs
        $display("IDEX Inputs: rs1 = %h | rs2 = %h | rd = %h | funct3 = %h | funct7 = %h | imm = %d", 
                 uut.rs1_id, uut.rs2_id, uut.rd_id, uut.funct3_id, uut.funct7_id, uut.imm_id);
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------");
        // IDEX Register Outputs
        $display("IDEX Outputs: rs1 = %h | rs2 = %h | rd = %h | funct3 = %h | funct7 = %h | imm = %d", 
                 uut.rs1_ex, uut.rs2_ex, uut.rd_ex, uut.funct3_ex, uut.funct7_ex, uut.imm_ex);
        $display("IDEX Control Signals: Branch = %b | MemRead = %b | MemtoReg = %b | ALUOp = %b | MemWrite = %b | ALUSrc = %b | RegWrite = %b\n", 
                 uut.branch_ex, uut.memread_ex, uut.memtoreg_ex, uut.aluop_ex, uut.memwrite_ex, uut.alusrc_ex, uut.regwrite_ex);

        // Execution (EX) Stage
        $display("EX Stage: PC_ex = %h\n", uut.pc_ex);
        $display("Execute Inputs: ALUOp = %b | funct7 = %h | funct3 = %h | read_data1 = %h | pc = %h | imm = %d\n", 
                 uut.aluop_ex, uut.funct7_ex, uut.funct3_ex, uut.readdata1_ex, uut.pc_ex, uut.imm_ex);

        $display("ForwardA=%b        ", uut.forwardA);
        $display("ForwardB=%b\n", uut.forwardB);

        $display("read_data1 = %d, meminput = %d, wbinput = %d, forwardA[1] = %d, forwardA[0] = %d", uut.readdata1_ex, uut.alu_result_mem, uut.write_data, uut.forwardA[1], uut.forwardA[0]);
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        $display("read_data1 = %d, meminput = %d, wbinput = %d, forwardB[1] = %d, forwardB[0] = %d\n", uut.readdata2_ex, uut.alu_result_mem, uut.write_data, uut.forwardB[1], uut.forwardB[0]);
        $display("A_input = %b , B_input = %b",uut.EX.A_input,uut.EX.B_input);
        $display("Execute Outputs: ALU Result = %h | Zero Flag = %b | Branch PC = %h\n", uut.alu_result_ex, uut.zero_flag, uut.pcb);

        // EXMEM Register Inputs
        $display("EXMEM Inputs: Branch = %b | MemRead = %b | MemtoReg = %b | MemWrite = %b | RegWrite = %b | PC = %h | ALU Result = %h | Zero Flag = %b | rd = %h| B_input=%b", 
                 uut.branch_ex, uut.memread_ex, uut.memtoreg_ex, uut.memwrite_ex, uut.regwrite_ex, uut.pc_ex, uut.alu_result_ex, uut.zero_flag, uut.rd_ex, uut.B_input);
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------");
        // EXMEM Register Outputs
        $display("EXMEM Outputs: PC = %h | rd = %h | Branch = %b | MemRead = %b | MemtoReg = %b | MemWrite = %b | RegWrite = %b | ALU Result = %h | Zero Flag = %b\n|readdata2_mem", 
                 uut.pc_mem, uut.rd_mem, uut.branch_mem, uut.memread_mem, uut.memtoreg_mem, uut.memwrite_mem, uut.regwrite_mem, uut.alu_result_mem, uut.zero_flag_mem,uut.readdata2_mem);

        // Memory (MEM) Stage
        $display("MEM Stage: ReadData = %h | ALU Result = %h | PC = %h | rd = %h\n | write_Data=%b", uut.readdata, uut.alu_result_mem, uut.pc_mem, uut.rd_mem,uut.readdata2_mem);

        // MEMWB Register Inputs
        $display("MEMWB Inputs: PC = %h | rd = %h | MemtoReg = %b | RegWrite = %b | ALU Result = %h | ReadData = %h", uut.pc_mem, uut.rd_mem, uut.memtoreg_mem, uut.regwrite_mem, uut.alu_result_mem, uut.readdata);
        $display("----------------------------------------------------------------------------------------------------------------------------------------------------");
        // MEMWB Register Outputs
        $display("MEMWB Outputs: rd = %h | MemtoReg = %b | RegWrite = %b | ALU Result = %h | ReadData = %h\n", uut.rd_wb, uut.memtoreg_wb, uut.regwrite_wb, uut.alu_result_wb, uut.readdata_wb);

        // Write Back (WB) Stage
        $display("WB Stage: Write Data = %h | RegWrite = %b | rd = %h\n", uut.write_data, uut.regwrite_wb, uut.rd_wb);

    $display("reg[ 0]=%b reg[ 1]=%b reg[ 2}=%b", uut.ID.regfile.reg_memory[0],  uut.ID.regfile.reg_memory[1],  uut.ID.regfile.reg_memory[2]);
    $display("reg[ 3]=%b reg[ 4]=%b reg[ 5]=%b", uut.ID.regfile.reg_memory[3],  uut.ID.regfile.reg_memory[4],  uut.ID.regfile.reg_memory[5]);
    $display("reg[ 6]=%b reg[ 7]=%b reg[ 8]=%b", uut.ID.regfile.reg_memory[6],  uut.ID.regfile.reg_memory[7],  uut.ID.regfile.reg_memory[8]);
    $display("reg[ 9]=%b reg[10]=%b reg[11]=%b", uut.ID.regfile.reg_memory[9],  uut.ID.regfile.reg_memory[10], uut.ID.regfile.reg_memory[11]);
    $display("reg[12]=%b reg[13]=%b reg[14]=%b", uut.ID.regfile.reg_memory[12], uut.ID.regfile.reg_memory[13], uut.ID.regfile.reg_memory[14]);
    $display("reg[15]=%b reg[16]=%b reg[17]=%b", uut.ID.regfile.reg_memory[15], uut.ID.regfile.reg_memory[16], uut.ID.regfile.reg_memory[17]);
    $display("reg[18]=%b reg[19]=%b reg[20]=%b", uut.ID.regfile.reg_memory[18], uut.ID.regfile.reg_memory[19], uut.ID.regfile.reg_memory[20]);
    $display("reg[21]=%b reg[22]=%b reg[23]=%b", uut.ID.regfile.reg_memory[21], uut.ID.regfile.reg_memory[22], uut.ID.regfile.reg_memory[23]);
    $display("reg[24]=%b reg[25]=%b reg[26]=%b", uut.ID.regfile.reg_memory[24], uut.ID.regfile.reg_memory[25], uut.ID.regfile.reg_memory[26]);
    $display("reg[27]=%b reg[28]=%b reg[29]=%b", uut.ID.regfile.reg_memory[27], uut.ID.regfile.reg_memory[28], uut.ID.regfile.reg_memory[29]);
    $display("reg[30]=%b reg[31]=%b", uut.ID.regfile.reg_memory[30], uut.ID.regfile.reg_memory[31]);

        // Divider
        $display("==================================================================================================================================");
    end
endmodule
