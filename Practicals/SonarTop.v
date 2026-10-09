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
	output reg		  	opPWM,
	output reg			opPA_en,
	// ToDo: Drop the "reg"?
	
	// ADC
	output [ 2:1]opADC_nCS,			// Chip Select (two ADC on Sonar PCB)
	inout  [ 3:0]bpADC_CR_DB,		// Configuration Register (CR0-CR3),
											// with pin sharing DB0/CR2 DB1/CR3; 
	output		 opADC_nWR,			// Write
	output		 opADC_nRD,			// Read
	output		 opADC_CONVST,		// Convert Start
	input  [ 2:1]ipADC_nEOC,		// End of Conversion
	input  [13:2]ipADC_DB			// Data Bus; not including DB1/CR3 and DB0/CR2
);
//.............................................................................


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

//wire [1:0]G_Sensor_Select;
//
//altsource_probe #(
//  .instance_id            ("GSNS"),
//  .sld_auto_instance_index("YES"),
//  .probe_width            (16),
//  .source_width           ( 2)
//)SourcesAndProbes_G_Sensor(
//  .source_ena(1'b1),
//  .source    (G_Sensor_Select),
//  .probe     (G_Sensor_Select == 0 ? G_Sensor_X :
//              G_Sensor_Select == 1 ? G_Sensor_Y :
//              G_Sensor_Select == 2 ? G_Sensor_Z : 0)
//);

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

// SDRAM on Avalon Bridge connect and intialise -------------------------------

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

// SDRAM state machine --------------------------------------------------------
// Read when ADC samples are ready, write with JTAG request

// Internal counters and registers
reg [3:0]  sample_idx;
reg [24:0] current_addr; // Persistent address tracker across ADC blocks

typedef enum { IDLE_WAIT_ADC, Write_Block, Read_All, Done } STATE;
STATE State;

