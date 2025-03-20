`timescale 1ns / 1ps
module processor_tb;
    reg clk;
    reg reset;
    wire [63:0] pc_value;
    wire [63:0] ReadData1, ReadData2;
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    wire [63:0] valE;
    wire zero_flag;
    wire [63:0] write_data;
    wire [63:0] read_data;
    wire BranchZero;
    wire [63:0] pcb;
    
    // Instantiate the processor
   processor uut (
    .clk(clk),
    .reset(reset),
    .pc_out(pc_value),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .ALUOp(ALUOp),
    .valE(valE),
    .zero_flag(zero_flag),
    .write_data(write_data),
    .read_data(read_data),
    .BranchZero(BranchZero),
    .pcb(pcb)
);

    
    // Clock generation
    always #10 clk = ~clk; // 10ns clock period
    
    initial begin
        $dumpfile("Processor_tb.vcd");
        $dumpvars(0, processor_tb);
        
        // Initialize signals
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        
        // Run simulation
        #100; // You may want to increase this to observe more cycles
        $finish;
    end
    
    // Display key processor signals at each cycle
    always @(posedge clk) begin
        $display("----------------------------------------------------------------------------------------------------------------------------------");
        $display("Time: %0t", $time);
        $display("Current PC = %h instruction = %h", pc_value,uut.instruction);
        $display("ReadData1 = %h, ReadData2 = %h", uut.ReadData1, uut.ReadData2);
        $display("ALU Output (valE) = %h, Zero Flag = %b", uut.valE, uut.zero_flag);
        $display("Memory Read Data = %h, Write Data = %h", uut.read_data, uut.write_data);
        $display("Control Signals: Branch=%b, MemRead=%b, MemtoReg=%b, MemWrite=%b, ALUSrc=%b, RegWrite=%b, ALUOp=%b", 
                 uut.Branch, uut.MemRead, uut.MemtoReg, uut.MemWrite, uut.ALUSrc, uut.RegWrite, uut.ALUOp);
        $display("----------------------------------------------------------------------------------------------------------------------------------");
    end
endmodule

