module fetch(
    input clk,
    input reset,
    input [63:0] pc,
    output reg [31:0] instruction
    
);

reg [31:0] instruction_memory [0:255];  
 integer i;
initial begin
   
    for (i = 0; i < 256; i = i + 1) begin
        instruction_memory[i] = 32'h00000013;
    end
    $readmemh("instructions.mem", instruction_memory);
    
end

    always @(posedge reset) begin
        if (reset) begin
            instruction <= 32'h00000013;  // Reset instruction to NOP 
        end 
        end 
        always @(*) begin
            instruction <= instruction_memory[pc >> 2]; // Fetch instruction
        end
// always @(*) begin
//      $display("inside fetch time = %0t ,instruction = %h",$time,instruction);
// end

 
endmodule

