module and_gate(input A, B, output rd);
    assign rd = A & B;
endmodule

module xor_gate(input A, B, output rd);
    assign rd = A ^ B;
endmodule

module or_gate(input A, B, output rd);
    assign rd = A | B;
endmodule

module not_gate(input B, output bdash);
    assign bdash = ~B;
endmodule

module AND(input [63:0]A,B, output [63:0] rd);
        genvar i;
        generate
            for(i=0;i<64;i=i+1)begin
                and_gate a1(.A(A[i]), .B(B[i]), .rd(rd[i]));
            end
        endgenerate
endmodule 

module XOR(input [63:0]A,B, output [63:0] rd);
        genvar i;
        generate
            for(i=0;i<64;i=i+1)begin
                xor_gate a2(.A(A[i]), .B(B[i]), .rd(rd[i]));
            end
        endgenerate
endmodule 


module OR(input [63:0]A,B, output [63:0] rd);
        genvar i;
        generate
            for(i=0;i<64;i=i+1)begin
                or_gate x3(.A(A[i]), .B(B[i]), .rd(rd[i]));
            end
        endgenerate
endmodule

module ADD_using_cla(input [63:0] A, B, input cin, output [63:0] sum, output c_out);
    wire [63:0] g, p;
    wire [64:0]c;
    genvar i, j, k, l;
    generate 
        for(i = 0; i < 64; i = i + 1) begin
            and_gate a1(.A(A[i]), .B(B[i]), .rd(g[i]));
        end 
        for(j = 0; j < 64; j = j + 1) begin
            xor_gate a2(.A(A[j]), .B(B[j]), .rd(p[j]));
        end 
    endgenerate

    assign c[0] = cin;

    generate 
        for(k = 0; k < 64; k = k + 1) begin
            xor_gate a3(.A(p[k]), .B(c[k]), .rd(sum[k]));
        end 
        for(l = 0; l < 64; l = l + 1) begin
            wire temp;
            and_gate a4(.A(p[l]), .B(c[l]), .rd(temp));
            or_gate a5(.A(g[l]), .B(temp), .rd(c[l + 1]));
        end 
    endgenerate 
    assign c_out = c[64];
endmodule

module ADD(
    input signed [63:0] A, B, 
    input cin, 
    output signed [63:0] sum,  
    output carry, 
    output reg overflow  
);
    ADD_using_cla a1(.A(A), .B(B), .cin(cin), .sum(sum), .c_out(carry));

    always @(*) begin
        overflow = 0;
        if ((A[63] == B[63]) && (sum[63] != A[63])) begin
            overflow = 1;
        end
    end
endmodule

