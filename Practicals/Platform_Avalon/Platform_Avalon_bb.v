
module Platform_Avalon (
	clk_clk,
	master_waitrequest,
	master_readdata,
	master_readdatavalid,
	master_burstcount,
	master_writedata,
	master_address,
	master_write,
	master_read,
	master_byteenable,
	master_debugaccess,
	registers_waitrequest,
	registers_readdata,
	registers_readdatavalid,
	registers_burstcount,
	registers_writedata,
	registers_address,
	registers_write,
	registers_read,
	registers_byteenable,
	registers_debugaccess,
	reset_reset_n,
	sdram_waitrequest,
	sdram_readdata,
	sdram_readdatavalid,
	sdram_burstcount,
	sdram_writedata,
	sdram_address,
	sdram_write,
	sdram_read,
	sdram_byteenable,
	sdram_debugaccess);	

	input		clk_clk;
	output		master_waitrequest;
	output	[31:0]	master_readdata;
	output		master_readdatavalid;
	input	[0:0]	master_burstcount;
	input	[31:0]	master_writedata;
	input	[29:0]	master_address;
	input		master_write;
	input		master_read;
	input	[3:0]	master_byteenable;
	input		master_debugaccess;
	input		registers_waitrequest;
	input	[31:0]	registers_readdata;
	input		registers_readdatavalid;
	output	[0:0]	registers_burstcount;
	output	[31:0]	registers_writedata;
	output	[7:0]	registers_address;
	output		registers_write;
	output		registers_read;
	output	[3:0]	registers_byteenable;
	output		registers_debugaccess;
	input		reset_reset_n;
	input		sdram_waitrequest;
	input	[15:0]	sdram_readdata;
	input		sdram_readdatavalid;
	output	[0:0]	sdram_burstcount;
	output	[15:0]	sdram_writedata;
	output	[24:0]	sdram_address;
	output		sdram_write;
	output		sdram_read;
	output	[1:0]	sdram_byteenable;
	output		sdram_debugaccess;
endmodule
