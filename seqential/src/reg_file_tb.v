`timescale 1ns / 1ps

module reg_file_tb;

    // Inputs
    reg [4:0] read_reg1;
    reg [4:0] read_reg2;
    reg [4:0] write_reg;
    reg [63:0] write_data;
    reg regwrite;
    reg clock;
    reg reset;

    // Outputs
    wire [63:0] ReadData1;
    wire [63:0] ReadData2;

    // Instantiate the register file
    reg_file uut (
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2),
        .regwrite(regwrite),
        .clock(clock),
        .reset(reset)
    );

    // Clock Generation (10ns period)
    always #5 clock = ~clock;

    // Task to print full register file
    task print_registers;
        integer j;
        begin
            $display("Register File Contents:");
            for (j = 0; j < 32; j = j + 1) begin
                $display("reg_memory[%0d] = %h", j, uut.reg_memory[j]);
            end
            $display("-----------------------------");
        end
    endtask

    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        regwrite = 0;
        write_reg = 0;
        write_data = 0;
        read_reg1 = 0;
        read_reg2 = 0;

        // Case I: Apply Reset (Initialize Registers to Index Values)
        #10 reset = 1;
        #10 reset = 0; // Release reset
        print_registers();

        // Write to register 2
        write_reg = 5'd2;
        write_data = 64'h1000;
        regwrite = 1;
        #10; // Wait for a clock cycle
        regwrite = 0;
        print_registers();

        // Read registers
        read_reg1 = 5'd2;  // Expect 1000
        read_reg2 = 5'd3;  // Expect 3
        #10;
        $display("ReadData1 = %h, ReadData2 = %h", ReadData1, ReadData2);

        // Attempt to write to register 0 (should remain 0)
        write_reg = 5'd0;
        write_data = 64'hFFFF_FFFF;
        regwrite = 1;
        #10;
        regwrite = 0;
        print_registers();

        // Case II: Reset all registers to 0
        reset = 1;
        #10;
        reset = 0;
        print_registers();

        $finish;
    end
endmodule
