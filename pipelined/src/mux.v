module mux_2x1 (
    input wire [63:0] I0,   
    input wire [63:0] I1,   
    input wire S0,          
    output wire [63:0] O   
);
  
    wire [63:0] and0_out, and1_out; 
    wire n_sel;
    
    not (n_sel, S0);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            and and0 (and0_out[i], I0[i], n_sel);  
            and and1 (and1_out[i], I1[i], S0);   
            or  or0  (O[i], and0_out[i], and1_out[i]);  
        end
    endgenerate
    
endmodule

module mux_3x1 (
    input wire [63:0] I0,   
    input wire [63:0] I1,   
    input wire [63:0] I2,   
    input wire S0,          
    input wire S1,          
    output wire [63:0] O   
);
  
    wire [63:0] andI0_out, andI1_out, andI2_out; 
    wire n_s0, n_s1;
    
    not (n_s0, S0);
    not (n_s1, S1);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_3x1_loop
            and and0 (andI0_out[i], I0[i], n_s0, n_s1);  
            and and1 (andI1_out[i], I1[i], S0, n_s1);   
            and and2 (andI2_out[i], I2[i], n_s0, S1);   
            or  or0  (O[i], andI0_out[i], andI1_out[i], andI2_out[i]);  
        end
    endgenerate
    
endmodule

module mux_4x1 (
    input wire [63:0] I0,   
    input wire [63:0] I1,   
    input wire [63:0] I2,   
    input wire [63:0] I3,
    input wire S0,          
    input wire S1,  
    input wire ALUSrc,        
    output wire [63:0] O   
);
  
    wire [63:0] andI0_out, andI1_out, andI2_out, andI3_out; 
    wire n_s0, n_s1;
    wire S0_actual, S1_actual;

    

    // Override select lines if ALUSrc is high
    assign S0_actual = ALUSrc ? 1'b1 : S0;
    assign S1_actual = ALUSrc ? 1'b1 : S1;
    not (n_s0, S0_actual);
    not (n_s1, S1_actual);

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_4x1_loop
            and and0 (andI0_out[i], I0[i], n_s0, n_s1);  
            and and1 (andI1_out[i], I1[i], S0_actual, n_s1);   
            and and2 (andI2_out[i], I2[i], n_s0, S1_actual);  
            and and3 (andI3_out[i], I3[i], S0_actual, S1_actual); 
            or  or0  (O[i], andI0_out[i], andI1_out[i], andI2_out[i], andI3_out[i]);  
        end
    endgenerate
    
endmodule
