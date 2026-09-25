module SonarTop(
	// Switches and LEDs .......................................................
	input		[9:0]Switch,
	output	[9:0]LED,
	
	// ADXL345 SPI communication controller ....................................
	input ipClk_50M,
	input ipnReset,
	
	output opADXL345_nCS,
	output opADXL345_SClk,
	output opADXL345_SDI,
	input	 ipADXL345_SDO	
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
//-----------------------------------------------------------------------------

endmodule