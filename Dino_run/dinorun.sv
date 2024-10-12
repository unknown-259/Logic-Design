module dinorun import dinorun_pkg::*; (
   input  logic       clk_25_175_i,
   input  logic       rst_ni,

   input  logic       start_i,
   input  logic       up_i,
   input  logic       down_i,

   output logic       digit0_en_o,
   output logic [3:0] digit0_o,
   output logic       digit1_en_o,
   output logic [3:0] digit1_o,
   output logic       digit2_en_o,
   output logic [3:0] digit2_o,
   output logic       digit3_en_o,
   output logic [3:0] digit3_o,

   output logic [3:0] vga_red_o,
   output logic [3:0] vga_green_o,
   output logic [3:0] vga_blue_o,
   output logic       vga_hsync_o,
   output logic       vga_vsync_o
);

logic vga_rst_ni;
logic vga_hsync;
logic vga_vsync;
logic vga_visible;
logic [9:0] position_x, position_y;
vga_timer vga_timer (
   .clk_i(clk_25_175_i),
   .rst_ni(vga_rst_ni & rst_ni),
   .hsync_o(vga_hsync),
   .vsync_o(vga_vsync),
   .visible_o(vga_visible),
   .position_x_o(position_x),
   .position_y_o(position_y)
);

logic seg_rst_ni;
basys3_7seg_driver basys3_7seg_driver (
   .clk_1k_i(clk_25_175_i),
   .rst_ni(seg_rst_ni & rst_ni),
   .digit0_en_i(digit0_en_o),
   .digit1_en_i(digit1_en_o),
   .digit2_en_i(digit2_en_o),
   .digit3_en_i(digit3_en_o),
   .digit0_i(digit0_o),
   .digit1_i(digit1_o),
   .digit2_i(digit2_o),
   .digit3_i(digit3_o)
);

logic lfsr_rst_ni;
logic lfsr_next;
logic [15:0] lfsr_rand_o;
lfsr16 lfsr16 (
   .clk_i(clk_25_175_i),
   .rst_ni(lfsr_rst_ni & rst_ni),
   .next_i(lfsr_next),
   .rand_o(lfsr_rand_o)
);

logic title_on;
logic [9:0] title_pos_x, title_pos_y;
title title (
   .pixel_x_i(title_pos_x),
   .pixel_y_i(title_pos_y),
   .pixel_o(title_on)
);

logic edge_data;
logic edge_edge;
edge_detector edge_detector (
   .clk_i(clk_25_175_i),
   .data_i(edge_data),
   .edge_o(edge_edge)
);

logic dino_rst_ni;
logic dino_hit;
logic dino_next_frame;
logic dino_pixel;
logic [9:0] dino_pos_x, dino_pos_y;
dino dino (
   .clk_i(clk_25_175_i),
   .rst_ni(dino_rst_ni),
   .hit_i(dino_hit),
   .up_i,
   .down_i,
   .next_frame_i(dino_next_frame),
   .pixel_x_i(dino_pos_x),
   .pixel_y_i(dino_pos_y),
   .pixel_o(dino_pixel)
);

logic cact_rst_ni;
logic cact_next_frame;
logic cact_spawn;
logic cact_pixel;
logic [1:0] cact_rand;
logic [9:0] cact_pos_x, cact_pos_y;
cactus cactus1 (
   .clk_i(clk_25_175_i),
   .rst_ni(cact_rst_ni & !start_i),
   .next_frame_i(cact_next_frame),
   .spawn_i(cact_spawn),
   .rand_i(cact_rand),
   .pixel_x_i(cact_pos_x),
   .pixel_y_i(cact_pos_y),
   .pixel_o(cact_pixel)
);

logic bird1_rst_ni;
logic bird1_next_frame;
logic bird1_spawn;
logic bird1_pixel;
logic [1:0] bird1_rand;
logic [9:0] bird1_pos_x, bird1_pos_y;
bird bird1 (
   .clk_i(clk_25_175_i),
   .rst_ni(bird1_rst_ni & !start_i),
   .next_frame_i(bird1_next_frame),
   .spawn_i(bird1_spawn),
   .rand_i(bird1_rand),
   .pixel_x_i(bird1_pos_x),
   .pixel_y_i(bird1_pos_y),
   .pixel_o(bird1_pixel)
);

