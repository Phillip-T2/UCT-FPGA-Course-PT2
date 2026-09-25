module ADXL345 #(
  parameter Clock_kHz,
  parameter Baud_kHz = 5000
)(
  input ipClk, ipReset,

  // 2's Compliment Output
  output reg [15:0]opX,
  output reg [15:0]opY,
  output reg [15:0]opZ,

  // Physical device interface
  output reg opnCS, opSClk, opSDI,
  input      ipSDO
);
//------------------------------------------------------------------------------

localparam ClockDiv = Clock_kHz / Baud_kHz / 2;
//------------------------------------------------------------------------------

reg      Reset;
reg [3:0]ClockCount  = 0;
wire     ClockEnable = (ClockCount == ClockDiv);
//------------------------------------------------------------------------------

reg [ 4:0]Count;
reg [15:0]Data; // (R/W, MB, Address, Byte) or (2 Bytes)
//------------------------------------------------------------------------------

typedef enum {
  Setup, Enable,
  ReadX, ReadY, ReadZ,
  Transaction
} STATE;

STATE State;
STATE RetState; // Used for function calls
//------------------------------------------------------------------------------

always @(posedge ipClk) begin
  Reset <= ipReset;

  if(ClockEnable) ClockCount <= 4'd1;
  else            ClockCount <= ClockCount + 1'b1;

  if(Reset) begin
    opnCS   <= 1'b1;
    opSClk  <= 1'b1;
    opSDI   <= 1'b1;
    State   <= Setup;
  //----------------------------------------------------------------------------

  end else if(ClockEnable) begin
    case(State)
      Setup: begin
        // SPI 4-wire; Full-res; Right-justify; 4g Range
        Data     <= {2'b00, 6'h31, 8'b0000_1001};
        Count    <= 5'd16;
        State    <= Transaction;
        RetState <= Enable;
      end
      //------------------------------------------------------------------------

      Enable: begin
        // Disable auto-sleep, and set to normal measure mode
        Data     <= {2'b00, 6'h2D, 8'b0010_1000};
        Count    <= 5'd16;
        State    <= Transaction;
        RetState <= ReadX;
      end
      //------------------------------------------------------------------------

      ReadX: begin
        opZ      <= {Data[7:0], Data[15:8]};
        Data     <= {2'b11, 6'h32, 8'd0};
        Count    <= 5'd24;
        State    <= Transaction;
        RetState <= ReadY;
      end
      //------------------------------------------------------------------------

      ReadY: begin
        opX      <= {Data[7:0], Data[15:8]};
        Data     <= {2'b11, 6'h34, 8'd0};
        Count    <= 5'd24;
        State    <= Transaction;
        RetState <= ReadZ;
      end
      //------------------------------------------------------------------------

      ReadZ: begin
        opY      <= {Data[7:0], Data[15:8]};
        Data     <= {2'b11, 6'h36, 8'd0};
        Count    <= 5'd24;
        State    <= Transaction;
        RetState <= ReadX;
      end
      //------------------------------------------------------------------------

      Transaction: begin
        if(opnCS) begin
          opnCS <= 1'b0;

        end else begin
          if(opSClk) begin
            if(Count == 0) begin
              opnCS <= 1'b1;
              State <= RetState;
            end else begin
              opSClk <= 1'b0;
            end
            Count <= Count - 1'b1;
            {opSDI, Data} <= {Data, ipSDO};

          end else begin
            opSClk <= 1'b1;
          end
        end
      end
      //------------------------------------------------------------------------

      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------