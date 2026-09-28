module SonarTop(
	// Switches and LEDs .......................................................
	input		[9:0]ipSwitch,
	output	[9:0]opLED,
	
	// ADXL345 SPI communication controller ....................................
	input ipClk_50M,
	input ipnReset,
	
	output opADXL345_nCS,
	output opADXL345_SClk,
	output opADXL345_SDI,
	input	 ipADXL345_SDO,

	// SDRAM ...................................................................
	output       opClk_SDRAM,
	output       opSDRAM_CKE,
	output       opSDRAM_nCS,
	output       opSDRAM_nRAS,
	output       opSDRAM_nCAS,
	output       opSDRAM_nWE,
	output [12:0]opSDRAM_A,
	output [ 1:0]opSDRAM_BA,
	output [ 1:0]opSDRAM_DQM,
	inout  [15:0]bpSDRAM_DQ,

	output reg [15:0]opReadData,
	
	// PWM Audio output
	output		opPWM
);



// Sources and Probes .........................................................
//wire [9:0]Source;
//SourcesAndProbes SourcesAndProbes_inst(
//	.source(Source),
//	.probe(Switch)
//);

//assign LED = Switch ^ Source;  // XOR between Switch state and Source

// ADXL345 wires and instance .................................................
wire [15:0]G_Sensor_X;
wire [15:0]G_Sensor_Y;
wire [15:0]G_Sensor_Z;

ADXL345 #(
	.Clock_kHz(50_000),
	.Baud_kHz ( 5_000)
) G_Sensor_inst (
	.ipClk	(ipClk_50M),
	.ipReset (~ipnReset),

  // 2's Compliment Output
  .opX(G_Sensor_X),
  .opY(G_Sensor_Y),
  .opZ(G_Sensor_Z),

  // Physical device interface
  .opnCS (opADXL345_nCS ),
  .opSClk(opADXL345_SClk),
  .opSDI (opADXL345_SDI ),
  .ipSDO (ipADXL345_SDO )
);

//-----------------------------------------------------------------------------

wire [1:0]G_Sensor_Select;

