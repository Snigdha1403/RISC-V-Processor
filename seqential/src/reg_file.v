module reg_file(
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [63:0] write_data,
    output  [63:0] ReadData1,
    output  [63:0] ReadData2,
    input regwrite,
    input clock,
    input reset
);
    reg [63:0] reg_memory [31:0]; 
    integer i;
    
    // Reset registers only once
    always @(posedge reset) begin
        if (reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            reg_memory[i] <= 64'b0;
        end

        reg_memory[1] <= 64'd1;
        reg_memory[2] <= 64'd2;
        reg_memory[4] <= 64'd4;
        reg_memory[5] <= 64'd5;
        reg_memory[7] <= 64'd7;
        reg_memory[8] <= 64'd8;
        reg_memory[11] <= 64'd11;
        reg_memory[10] <= 64'd10;
        reg_memory[12] <= 64'd12;
        reg_memory[17] <= 64'b0111111111111111111111111111111111111111111111111111111111111111;  //max +ve value
        reg_memory[18] <= 64'b1000000000000000000000000000000000000000000000000000000000000000;
        reg_memory[19] <= 64'b1111111111111111111111111111111111111111111111111111111111111111;
        reg_memory[30] <= 64'b1010101010101010101010101010101010101010101010101010101010101010;
        reg_memory[31] <= 64'b1111111111111111111111111111111111111111111111111111111111111100;
        end
        
        // if(clock) begin
        //      if (regwrite && write_reg != 5'b00000)
        //       begin
        //     reg_memory[write_reg] <= write_data;
        //      for (i = 0; i < 13; i = i + 1) begin
        //     $display("reg_memory[%0d] = %b", i, reg_memory[i]);
        //      end
        // end
        // end
    end
    always @(posedge clock) begin
         if (regwrite && write_reg != 5'b00000)
              begin
            reg_memory[write_reg] <= write_data;
             
              end

              for (i = 0; i < 32; i = i + 1) begin
            $display("reg_memory[%0d] = %b", i, reg_memory[i]);
             end
    end

    // Read register values (combinational logic)
    // always @(*) begin
        assign ReadData1 = reg_memory[read_reg1];
        assign ReadData2 = reg_memory[read_reg2];
      
    // end
endmodule