always @(posedge Clk_100M) begin
  if(Reset) begin
    current_addr     <= 0;
    Avalon_Address   <= 0;
    Avalon_WriteData <= 0;
    Avalon_Write     <= 0;
    Avalon_Read      <= 0;
    sample_idx       <= 0;

    State <= IDLE_WAIT_ADC;

  end else begin
    case(State)
      
      // 1. Wait for individual 16-sample ADC blocks until SDRAM is full
      IDLE_WAIT_ADC: begin
        Avalon_Write <= 1'b0;
        
        if(ADC_Valid) begin
          sample_idx     <= 4'd0;
          Avalon_Address <= current_addr; // Resume writing from where we left off
          State          <= Write_Block;
        end
      end

      // 2. Burst-write the 16 samples into the current segment of SDRAM
      Write_Block: begin
        if(~Avalon_WaitRequest) begin
          Avalon_WriteData <= {2'b00, ADC_Samples[sample_idx]};
          Avalon_Write     <= 1'b1;

          if(Avalon_Write) begin
            // If we have written all 16 samples in this block
            if(sample_idx == 4'd15) begin
              Avalon_Write <= 1'b0;
              
              // CRITICAL: Check if this was the final block filling the SDRAM
              if(Avalon_Address == 25'h1FF_FFFE) begin
                Avalon_Address <= 25'd0; // Reset address pointer to 0 for the upcoming Read Phase
                State          <= Read_All; 
              end else begin
                current_addr   <= Avalon_Address + 1'b1; // Save progress for next block
                State          <= IDLE_WAIT_ADC;
              end
            end else begin
              Avalon_Address <= Avalon_Address + 1'b1;
              sample_idx     <= sample_idx + 1'b1;
            end
          end
        end
      end

      // 3. SDRAM is completely full! Now continuously read it all back out for JTAG
      Read_All: begin
        if(~Avalon_WaitRequest) begin
          Avalon_Read <= 1'b1;
          
          if(Avalon_Read) begin
            if(Avalon_Address == 25'h1FF_FFFE) begin
              State       <= Done;
              Avalon_Read <= 1'b0;
            end else begin
              Avalon_Address <= Avalon_Address + 1'b1;
            end
          end
        end
      end

      // 4. Lock state to protect data from being overwritten until a hardware Reset
      Done: begin
        Avalon_Read  <= 1'b0;
        Avalon_Write <= 1'b1; // Explicitly ensure writing is locked out
      end

      default: State <= IDLE_WAIT_ADC;
    endcase
  end

  // Capture read data whenever the Avalon bus says it's ready
  if(Avalon_ReadDataValid) opReadData <= Avalon_ReadData;
end

//------------------------------------------------------------------------------



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

//always @(posedge Clk_100M) begin
//  if(Reset) begin
//    opLED <= 0;
//
//  end else if(Registers_Write) begin
//    case(Registers_Address)
//      8'h01: begin
//        if(Registers_ByteEnable[0]) opLED[7:0] <= Registers_WriteData[7:0];
//        if(Registers_ByteEnable[1]) opLED[9:8] <= Registers_WriteData[9:8];
//      end
//    endcase
//  end
//
//  case(Registers_Address)
//    8'h00: Registers_ReadData <= ipSwitch;
//    8'h01: Registers_ReadData <= opLED;
//
//    8'h10: Registers_ReadData <= { {16{G_Sensor_X[15]}}, G_Sensor_X };
//    8'h11: Registers_ReadData <= { {16{G_Sensor_Y[15]}}, G_Sensor_Y };
//    8'h12: Registers_ReadData <= { {16{G_Sensor_Z[15]}}, G_Sensor_Z };
//  endcase
//  Registers_ReadDataValid <= Registers_Read;
//end

	// Attempte to generate a tone

//	parameter CLK_DIV_TARGET = 191109;
//    
//   reg [17:0] clk_divider;
//   reg        tone_state;
//
//   always @(posedge Clk_100M or negedge ipnReset) begin
//       if (!ipnReset) begin
//           clk_divider <= 0;
//           tone_state  <= 1'b0;
//       end else if (clk_divider >= (CLK_DIV_TARGET - 1)) begin
//           clk_divider <= 0;
//           tone_state  <= ~tone_state; // Toggle at 523.26 Hz
//       end else begin
//           clk_divider <= clk_divider + 1'b1;
//       end
//   end
	// The code above did work, but sounded horriable
	
	
	

   // --- 2. Duty Cycle Selection ---
   wire [7:0] duty_cycle;
   
	assign opPA_en = ipSwitch[0];
   
	wire   chirp_done;    // Flags when the 0.5s sweep finishes

    // Internal bus to capture the full 16-bit unsigned sine wave
//    wire [15:0] full_sine_wave;

    // Connect the 8 Most Significant Bits (MSBs) to the duty_cycle output
    // For unsigned values, this preserves the overall wave shape with lower resolution (0 to 255)
//    assign duty_cycle = full_sine_wave[15:8];
	 
	 // 1. Sine ROM (Look-Up Table)
    reg [15:0] sine_rom [0:1023]; 
    initial begin
        $readmemh("sine_table.mem", sine_rom);
    end

    // 2. Sample Rate Clock Enable Divider (100MHz / 2048 = 48.828125 kHz)
    reg [10:0] sample_counter; // 11-bit counter to count up to 2048
    wire       sample_en = (sample_counter == 11'd2047);

    always @(posedge Clk_100M) begin
        if (~ipnReset) begin
            sample_counter <= 11'd0;
        end else begin
            sample_counter <= sample_counter + 1'b1; // Automatically rolls over at 2048
        end
    end

    // 3. Phase Accumulator updating ONLY on the sample enable strobe
    reg [23:0] phase_accumulator;
    
    // Constant value for a 260Hz tone at a sample rate of 48.828125 kHz
    localparam [23:0] FIXED_FCW = 24'd89335; 

    always @(posedge Clk_100M) begin
        if (~ipnReset) begin
            phase_accumulator <= 24'b0;
        end else if (sample_en) begin
            phase_accumulator <= phase_accumulator + FIXED_FCW;
        end
    end

    // 4. Index the ROM and update duty_cycle synchronously with the sample rate
    wire [9:0]  rom_index      = phase_accumulator[23:14];
    wire [15:0] full_sine_wave = sine_rom[rom_index];
    wire [7:0]  raw_unsigned   = full_sine_wave[15:8];

    always @(posedge Clk_100M) begin
        if (~ipnReset) begin
            duty_cycle <= 8'h80; // Silent midpoint on reset
        end else if (sample_en) begin
            duty_cycle <= raw_unsigned; // Output updates exactly at 48.828125 kSps
        end
    end
	 
	 // ------------------------------------------------------------------------

    // Instantiate the chirp generator
//    chirp_generator u_chirp_gen (
//        .clk             (Clk_100M),
//        .reset           (~ipnReset),
//        // Loopback: when the sweep finishes, it immediately triggers a new one.
//        // We also use sys_reset to kick off the very first sweep.
//        .start_sweep     (chirp_done || ~ipnReset), 
//        
//        // Configured for 1kHz to 5kHz over 1 seconds
//        .freq_start_hz (32'd260),   // Start at 260 Hz
//        .freq_stop_hz  (32'd260),   // Stop at 260 Hz (holds frequency constant)
//        .freq_step_hz  (32'd0),     // No sweep step
//        //.step_interval   (16'd25_000), // 25,000 clock cycles per 1 kHz step
//		  .step_interval (16'd0),     // No interval step
//        
//        .sine_out        (full_sine_wave),
//        .sweep_done      (chirp_done)
//    );

	// Now assign the output of the chirp generator to the duty cycle of the PWM module
	
   // --- 3. Instantiate the PWM Generator ---
   PWM_module #(.Width(8)) PWM_inst (
       .ipClk(Clk_100M),
       .ipReset(~ipnReset),
       .ipDuty_Cycle(duty_cycle),
       .opPWM(opPWM) // Connected directly to top level output port
   );


// PWM Module .................................................................
//PWM_module PWM_inst(
//	.ipClk(Clk_100M),	// Assume this is 100MHz clock
//	.ipReset(~ipnReset),	// Synchronous reset (active high)
//	.PWM_amp(ipSwitch[8:1]),
//	.opPWM(opLED[9])
//	);


	assign opLED = ipSwitch;  // XOR between Switch state and Source



	// ADC Module .............................................................. 
		
	wire [13:0]ADC_Samples[15:0];		// 14-bit sample for 16ch (2x8 Ch)
	wire       ADC_Valid;
	
	reg  [ 3:0]opADC_CR;		// Declare as a "reg" to use in "if-else" statment
									// inside an "always" block
	wire       enADC_CR;		// Utility wire to enable CR and disable DB
	
//	// Combinational "always" block for "if-else" logic
//	always @(*) begin
//		 if (enADC_CR) begin
//			  bpADC_CR_DB = opADC_CR; // enable driving of CR pins
//		 end else begin
//			  bpADC_CR_DB = 4'hZ;	// set to high impedance so that DB can be read
//		 end
//	end
	
	// Tri-state buffer
	assign bpADC_CR_DB = enADC_CR ? opADC_CR : 4'hZ;

	MAX11059 #(
	  .Clock_kHz       (100_000),
	  .SamplingRate_kHz(97.656_250)	// fs = 100kHz/1024 = 97.656_250 kSps
	)ADC_inst(
	  .ipClk    (Clk_100M ),
	  .ipReset  (Reset),

	  .opSamples(ADC_Samples),	// What lines/logic!?
	  .opValid  (ADC_Valid  ),	// What lines/logic!?

	  .opnCS    (opADC_nCS	 ),	
	  .opCR     (opADC_CR 	 ),
	  .enCR     (enADC_CR  	 ),
	  .opnWR    (opADC_nWR 	 ),
	  .opnRD    (opADC_nRD 	 ),
	  .opCONVST (opADC_CONVST),
	  .ipnEOC   (ipADC_nEOC	 ),
	  .ipDB     ({ ipADC_DB, bpADC_CR_DB[3:2] })  // DB15 to DB2, DB1 to DB0
	);		

	// Now start to sample some values -----------------------------------------
	

	
	
	
//------------------------------------------------------------------------------

// If the RAM loading and reading does not work, try a tone





endmodule