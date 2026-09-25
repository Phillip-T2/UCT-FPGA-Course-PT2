module SonarTop(
	input		[9:0]Switch,
	output	[9:0]LED
);

// Sources and Probes .........................................................
wire [9:0]Source;
SourcesAndProbes SourcesAndProbes_inst(
	.source(Source),
	.probe(Switch)
);

assign LED = Switch ^ Source;  // XOR between Switch state and Source

endmodule