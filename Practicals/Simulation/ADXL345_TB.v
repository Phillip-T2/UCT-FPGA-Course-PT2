`timescale 1ns/1ps
module ADXL345_TB;
//------------------------------------------------------------------------------

// Clock
reg ipClk = 0;
always #10 ipClk <= ~ipClk;
//------------------------------------------------------------------------------

// Reset
reg ipReset = 1;
initial #50 ipReset <= 0;
//------------------------------------------------------------------------------

// DUT
wire [15:0]opX;
wire [15:0]opY;
wire [15:0]opZ;
wire opnCS, opSClk, opSDI;
reg  ipSDO = 0;

ADXL345 #(
  .Clock_kHz(50_000),
  .Baud_kHz ( 5_000)
)Accelerator(
  .ipClk  (ipClk),
  .ipReset(ipReset),
  .opX    (opX),
  .opY    (opY),
  .opZ    (opZ),
  .opnCS  (opnCS),
  .opSClk (opSClk),
  .opSDI  (opSDI),
  .ipSDO  (ipSDO)
);
//------------------------------------------------------------------------------

reg [ 7:0]DataIn;
reg [15:0]DataOut = 0;

integer n;
always begin
  @(negedge opnCS);

  // Instruction word
  for(n = 7; n >= 0; n--) begin
    @(negedge opSClk);
    DataIn[n] <= opSDI;
  end

  // The first data word
  for(n = 7; n >= 0; n--) begin
    @(negedge opSClk); #40; // Output delay
    ipSDO <= DataOut[n];
  end

  // The optional second data word
  if(DataIn[6]) begin // More bits
    for(n = 15; n >= 8; n--) begin
      @(negedge opSClk); #40; // Output delay
      ipSDO <= DataOut[n];
    end
  end

  @(posedge opnCS);

  DataOut <= DataOut + 1;
end

endmodule
//------------------------------------------------------------------------------