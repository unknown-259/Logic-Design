module basys3_7seg_driver (
   input              clk_1k_i,
   input              rst_ni,

   input  logic       digit0_en_i,
   input  logic [3:0] digit0_i,
   input  logic       digit1_en_i,
   input  logic [3:0] digit1_i,
   input  logic       digit2_en_i,
   input  logic [3:0] digit2_i,
   input  logic       digit3_en_i,
   input  logic [3:0] digit3_i,

   output logic [3:0] anode_o,
   output logic [6:0] segments_o
);

// TODO
hex7seg segment_decoder (
   .d3(current_digit[3]),
   .d2(current_digit[2]),
   .d1(current_digit[1]),
   .d0(current_digit[0]),
   .A(seg_o[0]),
   .B(seg_o[1]),
   .C(seg_o[2]),
   .D(seg_o[3]),
   .E(seg_o[4]),
   .F(seg_o[5]),
   .G(seg_o[6])
);

logic [3:0] current_digit;

logic [6:0] seg_o;
always_comb begin
   if (anode_o == 4'b1111) begin
       segments_o = 7'b1111111;
   end else begin
       segments_o = ~seg_o;
   end
end

always_comb begin
   digit_select_d = digit_select_q;
   anode_o = 4'b1111;
   case (digit_select_q)
       2'b00: begin
           if (digit0_en_i) begin
               anode_o = 4'b1110;
           end
           current_digit = digit0_i;
       end
       2'b01: begin
           if (digit1_en_i) begin
               anode_o = 4'b1101;
           end
           current_digit = digit1_i;
       end
       2'b10: begin
           if (digit2_en_i) begin
               anode_o = 4'b1011;
           end
           current_digit = digit2_i;
       end
       2'b11: begin
           if (digit3_en_i) begin
               anode_o = 4'b0111;
           end
           current_digit = digit3_i;
       end
       default: begin
           current_digit = 4'b0000;
           anode_o = 4'b1111;
       end
   endcase
end

logic [1:0] digit_select_d, digit_select_q;
always_ff @(posedge clk_1k_i) begin
   if (!rst_ni) begin
       digit_select_q <= 2'b00;
   end else begin
       digit_select_q <= digit_select_d + 2'b01;
   end
end

endmodule