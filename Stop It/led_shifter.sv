module led_shifter (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        shift_i,

    input  logic [15:0] switches_i,
    input  logic        load_i,

    input  logic        off_i,
    output logic [15:0] leds_o
);

// TODO
always_comb begin
   leds_d = leds_q;
   if (load_i) begin
       leds_d = switches_i;
   end else if (shift_i) begin
       leds_d = {leds_q[14:0], 1'b1};
   end
end

always_comb begin
   case (off_i)
       1: leds_o = 16'b0;
       0: leds_o = leds_q;
       default: leds_o = 16'b0;
   endcase
end

logic [15:0] leds_q, leds_d;
always_ff @(posedge clk_i) begin
   if (!rst_ni) begin
       leds_q <= 16'b0;
   end else begin
       leds_q <= leds_d;
   end
end

endmodule