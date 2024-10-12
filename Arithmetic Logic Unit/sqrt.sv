module sqrt(
   input  logic [7:0] a_i,
   output logic [7:0] y_o
);
   reg [7:0] ram [256];
   initial begin
       $readmemh("sqrt.memh", ram, 0, 255);
   end
   assign y_o = ram[a_i];


endmodule