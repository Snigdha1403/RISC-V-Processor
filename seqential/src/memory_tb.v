`timescale 1ns / 1ps

module data_memory_tb;

    // Inputs
    reg clock;
    reg reset;
    reg memwrite;
    reg memread;
    reg [9:0] address;
    reg [63:0] write_data;
    
    // Output
    wire [63:0] read_data;

    // Instantiate the module
    data_memory uut (
        .clock(clock),
        .reset(reset),
        .memwrite(memwrite),
        .memread(memread),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock generation (10ns period)
    always #5 clock = ~clock;

    // Task to print input/output values and memory updates
    task print_values;
        begin
            $display("Time=%0t | clk=%b | reset=%b | memwrite=%b | memread=%b | addr=%d | write_data=%b | read_data=%b",
                     $time, clock, reset, memwrite, memread, address, write_data, read_data);
        end
    endtask

    task print_memory_change;
        begin
            if (memwrite) begin
                $display(">>> Memory[%0d] changed to %b", address, write_data);
            end
        end
    endtask

    initial begin
        // Initialize signals
        clock = 0;
        reset = 1;
        memwrite = 0;
        memread = 0;
        address = 0;
        write_data = 0;

        // Apply Reset
        #10 reset = 0;
        print_values();

        // Write to memory at address 50
        #10;
        address = 10'd50;
        write_data = 64'b1010101010101010101010101010101010101010101010101010101010101010;
        memwrite = 1;
        print_values();
        #10;
        memwrite = 0;
        print_memory_change();

        // Write to memory at address 100
        #10;
        address = 10'd100;
        write_data = 64'b1111000011110000111100001111000011110000111100001111000011110000;
        memwrite = 1;
        print_values();
        #10;
        memwrite = 0;
        print_memory_change();

        // Read from memory at address 50
        #10;
        address = 10'd50;
        memread = 1;
        print_values();
        #10;
        memread = 0;

        // Read from memory at address 100
        #10;    
        address = 10'd100;
        memread = 1;
        print_values();
        #10;
        memread = 0;

        // Read from an unmodified address (should contain initial value)
        #10;
        address = 10'd10;
        memread = 1;
        print_values();
        #10;
        memread = 0;

        // End simulation
        #10;
        $finish;
    end
endmodule
