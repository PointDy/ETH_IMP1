
module sdram_4port_sys (
	clk_clk,
	reset_reset_n,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	port1_cam_wr_waitrequest,
	port1_cam_wr_readdata,
	port1_cam_wr_readdatavalid,
	port1_cam_wr_burstcount,
	port1_cam_wr_writedata,
	port1_cam_wr_address,
	port1_cam_wr_write,
	port1_cam_wr_read,
	port1_cam_wr_byteenable,
	port1_cam_wr_debugaccess,
	port2_diff_wr_waitrequest,
	port2_diff_wr_readdata,
	port2_diff_wr_readdatavalid,
	port2_diff_wr_burstcount,
	port2_diff_wr_writedata,
	port2_diff_wr_address,
	port2_diff_wr_write,
	port2_diff_wr_read,
	port2_diff_wr_byteenable,
	port2_diff_wr_debugaccess,
	port3_diff_rd_waitrequest,
	port3_diff_rd_readdata,
	port3_diff_rd_readdatavalid,
	port3_diff_rd_burstcount,
	port3_diff_rd_writedata,
	port3_diff_rd_address,
	port3_diff_rd_write,
	port3_diff_rd_read,
	port3_diff_rd_byteenable,
	port3_diff_rd_debugaccess,
	port4_eth_rd_waitrequest,
	port4_eth_rd_readdata,
	port4_eth_rd_readdatavalid,
	port4_eth_rd_burstcount,
	port4_eth_rd_writedata,
	port4_eth_rd_address,
	port4_eth_rd_write,
	port4_eth_rd_read,
	port4_eth_rd_byteenable,
	port4_eth_rd_debugaccess);	

	input		clk_clk;
	input		reset_reset_n;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	output		port1_cam_wr_waitrequest;
	output	[15:0]	port1_cam_wr_readdata;
	output		port1_cam_wr_readdatavalid;
	input	[0:0]	port1_cam_wr_burstcount;
	input	[15:0]	port1_cam_wr_writedata;
	input	[24:0]	port1_cam_wr_address;
	input		port1_cam_wr_write;
	input		port1_cam_wr_read;
	input	[1:0]	port1_cam_wr_byteenable;
	input		port1_cam_wr_debugaccess;
	output		port2_diff_wr_waitrequest;
	output	[15:0]	port2_diff_wr_readdata;
	output		port2_diff_wr_readdatavalid;
	input	[0:0]	port2_diff_wr_burstcount;
	input	[15:0]	port2_diff_wr_writedata;
	input	[24:0]	port2_diff_wr_address;
	input		port2_diff_wr_write;
	input		port2_diff_wr_read;
	input	[1:0]	port2_diff_wr_byteenable;
	input		port2_diff_wr_debugaccess;
	output		port3_diff_rd_waitrequest;
	output	[15:0]	port3_diff_rd_readdata;
	output		port3_diff_rd_readdatavalid;
	input	[0:0]	port3_diff_rd_burstcount;
	input	[15:0]	port3_diff_rd_writedata;
	input	[24:0]	port3_diff_rd_address;
	input		port3_diff_rd_write;
	input		port3_diff_rd_read;
	input	[1:0]	port3_diff_rd_byteenable;
	input		port3_diff_rd_debugaccess;
	output		port4_eth_rd_waitrequest;
	output	[15:0]	port4_eth_rd_readdata;
	output		port4_eth_rd_readdatavalid;
	input	[0:0]	port4_eth_rd_burstcount;
	input	[15:0]	port4_eth_rd_writedata;
	input	[24:0]	port4_eth_rd_address;
	input		port4_eth_rd_write;
	input		port4_eth_rd_read;
	input	[1:0]	port4_eth_rd_byteenable;
	input		port4_eth_rd_debugaccess;
endmodule
