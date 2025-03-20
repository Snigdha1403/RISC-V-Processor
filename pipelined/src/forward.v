// module ForwardingUnit(
//     input [4:0] ID_EX_Rs1, ID_EX_Rs2, EX_MEM_Rd, MEM_WB_Rd,
//     input EX_MEM_RegWrite, MEM_WB_RegWrite,
//     output reg [1:0] ForwardA, ForwardB
// );

//     wire match_EX_MEM_Rs1, match_EX_MEM_Rs2;
//     wire match_MEM_WB_Rs1, match_MEM_WB_Rs2;
    
//     // Comparator for EX/MEM stage
//     assign match_EX_MEM_Rs1 = ((EX_MEM_RegWrite && (EX_MEM_Rd != 0)) && (EX_MEM_Rd == ID_EX_Rs1));
//     assign match_EX_MEM_Rs2 = ((EX_MEM_RegWrite && (EX_MEM_Rd != 0)) && (EX_MEM_Rd == ID_EX_Rs2));

//     // Comparator for MEM/WB stage
//     assign match_MEM_WB_Rs1 = ((MEM_WB_RegWrite && (MEM_WB_Rd != 0)) && (MEM_WB_Rd == ID_EX_Rs1));
//     assign match_MEM_WB_Rs2 = ((MEM_WB_RegWrite && (MEM_WB_Rd != 0)) && (MEM_WB_Rd == ID_EX_Rs2));

//     // Forwarding MUX logic using if-else
//     always @(*) begin
//         // Default: No forwarding
//         ForwardA = 2'b00;
//         ForwardB = 2'b00;

//         // Display input values
//         $display("-------------------------------------------------");
//         $display("ID_EX_Rs1 = %d, ID_EX_Rs2 = %d", ID_EX_Rs1, ID_EX_Rs2);
//         $display("EX_MEM_Rd = %d, EX_MEM_RegWrite = %b", EX_MEM_Rd, EX_MEM_RegWrite);
//         $display("MEM_WB_Rd = %d, MEM_WB_RegWrite = %b", MEM_WB_Rd, MEM_WB_RegWrite);
        
//         // Display matching conditions
//         $display("match_EX_MEM_Rs1 = %b, match_EX_MEM_Rs2 = %b", match_EX_MEM_Rs1, match_EX_MEM_Rs2);
//         $display("match_MEM_WB_Rs1 = %b, match_MEM_WB_Rs2 = %b", match_MEM_WB_Rs1, match_MEM_WB_Rs2);

//         // Check EX/MEM hazards first
//         if (match_EX_MEM_Rs1) begin
//             ForwardA = 2'b10;
//             // $display("ForwardA set to 2'b10 (EX/MEM hazard detected)");
//         end else if (match_MEM_WB_Rs1) begin
//             ForwardA = 2'b01;
//             // $display("ForwardA set to 2'b01 (MEM/WB hazard detected)");
//         end

//         if (match_EX_MEM_Rs2) begin
//             ForwardB = 2'b10;
//             // $display("ForwardB set to 2'b10 (EX/MEM hazard detected)");
//         end else if (match_MEM_WB_Rs2) begin
//             ForwardB = 2'b01;
//             // $display("ForwardB set to 2'b01 (MEM/WB hazard detected)");
//         end

//         // Display final forwarding decisions
//         $display("Final ForwardA = %b, ForwardB = %b", ForwardA, ForwardB);
//         $display("-------------------------------------------------");
//     end

// endmodule

module ForwardingUnit(
    input [4:0] ID_EX_Rs1, ID_EX_Rs2, EX_MEM_Rd, MEM_WB_Rd,
    input EX_MEM_RegWrite, MEM_WB_RegWrite,
    output reg [1:0] ForwardA, ForwardB
);

    always @(*) begin
        // ForwardA logic
        if ((EX_MEM_Rd == ID_EX_Rs1) && (EX_MEM_RegWrite != 0) && (EX_MEM_Rd != 0)) begin
            ForwardA = 2'b10; // Forward from EX/MEM stage
        end
        else begin
            // Not forwarding from EX/MEM, check MEM/WB
            if ((MEM_WB_Rd == ID_EX_Rs1) && (MEM_WB_RegWrite != 0) && (MEM_WB_Rd != 0) && 
                !((EX_MEM_Rd == ID_EX_Rs1) && (EX_MEM_RegWrite != 0) && (EX_MEM_Rd != 0))) begin
                ForwardA = 2'b01; // Forward from MEM/WB stage
            end
            else begin
                ForwardA = 2'b00; // No forwarding
            end
        end

        //         $display("-------------------------------------------------");
        // $display("ID_EX_Rs1 = %d, ID_EX_Rs2 = %d", ID_EX_Rs1, ID_EX_Rs2);
        // $display("EX_MEM_Rd = %d, EX_MEM_RegWrite = %b", EX_MEM_Rd, EX_MEM_RegWrite);
        // $display("MEM_WB_Rd = %d, MEM_WB_RegWrite = %b", MEM_WB_Rd, MEM_WB_RegWrite);

        // Display matching conditions
        // $display("match_EX_MEM_Rs1 = %b, match_EX_MEM_Rs2 = %b", match_EX_MEM_Rs1, match_EX_MEM_Rs2);
        // $display("match_MEM_WB_Rs1 = %b, match_MEM_WB_Rs2 = %b", match_MEM_WB_Rs1, match_MEM_WB_Rs2);


        // ForwardB logic
        if ((EX_MEM_Rd == ID_EX_Rs2) && (EX_MEM_RegWrite != 0) && (EX_MEM_Rd != 0)) begin
            ForwardB = 2'b10; // Forward from EX/MEM stage
        end
        else begin
            // Not forwarding from EX/MEM, check MEM/WB
            if ((MEM_WB_Rd == ID_EX_Rs2) && (MEM_WB_RegWrite != 0) && (MEM_WB_Rd != 0) && 
                !((EX_MEM_Rd == ID_EX_Rs2) && (EX_MEM_RegWrite != 0) && (EX_MEM_Rd != 0))) begin
                ForwardB = 2'b01; // Forward from MEM/WB stage
            end
            else begin
                ForwardB = 2'b00; // No forwarding
            end
        end

        $display("ForwardA=%b",ForwardA );
        $display("ForwardB=%b",ForwardB );
    end

endmodule