logic bird2_rst_ni;
logic bird2_next_frame;
logic bird2_spawn;
logic bird2_pixel;
logic [1:0] bird2_rand;
logic [9:0] bird2_pos_x, bird2_pos_y;
bird bird2 (
   .clk_i(clk_25_175_i),
   .rst_ni(bird2_rst_ni & !start_i),
   .next_frame_i(bird2_next_frame),
   .spawn_i(bird2_spawn),
   .rand_i(bird2_rand),
   .pixel_x_i(bird2_pos_x),
   .pixel_y_i(bird2_pos_y),
   .pixel_o(bird2_pixel)
);

logic score_en;
logic score_rst_ni;
logic [3:0] score_digit0, score_digit1, score_digit2, score_digit3;
score_counter score_counter (
   .clk_i(clk_25_175_i),
   .rst_ni(score_rst_ni & !start_i),
   .en_i(score_en),
   .digit0_o(score_digit0),
   .digit1_o(score_digit1),
   .digit2_o(score_digit2),
   .digit3_o(score_digit3)
);

state_t state_d, state_q;
always_ff @(posedge clk_25_175_i) begin
   if (!rst_ni) begin
       state_q <= TITLE_SCREEN;
   end else begin
       state_q <= state_d;
   end
end

logic [3:0] vga_red_d, vga_red_q;
logic [3:0] vga_blue_d, vga_blue_q;
logic [3:0] vga_green_d, vga_green_q;
always_ff @(posedge clk_25_175_i) begin
   if (!rst_ni) begin
       vga_red_q <= 4'b1111;
       vga_blue_q <= 4'b1111;
       vga_green_q <= 4'b1111;
   end else begin
       vga_red_q <= vga_red_d;
       vga_blue_q <= vga_blue_d;
       vga_green_q <= vga_green_d;
   end
end

