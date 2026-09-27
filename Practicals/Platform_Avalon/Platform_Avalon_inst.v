	Platform_Avalon u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //       clk.clk
		.master_waitrequest      (<connected-to-master_waitrequest>),      //    master.waitrequest
		.master_readdata         (<connected-to-master_readdata>),         //          .readdata
		.master_readdatavalid    (<connected-to-master_readdatavalid>),    //          .readdatavalid
		.master_burstcount       (<connected-to-master_burstcount>),       //          .burstcount
		.master_writedata        (<connected-to-master_writedata>),        //          .writedata
		.master_address          (<connected-to-master_address>),          //          .address
		.master_write            (<connected-to-master_write>),            //          .write
		.master_read             (<connected-to-master_read>),             //          .read
		.master_byteenable       (<connected-to-master_byteenable>),       //          .byteenable
		.master_debugaccess      (<connected-to-master_debugaccess>),      //          .debugaccess
		.registers_waitrequest   (<connected-to-registers_waitrequest>),   // registers.waitrequest
		.registers_readdata      (<connected-to-registers_readdata>),      //          .readdata
		.registers_readdatavalid (<connected-to-registers_readdatavalid>), //          .readdatavalid
		.registers_burstcount    (<connected-to-registers_burstcount>),    //          .burstcount
		.registers_writedata     (<connected-to-registers_writedata>),     //          .writedata
		.registers_address       (<connected-to-registers_address>),       //          .address
		.registers_write         (<connected-to-registers_write>),         //          .write
		.registers_read          (<connected-to-registers_read>),          //          .read
		.registers_byteenable    (<connected-to-registers_byteenable>),    //          .byteenable
		.registers_debugaccess   (<connected-to-registers_debugaccess>),   //          .debugaccess
		.reset_reset_n           (<connected-to-reset_reset_n>),           //     reset.reset_n
		.sdram_waitrequest       (<connected-to-sdram_waitrequest>),       //     sdram.waitrequest
		.sdram_readdata          (<connected-to-sdram_readdata>),          //          .readdata
		.sdram_readdatavalid     (<connected-to-sdram_readdatavalid>),     //          .readdatavalid
		.sdram_burstcount        (<connected-to-sdram_burstcount>),        //          .burstcount
		.sdram_writedata         (<connected-to-sdram_writedata>),         //          .writedata
		.sdram_address           (<connected-to-sdram_address>),           //          .address
		.sdram_write             (<connected-to-sdram_write>),             //          .write
		.sdram_read              (<connected-to-sdram_read>),              //          .read
		.sdram_byteenable        (<connected-to-sdram_byteenable>),        //          .byteenable
		.sdram_debugaccess       (<connected-to-sdram_debugaccess>)        //          .debugaccess
	);

