module PWM_module #(
    parameter int Width = 8  // Resolution (8-bit default gives 0 to 255 steps)
)(
	// Define stuff ............................................................
	input					ipClk,	// Assume this is 100MHz clock
	input					ipReset,	// Synchronous reset (active high)
	input	[Width-1:0]	ipDuty_Cycle,	//
	output reg 			opPWM
);

	// Do stuff ...................................................................
	// This module needs to output a 8-bit amplitude level by doing PWM

	reg [Width-1:0]Counter_reg;

   always @(posedge ipClk) begin
        if (ipReset) begin
            Counter_reg <= '0;
        end else begin
            Counter_reg <= Counter_reg + 1'b1;
        end
    end

    // Output assignment: High when counter is strictly less than the duty cycle
    always @(posedge ipClk) begin
        if (ipReset) begin
            opPWM <= 1'b0;
        end else begin
            opPWM <= (Counter_reg < ipDuty_Cycle);
        end
    end

endmodule