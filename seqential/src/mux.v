
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