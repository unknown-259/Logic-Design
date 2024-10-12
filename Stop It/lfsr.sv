module lfsr (
  input  logic       clk_i,
  input  logic       rst_ni,
  input  logic       next_i,
  output logic [4:0] rand_o
);

// TODO
always_comb begin
   rand_d[7] = rand_q[6];
   rand_d[6] = rand_q[5];
   rand_d[5] = rand_q[4];
   rand_d[4] = rand_q[3];
   rand_d[3] = rand_q[2];
   rand_d[2] = rand_q[1];
   rand_d[1] = rand_q[0];
   rand_d[0] = rand_q[0] ^ rand_q[5] ^ rand_q[6] ^ rand_q[7];
end

logic [7:0] rand_d, rand_q;
always_ff @(posedge clk_i) begin
   if (!rst_ni) begin
       rand_q <= 8'b00000001;
   end else if (next_i) begin
       rand_q <= rand_d;
   end
end

assign rand_o = rand_q[4:0];

endmodule