altsource_probe #(
  .instance_id            ("GSNS"),
  .sld_auto_instance_index("YES"),
  .probe_width            (16),
  .source_width           ( 2)
)SourcesAndProbes_G_Sensor(
  .source_ena(1'b1),
  .source    (G_Sensor_Select),
  .probe     (G_Sensor_Select == 0 ? G_Sensor_X :
              G_Sensor_Select == 1 ? G_Sensor_Y :
              G_Sensor_Select == 2 ? G_Sensor_Z : 0)
);
// SDRAM Clocks, 100MHz with 0 and -90deg phase -------------------------------

wire Clk_100M;
wire PLL_Locked;

SDRAM_PLL SDRAM_PLL_Inst(
  .inclk0(ipClk_50M),
  .c0    (Clk_100M),
  .c1    (opClk_SDRAM),
  .locked(PLL_Locked)
);
//------------------------------------------------------------------------------

reg Reset;
always @(posedge Clk_100M) Reset <= ~PLL_Locked || ~ipnReset;

// SDRAM on Avalon Bridge -----------------------------------------------------

wire [24:0]Avalon_Address;
wire       Avalon_WaitRequest;

wire [15:0]Avalon_WriteData;
wire       Avalon_Write;

wire       Avalon_Read;
wire [15:0]Avalon_ReadData;
wire       Avalon_ReadDataValid;

IS42S16320D SDRAM_Inst(
  .ipClk          (Clk_100M),
  .ipReset        (Reset   ),

  .ipAddress      (Avalon_Address      ),
  .ipByteEnable   (2'b11               ),
  .opWaitRequest  (Avalon_WaitRequest  ),

  .ipWriteData    (Avalon_WriteData    ),
  .ipWrite        (Avalon_Write        ),

  .ipRead         (Avalon_Read         ),
  .opReadData     (Avalon_ReadData     ),
  .opReadDataValid(Avalon_ReadDataValid),

  .opCKE          (opSDRAM_CKE ),
  .opnCS          (opSDRAM_nCS ),
  .opnRAS         (opSDRAM_nRAS),
  .opnCAS         (opSDRAM_nCAS),
  .opnWE          (opSDRAM_nWE ),
  .opA            (opSDRAM_A   ),
  .opBA           (opSDRAM_BA  ),
  .opDQM          (opSDRAM_DQM ),
  .bpDQ           (bpSDRAM_DQ  )
);
//------------------------------------------------------------------------------

typedef enum { Write, Read, Done } STATE;
STATE State;

always @(posedge Clk_100M) begin
  if(Reset) begin
    Avalon_Address   <= 0;
    Avalon_WriteData <= 0;
    Avalon_Write     <= 0;
    Avalon_Read      <= 0;

    State <= Write;

  end else if(~Avalon_WaitRequest) begin
    case(State)
      Write: begin
        if(Avalon_Address == 25'h1FF_FFFE) State <= Read;
        if(Avalon_Write) begin
          Avalon_Address   <= Avalon_Address + 1;
          Avalon_WriteData <= Avalon_Address[15:0] + 1;
        end
        Avalon_Write <= 1;
      end

      Read: begin
        Avalon_Write <= 0;
        if(Avalon_Address == 25'h1FF_FFFE) State <= Done;
        Avalon_Address <= Avalon_Address + 1;
        Avalon_Read <= 1;
      end

      Done: begin
        Avalon_Read  <= 0;
        Avalon_Write <= 0;
      end

      default:;
    endcase
  end

  if(Avalon_ReadDataValid) opReadData <= Avalon_ReadData;
end
//------------------------------------------------------------------------------

wire [29:0]Master_Address;
wire [ 3:0]Master_ByteEnable;
wire       Master_WaitRequest;
wire [31:0]Master_WriteData;
wire       Master_Write = 0;
wire       Master_Read  = 0;
wire [31:0]Master_ReadData;
wire       Master_ReadDataValid;

wire [ 7:0]Registers_Address;
wire [ 3:0]Registers_ByteEnable;
wire       Registers_WaitRequest;
wire [31:0]Registers_WriteData;
wire       Registers_Write;
wire       Registers_Read;
wire [31:0]Registers_ReadData;
wire       Registers_ReadDataValid;

wire [24:0]SDRAM_Address;
wire [ 1:0]SDRAM_ByteEnable;
wire       SDRAM_WaitRequest;
wire [15:0]SDRAM_WriteData;
wire       SDRAM_Write;
wire       SDRAM_Read;
wire [15:0]SDRAM_ReadData;
wire       SDRAM_ReadDataValid;

Platform_Avalon QSys_Inst (
  .clk_clk                (Clk_100M               ), // In
  .reset_reset_n          (~Reset                 ), // In

  .master_address         (Master_Address         ), // In
  .master_byteenable      (Master_ByteEnable      ), // In
  .master_burstcount      (1                      ), // In
  .master_waitrequest     (Master_WaitRequest     ), // Out
  .master_writedata       (Master_WriteData       ), // In
  .master_write           (Master_Write           ), // In
  .master_read            (Master_Read            ), // In
  .master_readdata        (Master_ReadData        ), // Out
  .master_readdatavalid   (Master_ReadDataValid   ), // Out
  .master_debugaccess     (0                      ), // In

  .registers_address      (Registers_Address      ), // Out
  .registers_byteenable   (Registers_ByteEnable   ), // Out
  .registers_burstcount   (                       ), // Out
  .registers_waitrequest  (Registers_WaitRequest  ), // In
  .registers_writedata    (Registers_WriteData    ), // Out
  .registers_write        (Registers_Write        ), // Out
  .registers_read         (Registers_Read         ), // Out
  .registers_readdata     (Registers_ReadData     ), // In
  .registers_readdatavalid(Registers_ReadDataValid), // In
  .registers_debugaccess  (                       ), // Out

  .sdram_address          (SDRAM_Address          ), // Out
  .sdram_byteenable       (SDRAM_ByteEnable       ), // Out
  .sdram_burstcount       (                       ), // Out
  .sdram_waitrequest      (SDRAM_WaitRequest      ), // In
  .sdram_writedata        (SDRAM_WriteData        ), // Out
  .sdram_write            (SDRAM_Write            ), // Out
  .sdram_read             (SDRAM_Read             ), // Out
  .sdram_readdata         (SDRAM_ReadData         ), // In
  .sdram_readdatavalid    (SDRAM_ReadDataValid    ), // In
  .sdram_debugaccess      (                       )  // Out
);

// Assign some registers ------------------------------------------------------

assign Registers_WaitRequest = 0;

always @(posedge Clk_100M) begin
  if(Reset) begin
    opLED <= 0;

  end else if(Registers_Write) begin
    case(Registers_Address)
      8'h01: begin
        if(Registers_ByteEnable[0]) opLED[7:0] <= Registers_WriteData[7:0];
        if(Registers_ByteEnable[1]) opLED[9:8] <= Registers_WriteData[9:8];
      end
    endcase
  end

  case(Registers_Address)
    8'h00: Registers_ReadData <= ipSwitch;
    8'h01: Registers_ReadData <= opLED;

    8'h10: Registers_ReadData <= { {16{G_Sensor_X[15]}}, G_Sensor_X };
    8'h11: Registers_ReadData <= { {16{G_Sensor_Y[15]}}, G_Sensor_Y };
    8'h12: Registers_ReadData <= { {16{G_Sensor_Z[15]}}, G_Sensor_Z };
  endcase
  Registers_ReadDataValid <= Registers_Read;
end

// PWM Module .................................................................
PWM_module PWM_inst(
	.ipClk(Clk_100M),	// Assume this is 100MHz clock
	.ipReset(~ipnReset),	// Synchronous reset (active high)
	.ipMute(ipSwitch[8]),
	.PWM_amp(ipSwitch[7:0]),
	.opPWM()
	);


// If the RAM loading and reading does not work, try a tone





endmodule