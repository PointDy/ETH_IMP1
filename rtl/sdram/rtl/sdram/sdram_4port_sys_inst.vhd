	component sdram_4port_sys is
		port (
			clk_clk                     : in    std_logic                     := 'X';             -- clk
			reset_reset_n               : in    std_logic                     := 'X';             -- reset_n
			sdram_wire_addr             : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba               : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n            : out   std_logic;                                        -- cas_n
			sdram_wire_cke              : out   std_logic;                                        -- cke
			sdram_wire_cs_n             : out   std_logic;                                        -- cs_n
			sdram_wire_dq               : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm              : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n            : out   std_logic;                                        -- ras_n
			sdram_wire_we_n             : out   std_logic;                                        -- we_n
			port1_cam_wr_waitrequest    : out   std_logic;                                        -- waitrequest
			port1_cam_wr_readdata       : out   std_logic_vector(15 downto 0);                    -- readdata
			port1_cam_wr_readdatavalid  : out   std_logic;                                        -- readdatavalid
			port1_cam_wr_burstcount     : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			port1_cam_wr_writedata      : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			port1_cam_wr_address        : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			port1_cam_wr_write          : in    std_logic                     := 'X';             -- write
			port1_cam_wr_read           : in    std_logic                     := 'X';             -- read
			port1_cam_wr_byteenable     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
			port1_cam_wr_debugaccess    : in    std_logic                     := 'X';             -- debugaccess
			port2_diff_wr_waitrequest   : out   std_logic;                                        -- waitrequest
			port2_diff_wr_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
			port2_diff_wr_readdatavalid : out   std_logic;                                        -- readdatavalid
			port2_diff_wr_burstcount    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			port2_diff_wr_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			port2_diff_wr_address       : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			port2_diff_wr_write         : in    std_logic                     := 'X';             -- write
			port2_diff_wr_read          : in    std_logic                     := 'X';             -- read
			port2_diff_wr_byteenable    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
			port2_diff_wr_debugaccess   : in    std_logic                     := 'X';             -- debugaccess
			port3_diff_rd_waitrequest   : out   std_logic;                                        -- waitrequest
			port3_diff_rd_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
			port3_diff_rd_readdatavalid : out   std_logic;                                        -- readdatavalid
			port3_diff_rd_burstcount    : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			port3_diff_rd_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			port3_diff_rd_address       : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			port3_diff_rd_write         : in    std_logic                     := 'X';             -- write
			port3_diff_rd_read          : in    std_logic                     := 'X';             -- read
			port3_diff_rd_byteenable    : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
			port3_diff_rd_debugaccess   : in    std_logic                     := 'X';             -- debugaccess
			port4_eth_rd_waitrequest    : out   std_logic;                                        -- waitrequest
			port4_eth_rd_readdata       : out   std_logic_vector(15 downto 0);                    -- readdata
			port4_eth_rd_readdatavalid  : out   std_logic;                                        -- readdatavalid
			port4_eth_rd_burstcount     : in    std_logic_vector(0 downto 0)  := (others => 'X'); -- burstcount
			port4_eth_rd_writedata      : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			port4_eth_rd_address        : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			port4_eth_rd_write          : in    std_logic                     := 'X';             -- write
			port4_eth_rd_read           : in    std_logic                     := 'X';             -- read
			port4_eth_rd_byteenable     : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable
			port4_eth_rd_debugaccess    : in    std_logic                     := 'X'              -- debugaccess
		);
	end component sdram_4port_sys;

	u0 : component sdram_4port_sys
		port map (
			clk_clk                     => CONNECTED_TO_clk_clk,                     --           clk.clk
			reset_reset_n               => CONNECTED_TO_reset_reset_n,               --         reset.reset_n
			sdram_wire_addr             => CONNECTED_TO_sdram_wire_addr,             --    sdram_wire.addr
			sdram_wire_ba               => CONNECTED_TO_sdram_wire_ba,               --              .ba
			sdram_wire_cas_n            => CONNECTED_TO_sdram_wire_cas_n,            --              .cas_n
			sdram_wire_cke              => CONNECTED_TO_sdram_wire_cke,              --              .cke
			sdram_wire_cs_n             => CONNECTED_TO_sdram_wire_cs_n,             --              .cs_n
			sdram_wire_dq               => CONNECTED_TO_sdram_wire_dq,               --              .dq
			sdram_wire_dqm              => CONNECTED_TO_sdram_wire_dqm,              --              .dqm
			sdram_wire_ras_n            => CONNECTED_TO_sdram_wire_ras_n,            --              .ras_n
			sdram_wire_we_n             => CONNECTED_TO_sdram_wire_we_n,             --              .we_n
			port1_cam_wr_waitrequest    => CONNECTED_TO_port1_cam_wr_waitrequest,    --  port1_cam_wr.waitrequest
			port1_cam_wr_readdata       => CONNECTED_TO_port1_cam_wr_readdata,       --              .readdata
			port1_cam_wr_readdatavalid  => CONNECTED_TO_port1_cam_wr_readdatavalid,  --              .readdatavalid
			port1_cam_wr_burstcount     => CONNECTED_TO_port1_cam_wr_burstcount,     --              .burstcount
			port1_cam_wr_writedata      => CONNECTED_TO_port1_cam_wr_writedata,      --              .writedata
			port1_cam_wr_address        => CONNECTED_TO_port1_cam_wr_address,        --              .address
			port1_cam_wr_write          => CONNECTED_TO_port1_cam_wr_write,          --              .write
			port1_cam_wr_read           => CONNECTED_TO_port1_cam_wr_read,           --              .read
			port1_cam_wr_byteenable     => CONNECTED_TO_port1_cam_wr_byteenable,     --              .byteenable
			port1_cam_wr_debugaccess    => CONNECTED_TO_port1_cam_wr_debugaccess,    --              .debugaccess
			port2_diff_wr_waitrequest   => CONNECTED_TO_port2_diff_wr_waitrequest,   -- port2_diff_wr.waitrequest
			port2_diff_wr_readdata      => CONNECTED_TO_port2_diff_wr_readdata,      --              .readdata
			port2_diff_wr_readdatavalid => CONNECTED_TO_port2_diff_wr_readdatavalid, --              .readdatavalid
			port2_diff_wr_burstcount    => CONNECTED_TO_port2_diff_wr_burstcount,    --              .burstcount
			port2_diff_wr_writedata     => CONNECTED_TO_port2_diff_wr_writedata,     --              .writedata
			port2_diff_wr_address       => CONNECTED_TO_port2_diff_wr_address,       --              .address
			port2_diff_wr_write         => CONNECTED_TO_port2_diff_wr_write,         --              .write
			port2_diff_wr_read          => CONNECTED_TO_port2_diff_wr_read,          --              .read
			port2_diff_wr_byteenable    => CONNECTED_TO_port2_diff_wr_byteenable,    --              .byteenable
			port2_diff_wr_debugaccess   => CONNECTED_TO_port2_diff_wr_debugaccess,   --              .debugaccess
			port3_diff_rd_waitrequest   => CONNECTED_TO_port3_diff_rd_waitrequest,   -- port3_diff_rd.waitrequest
			port3_diff_rd_readdata      => CONNECTED_TO_port3_diff_rd_readdata,      --              .readdata
			port3_diff_rd_readdatavalid => CONNECTED_TO_port3_diff_rd_readdatavalid, --              .readdatavalid
			port3_diff_rd_burstcount    => CONNECTED_TO_port3_diff_rd_burstcount,    --              .burstcount
			port3_diff_rd_writedata     => CONNECTED_TO_port3_diff_rd_writedata,     --              .writedata
			port3_diff_rd_address       => CONNECTED_TO_port3_diff_rd_address,       --              .address
			port3_diff_rd_write         => CONNECTED_TO_port3_diff_rd_write,         --              .write
			port3_diff_rd_read          => CONNECTED_TO_port3_diff_rd_read,          --              .read
			port3_diff_rd_byteenable    => CONNECTED_TO_port3_diff_rd_byteenable,    --              .byteenable
			port3_diff_rd_debugaccess   => CONNECTED_TO_port3_diff_rd_debugaccess,   --              .debugaccess
			port4_eth_rd_waitrequest    => CONNECTED_TO_port4_eth_rd_waitrequest,    --  port4_eth_rd.waitrequest
			port4_eth_rd_readdata       => CONNECTED_TO_port4_eth_rd_readdata,       --              .readdata
			port4_eth_rd_readdatavalid  => CONNECTED_TO_port4_eth_rd_readdatavalid,  --              .readdatavalid
			port4_eth_rd_burstcount     => CONNECTED_TO_port4_eth_rd_burstcount,     --              .burstcount
			port4_eth_rd_writedata      => CONNECTED_TO_port4_eth_rd_writedata,      --              .writedata
			port4_eth_rd_address        => CONNECTED_TO_port4_eth_rd_address,        --              .address
			port4_eth_rd_write          => CONNECTED_TO_port4_eth_rd_write,          --              .write
			port4_eth_rd_read           => CONNECTED_TO_port4_eth_rd_read,           --              .read
			port4_eth_rd_byteenable     => CONNECTED_TO_port4_eth_rd_byteenable,     --              .byteenable
			port4_eth_rd_debugaccess    => CONNECTED_TO_port4_eth_rd_debugaccess     --              .debugaccess
		);

