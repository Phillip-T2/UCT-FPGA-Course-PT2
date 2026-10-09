module chirp_generator (
    input  wire        clk,
    input  wire        reset,
    input  wire        start_sweep,
    
    // Inputs specified directly in Hz
    input  wire [31:0] freq_start_hz,
    input  wire [31:0] freq_stop_hz,
    input  wire [31:0] freq_step_hz,
    input  wire [15:0] step_interval,
    
    output wire [15:0] sine_out,
    output reg         sweep_done
);

    // Precise Hz-to-FCW conversion for a 100 MHz clock
    wire [23:0] fcw_start = (freq_start_hz * 32'd2097152) / 32'd12500000;
    wire [23:0] fcw_stop  = (freq_stop_hz  * 32'd2097152) / 32'd12500000;
    wire [23:0] fcw_step  = (freq_step_hz  * 32'd2097152) / 32'd12500000;

    reg [15:0] sine_rom [0:1023]; 
    initial begin
        $readmemh("sine_table.mem", sine_rom);
    end

    reg [23:0] current_fcw;
    reg [15:0] interval_counter;
    reg [23:0] phase_accumulator;
    reg        sweeping;

    always @(posedge clk) begin
        if (reset) begin
            current_fcw      <= 24'b0;
            interval_counter <= 16'b0;
            sweep_done       <= 1'b0;
            sweeping         <= 1'b0;
        end else if (start_sweep) begin
            current_fcw      <= fcw_start;
            interval_counter <= 16'b0;
            sweep_done       <= 1'b0;
            sweeping         <= 1'b1;
        end else if (sweeping) begin
            if (current_fcw >= fcw_stop) begin
                current_fcw <= fcw_stop;
                sweep_done  <= 1'b1;
                sweeping    <= 1'b0;
            end else begin
                if (interval_counter >= step_interval) begin
                    interval_counter <= 16'b0;
                    current_fcw      <= current_fcw + fcw_step;
                end else begin
                    interval_counter <= interval_counter + 1'b1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            phase_accumulator <= 24'b0;
        end else begin
            phase_accumulator <= phase_accumulator + current_fcw;
        end
    end

    wire [9:0] rom_index = phase_accumulator[23:14];
    assign sine_out = sine_rom[rom_index];

endmodule