always_comb begin

   cact_pos_x = position_x;
   cact_pos_y = position_y;
   bird2_pos_x = position_x;
   bird2_pos_y = position_y;
   bird1_pos_x = position_x;
   bird1_pos_y = position_y;
   dino_pos_x = position_x;
   dino_pos_y = position_y;
   title_pos_x = position_x;
   title_pos_y = position_y;
   dino_hit = 1'b0;

   lfsr_rst_ni = 1'b1;
   cact_rst_ni = 1'b1;
   bird2_rst_ni = 1'b1;
   bird1_rst_ni = 1'b1;
   dino_rst_ni = 1'b1;
   score_rst_ni = 1'b1;
   vga_rst_ni = rst_ni;
   seg_rst_ni = 1'b1;

   digit0_en_o = 1'b1;
   digit1_en_o = 1'b1;
   digit2_en_o = 1'b1;
   digit3_en_o = 1'b1;

   digit0_o = score_digit0;
   digit1_o = score_digit1;
   digit2_o = score_digit2;
   digit3_o = score_digit3;

   vga_red_o = vga_red_q;
   vga_blue_o = vga_blue_q;
   vga_green_o = vga_green_q;
   vga_hsync_o = vga_hsync;
   vga_vsync_o = vga_vsync;

   cact_spawn = 1'b0;
   bird2_spawn = 1'b0;
   bird1_spawn = 1'b0;

   cact_next_frame = 1'b0;
   bird2_next_frame = 1'b0;
   bird1_next_frame = 1'b0;
   dino_next_frame = 1'b0;

   unique case (state_q)
       TITLE_SCREEN: begin
           score_rst_ni = 1'b0;
           edge_data = 1'b0;
           dino_next_frame = 1'b0;
           lfsr_next = 1'b0;
           if (vga_visible == 1'b1) begin
               if (title_on == 1'b1) begin
                   vga_red_d = 4'b1111;
                   vga_blue_d = 4'b1111;
                   vga_green_d = 4'b0000;
               end else if (dino_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b1111;
               end else if (position_y >= 400) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0111;
               end else begin
                   vga_red_d = 4'b1111;
                   vga_blue_d = 4'b1111;
                   vga_green_d = 4'b1111;
               end
           end else begin
               vga_red_d = 4'b0000;
               vga_blue_d = 4'b0011;
               vga_green_d = 4'b0000;
           end
           if (vga_vsync == 1'b0) begin
               edge_data = 1'b1;
           end
           if (edge_edge == 1'b1) begin
               dino_next_frame = 1'b1;
           end
           if (start_i == 1'b1) begin
               lfsr_next = 1'b1;
               dino_next_frame = 1'b0;
               state_d = RUNNING;
           end else begin
               state_d = state_q;
           end

       end
       RUNNING: begin
           score_rst_ni = 1'b1;
           edge_data = 1'b0;
           cact_spawn = 1'b0;
           bird2_spawn = 1'b0;
           bird1_spawn = 1'b0;

           if (lfsr_rand_o[5:1] == 5'b10110) begin
               cact_spawn = 1'b1;
               cact_rand = lfsr_rand_o[15:14];
           end
           if (lfsr_rand_o[13:9] == 5'b01110) begin
               bird2_spawn = 1'b1;
               bird2_rand = lfsr_rand_o[2:1];
           end
           if (lfsr_rand_o[15:10] == 6'b100101) begin
               bird1_spawn = 1'b1;
               bird1_rand = lfsr_rand_o[9:8];
           end

           if (vga_visible == 1'b1) begin
               if (dino_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b1111;
               end else if (cact_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0011;
                   vga_green_d = 4'b0100;
               end else if (bird2_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0000;
               end else if (bird1_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0000;
               end else if (position_y >= 400) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0111;
               end else begin
                   vga_red_d = 4'b1111;
                   vga_blue_d = 4'b1111;
                   vga_green_d = 4'b1111;
               end
           end else begin
               vga_red_d = 4'b0000;
               vga_blue_d = 4'b0011;
               vga_green_d = 4'b0000;
           end

           if (vga_vsync == 1'b0) begin
               edge_data = 1'b1;
           end
           if (edge_edge == 1'b1) begin
               cact_next_frame = 1'b1;
               bird2_next_frame = 1'b1;
               bird1_next_frame = 1'b1;
               dino_next_frame = 1'b1;
               score_en = 1'b1;
           end else begin
               cact_next_frame = 1'b0;
               bird2_next_frame = 1'b0;
               bird1_next_frame = 1'b0;
               dino_next_frame = 1'b0;
               score_en = 1'b0;
           end

           if (dino_pixel && (cact_pixel || bird2_pixel || bird1_pixel)) begin
               cact_next_frame = 1'b0;
               bird2_next_frame = 1'b0;
               bird1_next_frame = 1'b0;
               dino_next_frame = 1'b0;
               score_en = 1'b0;
               state_d = HIT;
           end else begin
               state_d = state_q;
           end

       end
       HIT: begin

           cact_next_frame = 1'b0;
           bird2_next_frame = 1'b0;
           bird1_next_frame = 1'b0;
           dino_next_frame = 1'b0;
           dino_hit = 1'b1;
           score_en = 1'b0;

           if (vga_visible == 1'b1) begin
               if (dino_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b1111;
               end else if (cact_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0011;
                   vga_green_d = 4'b1000;
               end else if (bird2_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0000;
               end else if (bird1_pixel == 1'b1) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0000;
               end else if (position_y >= 400) begin
                   vga_red_d = 4'b0000;
                   vga_blue_d = 4'b0000;
                   vga_green_d = 4'b0111;
               end else begin
                   vga_red_d = 4'b1111;
                   vga_blue_d = 4'b1111;
                   vga_green_d = 4'b1111;
               end
           end else begin
               vga_red_d = 4'b0000;
               vga_blue_d = 4'b0011;
               vga_green_d = 4'b0000;
           end

           if (start_i == 1'b1) begin
               cact_rst_ni = 1'b0;
               bird2_rst_ni = 1'b0;
               bird1_rst_ni = 1'b0;
               dino_rst_ni = 1'b0;
               score_rst_ni = 1'b0;
               state_d = RUNNING;
           end else begin
               state_d = state_q;
           end

       end
       default: begin
           state_d = TITLE_SCREEN;
       end
   endcase
end

endmodule