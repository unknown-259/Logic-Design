module stop_it import stop_it_pkg::*; (
   input  logic        rst_ni,

   input  logic        clk_4_i,
   input  logic        go_i,
   input  logic        stop_i,
   input  logic        load_i,

   input  logic [15:0] switches_i,
   output logic [15:0] leds_o,

   output logic        digit0_en_o,
   output logic [3:0]  digit0_o,
   output logic        digit1_en_o,
   output logic [3:0]  digit1_o,
   output logic        digit2_en_o,
   output logic [3:0]  digit2_o,
   output logic        digit3_en_o,
   output logic [3:0]  digit3_o
);

// TODO
// Instantiate and drive all required nets and modules

logic [4:0] rand_o;
logic lfsr_next;
logic lfsr_rst_ni;
lfsr lfsr (
   .clk_i(clk_4_i),
   .rst_ni(lfsr_rst_ni & rst_ni),
   .next_i(lfsr_next),
   .rand_o(rand_o)
);

logic game_enable;
logic game_rst_ni;
logic [4:0] game_count;
game_counter game_counter (
   .clk_4_i(clk_4_i),
   .rst_ni(game_rst_ni & rst_ni),
   .en_i(game_enable),
   .count_o(game_count)
);

logic time_enable;
logic time_rst_ni;
logic [4:0] time_count;
logic [4:0] target_number;
time_counter time_counter (
   .clk_4_i(clk_4_i),
   .rst_ni(time_rst_ni & rst_ni),
   .en_i(time_enable),
   .count_o(time_count)
);

logic leds_shift;
logic leds_off;
logic leds_load;
logic leds_rst_ni;
led_shifter led_shifter (
   .clk_i(clk_4_i),
   .rst_ni(leds_rst_ni & rst_ni),
   .shift_i(leds_shift),
   .switches_i(switches_i),
   .load_i(leds_load),
   .off_i(leds_off),
   .leds_o(leds_o)
);

state_t state_d, state_q;
always_ff @(posedge clk_4_i) begin
   if (!rst_ni) begin
       state_q <= WAITING_TO_START;
   end else begin
       state_q <= state_d;
   end
end

logic winner_d, winner_q;
logic winner_rst_ni;
always_ff @(posedge clk_4_i) begin
   if (!winner_rst_ni) begin
       winner_q <= 1'b0;
   end else begin
       winner_q <= winner_d;
   end
end

always_comb begin
   state_d = state_q;
   winner_d = winner_q;
   time_rst_ni = 1'b1;

   // TODO
   target_number = 5'b0;
   digit0_o = game_count[3:0];
   digit1_o = game_count[4];
   digit2_o = target_number[3:0];
   digit3_o = target_number[4];
   digit0_en_o = 1'b0;
   digit1_en_o = 1'b0;
   digit2_en_o = 1'b0;
   digit3_en_o = 1'b0;
   game_enable = 1'b0;
   time_enable = 1'b0;
   leds_rst_ni = 1'b1;
   lfsr_rst_ni = 1'b1;
   game_rst_ni = 1'b1;
   winner_rst_ni = 1'b1;
   leds_load = 1'b0;
   leds_shift = 1'b0;
   leds_off = 1'b0;
   lfsr_next = 1'b0;

   unique case (state_q)
       WAITING_TO_START: begin
           leds_off = 1'b0;
           leds_rst_ni = 1'b1;
           lfsr_next = 1'b1;
           time_rst_ni = 1'b1;
           digit0_en_o = 1'b1;
           digit1_en_o = 1'b1;
           digit2_en_o = 1'b0;
           digit3_en_o = 1'b0;
           leds_shift = 1'b0;
           winner_rst_ni = 1'b0;

           if (go_i) begin
               lfsr_next = 1'b1;
               time_rst_ni = 1'b0;
               state_d = STARTING;
           end else if (load_i == 1'b1) begin
               leds_load = 1'b1;
           end else begin
               leds_load = 1'b0;
           end
       end
       STARTING: begin
           // load a random target number
           lfsr_next = 1'b0;
           digit0_en_o = 1'b1;
           digit1_en_o = 1'b1;
           digit2_en_o = 1'b1;
           digit3_en_o = 1'b1;

           target_number = rand_o;

           // wait 2 seconds
           time_rst_ni = 1'b1;
           time_enable = 1'b1;
           if (time_count == 5'd7) begin
               time_enable = 1'b0;
               time_rst_ni = 1'b0;
               game_rst_ni = 1'b0;
               state_d = DECREMENTING;
           end
       end
       DECREMENTING: begin
           time_rst_ni = 1'b1;
           game_rst_ni = 1'b1;
           game_enable = 1'b1;

           digit0_en_o = 1'b1;
           digit1_en_o = 1'b1;
           digit2_en_o = 1'b1;
           digit3_en_o = 1'b1;

           if (stop_i) begin
               game_enable = 1'b0;
               if (target_number == game_count) begin
                   time_rst_ni = 1'b0;
                   state_d = CORRECT;
                   if (leds_o == 16'hFFFF) begin
                        winner_d = 1'b1;
                   end
               end else if (target_number != game_count) begin
                   state_d = WRONG;
               end
           end
       end
       WRONG: begin
           time_enable = 1'b1;
           lfsr_next = 1'b1;
           // alternating flashing anodes
           if ((time_count % 2) == 0) begin
               digit0_en_o = 1'b1;
               digit1_en_o = 1'b1;
               digit2_en_o = 1'b0;
               digit3_en_o = 1'b0;
           end else if ((time_count % 2) == 1) begin
               digit0_en_o = 1'b0;
               digit1_en_o = 1'b0;
               digit2_en_o = 1'b1;
               digit3_en_o = 1'b1;
           end

           if (time_count == 5'd15) begin
               time_enable = 1'b0;
               time_rst_ni = 1'b0;
               state_d = WAITING_TO_START;
           end
       end
       CORRECT: begin
           lfsr_next = 1'b1;
           time_rst_ni = 1'b1;
           time_enable = 1'b1;

           // flash anodes synchronously
           if ((time_count % 2) == 0) begin
               digit0_en_o = 1'b1;
               digit1_en_o = 1'b1;
               digit2_en_o = 1'b1;
               digit3_en_o = 1'b1;
           end else if ((time_count % 2) == 1) begin
               digit0_en_o = 1'b0;
               digit1_en_o = 1'b0;
               digit2_en_o = 1'b0;
               digit3_en_o = 1'b0;
           end

           // wait 4 seconds
           if (time_count == 5'd15) begin
               time_enable = 1'b0;
               time_rst_ni = 1'b0;
               if (winner_q == 1'b1) begin
                   winner_rst_ni = 1'b0;
                   state_d = WON;
               end else begin
                   leds_shift = 1'b1;
                   state_d = WAITING_TO_START;
               end
           end
       end
       WON: begin
           winner_rst_ni = 1'b0;
           time_enable = 1'b1;

           if (!rst_ni) begin
               leds_rst_ni = 1'b0;
               time_rst_ni = 1'b0;
               game_rst_ni = 1'b0;
               state_d = WAITING_TO_START;
           end

           // flash leds
           if ((time_count % 2) == 0) begin
               leds_off = 1'b0;
           end else if ((time_count % 2) == 1) begin
               leds_off = 1'b1;
           end
       end
       default: begin
           state_d = WAITING_TO_START;
       end
   endcase
end

endmodule