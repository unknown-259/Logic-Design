module basys3(
  // TODO
  input  logic [15:0] sw,
  input  logic       btnU,
  input  logic       btnL,
  input  logic       btnR,
  input  logic       btnD,
  output logic [7:0] led
);

// TODO
alu alu_o(
  .a_i(sw [7:0]),
  .b_i(sw [15:8]),
  .operation_i({btnU, btnL, btnR, btnD}),
  .y_o(led)
);

endmodule