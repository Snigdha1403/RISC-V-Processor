module fetch(
    input clk,
    input reset,
    input [63:0] pc,
    output reg [31:0] instruction
);

reg [31:0] instruction_memory [0:255];  
integer i;
initial begin
    // Initialize the memory with a default value
    for (i = 0; i < 256; i = i + 1) begin
        instruction_memory[i] = 32'h00000013;  // NOP by default
    end

    // Read instructions from the file and print them
    $readmemh("instructions.mem", instruction_memory);

    // Display the instructions as they are loaded into memory
    // for (i = 0; i < 256; i = i + 1) begin
    //     $display("instruction_memory[%0d] = %h", i, instruction_memory[i]);
    // end
end

always @( posedge reset) begin
    if (reset) begin
        instruction <= 32'h00000013;  // Reset instruction to NOP
    end 
end
always @(*) begin
 instruction <= instruction_memory[pc >> 2]; 
end

endmodule