module SUB(
    input signed [63:0] A, B, 
    input cin, 
    output signed [63:0] sum,  
    output carry, 
    output reg borrow,
    output reg overflow  
);
    wire [63:0] com; 
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin
            not_gate a1(.B(B[i]), .bdash(com[i]));
        end
    endgenerate

    ADD_using_cla a2(.A(A), .B(com), .cin(cin), .sum(sum), .c_out(carry));

    always @(*) begin
        overflow = 0;
        if ((A[63] != B[63]) && (sum[63] != A[63])) begin
            overflow = 1;
        end
    end

     always @(*)begin
        if(B==4'b0000)begin 
            borrow =1'b0;
          end else if(A[63]==1 && B[63]==0)begin
              borrow = 1'b1;
          end else if(A[63]==0 && B[63]==1)begin
              borrow = 1'b0;
          end else begin
              borrow = sum[63];
          end
    end
endmodule

module xor3(input A, B, C, output diff);
    assign diff = A ^ B ^ C; 
endmodule 

module or3(input A, B, C, output bout);
    assign bout = A | B | C;
endmodule

module full_sub(
    input A, B, bin,
    output diff, bout
);
    xor3 h1(A, B, bin, diff); 
    wire e, f, g;
    and_gate l1(.A(A),.B(bin),.rd(e));
    and_gate l2(.A(A),.B(B),.rd(g));
    and_gate l3(.A(B),.B(bin),.rd(f));
    or3 g1(.A(e), .B(f), .C(g), .bout(bout)); 
endmodule

module SUB2(
    input [64:0] A, B,
    input cin,
    output [64:0] sum
);
    wire [64:0] com;
    wire [65:0] c;
    assign c[0] = cin;
    genvar l;
    generate
        for(l = 0; l < 65; l = l + 1) begin
            not_gate inverter(.B(B[l]), .bdash(com[l]));
        end
    endgenerate
    genvar k;
    generate
        for(k = 0; k < 65; k = k + 1) begin
            full_sub FS(.A(A[k]), .B(com[k]), .bin(c[k]), .diff(sum[k]), .bout(c[k+1]));
        end
    endgenerate
endmodule

module SLT(input signed [63:0] A,B, output reg rd);
        wire r;
        wire [63:0] sum;
        wire carry;
        wire overflow;
        wire borrow;
        SUB y6(A,B,1'b1,sum,carry,borrow,overflow);
        always @(*) begin
            if(borrow==1)begin
                rd =1'b1;
            end else if(A[63]==1 && B==64'b0000)begin 
                rd =1'b1;
            end else if(A[63]==0 && B==64'b0000)begin 
                rd =1'b0;
            end else begin 
                rd =1'b0;
            end
        end
endmodule  


module SLTU(input [63:0] A,B, output reg rd);
        wire r;
        wire [64:0] sum;
        wire [64:0] a,b;
        assign a = {1'b0,A};
        assign b = {1'b0,B};
        SUB2 a1(.A(a), .B(b), .cin(1'b1), .sum(sum));
        always @(*)begin
                rd = sum[64];
        end
endmodule 
 
module SLL(input [63:0] A , input [5:0]shift, output  [63:0] out);
        reg [63:0] s1,s2,s3,s4,s5,s6;
        always @(*)begin
            if (shift[5]==1)begin
                s1[63:32]=A[31:0];
                s1[31:0]= 32'b0;
            end else begin
                s1 = A;
            end

            if (shift[4]==1)begin
                s2[63:16]=s1[47:0];
                s2[15:0]= 16'b0;
            end else begin
                s2 = s1;
            end

            if (shift[3]==1)begin
                s3[63:8]=s2[55:0];
                s3[7:0]= 8'b0;
            end else begin
                s3 = s2;
            end

            if (shift[2]==1)begin
                s4[63:4]=s3[59:0];
                s4[3:0]= 4'b0;
            end else begin
                s4 = s3;
            end

            if (shift[1]==1)begin
                s5[63:2]=s4[61:0];
                s5[1:0]= 2'b0;
            end else begin
                s5 = s4;
            end

            if (shift[0]==1)begin
                s6[63:1]=s5[62:0];
                s6[0]= 1'b0;
            end else begin
                s6 = s5;
            end
        end 
        assign out = s6;
endmodule 

module SRL(input [63:0] A, input [5:0] shift, output [63:0] out);
    reg [63:0] s1, s2, s3, s4, s5, s6;
    always @(*) begin
        if (shift[5] == 1) begin
            s1[63:32] = 32'b0;
            s1[31:0] = A[63:32];
        end else begin
            s1 = A;
        end

        if (shift[4] == 1) begin
            s2[63:16] = 16'b0;
            s2[47:0] = s1[63:16];
        end else begin
            s2 = s1;
        end

        if (shift[3] == 1) begin
            s3[63:8] = 8'b0;
            s3[55:0] = s2[63:8];
        end else begin
            s3 = s2;
        end

        if (shift[2] == 1) begin
            s4[63:4] = 4'b0;
            s4[59:0] = s3[63:4];
        end else begin
            s4 = s3;
        end

        if (shift[1] == 1) begin
            s5[63:2] = 2'b0;
            s5[61:0] = s4[63:2];
        end else begin
            s5 = s4;
        end

        if (shift[0] == 1) begin
            s6[63:1] = 1'b0;
            s6[62:0] = s5[63:1];
        end else begin
            s6 = s5;
        end
    end
    
    assign out = s6;
endmodule

module SRA(input [63:0] A, input [5:0] shift, output [63:0] out);
    reg [63:0] s1, s2, s3, s4, s5, s6;
    always @(*) begin
        if (shift[5]) begin
            s1 = {{32{A[63]}}, A[63:32]};
        end else begin
            s1 = A;
        end

        if (shift[4]) begin
            s2 = {{16{s1[63]}}, s1[63:16]};
        end else begin
            s2 = s1;
        end

        if (shift[3]) begin
            s3 = {{8{s2[63]}}, s2[63:8]};
        end else begin
            s3 = s2;
        end

        if (shift[2]) begin
            s4 = {{4{s3[63]}}, s3[63:4]};
        end else begin
            s4 = s3;
        end

        if (shift[1]) begin
            s5 = {{2{s4[63]}}, s4[63:2]};
        end else begin
            s5 = s4;
        end

        if (shift[0]) begin
            s6 = {{1{s5[63]}}, s5[63:1]};
        end else begin
            s6 = s5;
        end
    end
    assign out = s6;
endmodule


