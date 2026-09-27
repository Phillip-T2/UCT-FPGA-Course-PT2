	component Platform_Avalon is
		port (
			clk_clk                 : in  std_logic                     := 'X';             -- clk
			master_waitrequest      : out std_logic;                                        -- waitrequest
			master_readdata         : out std_logic_vector(31 downto 0);                    -- readdata
			master_readdatavalid    : out std_logic;                                        -- readdatavalid
			master_burstcount       : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			master_writedata        : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			master_address          : in  std_logic_vector(29 downto 0) := (others => 'X'); -- address
			master_write            : in  std_logic                     := 'X';             -- write
			master_read             : in  std_logic                     := 'X';             -- read
			master_byteenable       : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			master_debugaccess      : in  std_logic                     := 'X';             -- debugaccess
			registers_waitrequest   : in  std_logic                     := 'X';             -- waitrequest
			registers_readdata      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			registers_readdatavalid : in  std_logic                     := 'X';             -- readdatavalid
			registers_burstcount    : out std_logic_vector(0 downto 0);                     -- burstcount
			registers_writedata     : out std_logic_vector(31 downto 0);                    -- writedata
			registers_address       : out std_logic_vector(7 downto 0);                     -- address
			registers_write         : out std_logic;                                        -- write
			registers_read          : out std_logic;                                        -- read
			registers_byteenable    : out std_logic_vector(3 downto 0);                     -- byteenable
			registers_debugaccess   : out std_logic;                                        -- debugaccess
			reset_reset_n           : in  std_logic                     := 'X';             -- reset_n
			sdram_waitrequest       : in  std_logic                     := 'X';             -- waitrequest
			sdram_readdata          : in  std_logic_vector(15 downto 0) := (others => 'X'); -- readdata
			sdram_readdatavalid     : in  std_logic                     := 'X';             -- readdatavalid
			sdram_burstcount        : out std_logic_vector(0 downto 0);                     -- burstcount
			sdram_writedata         : out std_logic_vector(15 downto 0);                    -- writedata
			sdram_address           : out std_logic_vector(24 downto 0);                    -- address
			sdram_write             : out std_logic;                                        -- write
			sdram_read              : out std_logic;                                        -- read
			sdram_byteenable        : out std_logic_vector(1 downto 0);                     -- byteenable
			sdram_debugaccess       : out std_logic                                         -- debugaccess
		);
	end component Platform_Avalon;

	u0 : component Platform_Avalon
		port map (
			clk_clk                 => CONNECTED_TO_clk_clk,                 --       clk.clk
			master_waitrequest      => CONNECTED_TO_master_waitrequest,      --    master.waitrequest
			master_readdata         => CONNECTED_TO_master_readdata,         --          .readdata
			master_readdatavalid    => CONNECTED_TO_master_readdatavalid,    --          .readdatavalid
			master_burstcount       => CONNECTED_TO_master_burstcount,       --          .burstcount
			master_writedata        => CONNECTED_TO_master_writedata,        --          .writedata
			master_address          => CONNECTED_TO_master_address,          --          .address
			master_write            => CONNECTED_TO_master_write,            --          .write
			master_read             => CONNECTED_TO_master_read,             --          .read
			master_byteenable       => CONNECTED_TO_master_byteenable,       --          .byteenable
			master_debugaccess      => CONNECTED_TO_master_debugaccess,      --          .debugaccess
			registers_waitrequest   => CONNECTED_TO_registers_waitrequest,   -- registers.waitrequest
			registers_readdata      => CONNECTED_TO_registers_readdata,      --          .readdata
			registers_readdatavalid => CONNECTED_TO_registers_readdatavalid, --          .readdatavalid
			registers_burstcount    => CONNECTED_TO_registers_burstcount,    --          .burstcount
			registers_writedata     => CONNECTED_TO_registers_writedata,     --          .writedata
			registers_address       => CONNECTED_TO_registers_address,       --          .address
			registers_write         => CONNECTED_TO_registers_write,         --          .write
			registers_read          => CONNECTED_TO_registers_read,          --          .read
			registers_byteenable    => CONNECTED_TO_registers_byteenable,    --          .byteenable
			registers_debugaccess   => CONNECTED_TO_registers_debugaccess,   --          .debugaccess
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --     reset.reset_n
			sdram_waitrequest       => CONNECTED_TO_sdram_waitrequest,       --     sdram.waitrequest
			sdram_readdata          => CONNECTED_TO_sdram_readdata,          --          .readdata
			sdram_readdatavalid     => CONNECTED_TO_sdram_readdatavalid,     --          .readdatavalid
			sdram_burstcount        => CONNECTED_TO_sdram_burstcount,        --          .burstcount
			sdram_writedata         => CONNECTED_TO_sdram_writedata,         --          .writedata
			sdram_address           => CONNECTED_TO_sdram_address,           --          .address
			sdram_write             => CONNECTED_TO_sdram_write,             --          .write
			sdram_read              => CONNECTED_TO_sdram_read,              --          .read
			sdram_byteenable        => CONNECTED_TO_sdram_byteenable,        --          .byteenable
			sdram_debugaccess       => CONNECTED_TO_sdram_debugaccess        --          .debugaccess
		);

