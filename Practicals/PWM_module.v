module PWM_module (
	// Define stuff ............................................................	
	input			ipClk,	// Assume this is 100MHz clock
	input			ipReset,	// Synchronous reset (active high)
	input			ipMute,
	input	[7:0]	PWM_amp,
	output 		opPWM
);

	// Do stuff ...................................................................
	// This module needs to output a 8-bit amplitude level by doing PWM

	reg [ 7:0]Count;

	// Sequential block: Decrements on every clock cycle
	always @(posedge ipClk) begin
		// Count from high to low
		if (ipReset) begin
			Count <= 8'hFF;
		end else begin
			Count--;
			
			if (ipMute) begin
				opPWM <= 1'b0;   // Mute forces output low
			end else begin
				opPWM <= (Count > PWM_amp);    
			end	
		end
	end

endmodule