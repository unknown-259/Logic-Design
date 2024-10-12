
module flog2(
   input   logic [7:0] b_i,
   output  logic [7:0] y_o
);

   always_comb begin
       if (b_i[7]) begin
           y_o = 7;
       end else if (b_i[6]) begin
           y_o = 6;
       end else if (b_i[5]) begin
           y_o = 5;
       end else if (b_i[4]) begin
           y_o = 4;
       end else if (b_i[3]) begin
           y_o = 3;
       end else if (b_i[2]) begin
           y_o = 2;
       end else if (b_i[1]) begin
           y_o = 1;
       end else if (b_i[0]) begin
           y_o = 0;
       end else
            y_o = 0;
   end


endmodule