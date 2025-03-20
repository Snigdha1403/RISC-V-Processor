module hazard_unit(
    input [31:0] instruction_id,
    input Memread,
    input [4:0]idex_rd,
    output reg pc_write,
    output reg ifid_write,
    output reg bubble
);

    wire [4:0] rs1, rs2;// Corrected bit-width of rs1, rs2, and rd


    assign rs1 = instruction_id[19:15]; 
    assign rs2 = instruction_id[24:20];

   initial begin

    pc_write = 1'b1;
        ifid_write = 1'b1;
        bubble = 1'b0;
   end
    always @(*) begin

        pc_write = 1'b1;
        ifid_write = 1'b1;
        bubble = 1'b0;

        // Load-use hazard detection
        if ((rs1 != 5'b0 && rs1 == idex_rd && Memread) ||
            (rs2 != 5'b0 && rs2 == idex_rd && Memread)) begin
            pc_write = 1'b0;   
            ifid_write = 1'b0; // Stall IF/ID register
            bubble = 1'b1;     // Insert a bubble
        end
    end
    // always @(*)begin
    //     $display("pc write: %d, ifid write=%b, bubble=%b\n",pc_write,ifid_write,bubble);
    // end
endmodule
