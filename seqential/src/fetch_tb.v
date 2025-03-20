`timescale 1ns / 1ps

module fetch_tb();
    // Inputs
    reg clk;
    reg reset;
    reg [63:0] pc;
    
    // Outputs
    wire [31:0] instruction;
    
    // Instantiate the Unit Under Test (UUT)
    fetch uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction)
    );
    
    
    // Create instruction memory file for testing
    initial begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0, fetch_tb);
        
        // Load instructions from a file into memory
        $readmemh("instructions.mem", uut.instruction_memory);
    end
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Monitor the signals
    initial begin
        $monitor("Time: %0t | clk: %b | reset: %b | PC: %h | Instruction: %h", $time, clk, reset, pc, instruction);
    end
    
    // Test sequence
    initial begin
        reset = 1;
        pc = 32'h00000000;
        #10;
        reset = 0;
        while (pc <= 80) begin
            #10; 
                 pc = pc + 64'h00000004;
           // Increment PC to fetch the next instruction
        end
        $finish;
    end
endmodule