module write_back(
    input clk,
    input reset,
    input RegWrite,
    input MemtoReg,
    input [4:0] rd,
    input [63:0] alu_output,
    input [63:0] mem_data,
    output [63:0] write_data
);
    // wire [63:0] write_data;
    mux_2x1 mux (
        .I0(alu_output),          // If MemtoReg is 0, select ALU output
        .I1(mem_data),            // If MemtoReg is 1, select memory data
        .S0(MemtoReg),            // Select based on MemtoReg control signal
        .O(write_data)            // Output the selected data
    );


endmodule

