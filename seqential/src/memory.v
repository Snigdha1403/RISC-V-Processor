// `include "data_memory.v"
module data_memory (
    input wire clock,
    input wire reset,
    input wire memwrite,
    input wire memread,
    input wire [63:0] add,  // 10-bit address to access 1024 entries
    input wire [63:0] write_data,
    output reg [63:0] read_data
);

    reg [63:0] memory [1023:0];
    integer i;
    wire [9:0] address = add[9:0];
    always @( posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1)
                memory[i] <= i;  // Initialize all 1024 memory entries with zeros
        end 
     
    end

    always @(*) begin
        if (memwrite) begin
            memory[address] <= write_data;
             
        end
        if (memread) begin
         
        read_data = memory[address];  // Read data from memory at the specified address
        end 
        else begin
        read_data = 64'b0;
        end
        
        
    end
    always @(posedge clock)begin
        $display("**************************************************************************************************************************************************************");
          for (i = 0; i < 32; i = i + 1) 
        begin
            $display("memory[%0d] = %b", i, memory[i]);
        end
        $display("************************************************************************************************************************************************************");
    end
endmodule 
