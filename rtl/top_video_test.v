module top_video_test (
    input  wire        sys_clk_50m,  // 开发板外部 50MHz 晶振
    input  wire        sys_rst_n,    // 开发板外部复位按键 (低电平有效)

    // === OV5640 摄像头物理接口 ===
    output wire        cam_scl,
    inout  wire        cam_sda,
    input  wire        cam_vsync,
    input  wire        cam_href,
    input  wire        cam_pclk,
    input  wire [7:0]  cam_data,
    output wire        cam_reset,    // 摄像头硬件复位引脚
    output wire        cam_pwdn,     // 摄像头休眠控制引脚

    // === SDRAM (W9825G6KH) 物理接口 ===
    output wire        sdram_clk,
    output wire        sdram_cke,
    output wire        sdram_cs_n,
    output wire        sdram_ras_n,
    output wire        sdram_cas_n,
    output wire        sdram_we_n,
    output wire [1:0]  sdram_ba,
    output wire [12:0] sdram_addr,
    inout  wire [15:0] sdram_dq,
    output wire [1:0]  sdram_dqm,

    // === HDMI 物理接口 (TMDS 差分引脚) ===
    output wire        tmds_clk_p,   // HDMI 时钟通道 P
    output wire        tmds_clk_n,   // HDMI 时钟通道 N
    output wire [2:0]  tmds_data_p,  // HDMI 数据通道 P (RGB)
    output wire [2:0]  tmds_data_n,  // HDMI 数据通道 N (RGB)
    
    // === HDMI DDC (I2C) 显示器探测假引脚 ===
    output wire        hdmi_ddc_scl,
    inout  wire        hdmi_ddc_sda
);

    // =========================================================
    // 0. HDMI 兼容性处理 (防止挑剔的显示器休眠)
    // =========================================================
    assign hdmi_ddc_scl = 1'b1;
    assign hdmi_ddc_sda = 1'bz; // 高阻态，由外部上拉电阻保持 I2C 空闲

    // =========================================================
    // 1. 系统时钟与全局复位管理 (4 路输出)
    // =========================================================
    wire clk_100m;       // c0: 100MHz 内部工作主频
    wire clk_100m_shift; // c1: 100MHz SDRAM 物理时钟 (-75度相位)
    wire clk_40m;        // c2: 40MHz HDMI 像素时钟 (800x600@60Hz)
    wire clk_200m;       // c3: 200MHz HDMI 5倍串行时钟
    wire pll_locked;
    
    // 只有复位没按下且 PLL 稳定时，系统才启动
    wire rst_n = sys_rst_n & pll_locked; 
    
    // 偏移时钟直通 SDRAM
    assign sdram_clk = clk_100m_shift; 

    pll_inst u_pll (
        .inclk0 (sys_clk_50m),
        .c0     (clk_100m),       
        .c1     (clk_100m_shift), 
        .c2     (clk_40m),        // 像素时钟
        .c3     (clk_200m),       // 串行高速时钟
        .locked (pll_locked)
    );

    // =========================================================
    // 2. 摄像头采集端 (OV5640)
    // =========================================================
    wire        cam_cfg_done;
    wire [15:0] cam_pixel_data;
    wire        cam_wr_en; 
    
    // 摄像头硬件电源与复位常态
    assign cam_pwdn  = 1'b0;    
    assign cam_reset = rst_n;   

    // 你原版的摄像头驱动 (输入必须是 50MHz 以生成 250kHz SCCB)
    ov5640_top u_ov5640_top (
        .sys_clk        (sys_clk_50m),     
        .sys_rst_n      (rst_n),
        .sys_init_done  (cam_cfg_done),    
        
        .ov5640_pclk    (cam_pclk),
        .ov5640_href    (cam_href),
        .ov5640_vsync   (cam_vsync),
        .ov5640_data    (cam_data),
        
        .cfg_done       (cam_cfg_done),
        .sccb_scl       (cam_scl),
        .sccb_sda       (cam_sda),
        
        .ov5640_wr_en   (cam_wr_en),
        .ov5640_data_out(cam_pixel_data)
    );

    // 摄像头的跨时钟域 FIFO (写时钟 cam_pclk -> 读时钟 100MHz)
    wire        cam_fifo_empty;
    wire [15:0] cam_fifo_rd_data;
    wire        cam_fifo_rd_en;

    cam_fifo u_cam_fifo (
        .wrclk   (cam_pclk),
        .wrreq   (cam_wr_en),
        .data    (cam_pixel_data),
        .rdclk   (clk_100m),
        .rdreq   (cam_fifo_rd_en),
        .q       (cam_fifo_rd_data),
        .rdempty (cam_fifo_empty),
        .wrfull  () 
    );

    // =========================================================
    // 3. 核心桥接器与 Qsys 仲裁系统 (带 VSYNC 帧同步对齐)
    // =========================================================
    
    // --- 通道 1：摄像头写入 ---
    wire [24:0] port1_address;
    wire        port1_write;
    wire [15:0] port1_writedata;
    wire        port1_waitrequest;

    avalon_write_bridge #(
        .ADDR_WIDTH (25), .DATA_WIDTH (16)
    ) u_cam_wr_bridge (
        .clk             (clk_100m),
        .rst_n           (rst_n),
        .vsync           (cam_vsync),         // 【帧同步】：摄像头场同步
        .fifo_empty      (cam_fifo_empty),
        .fifo_rd_data    (cam_fifo_rd_data),
        .fifo_rd_en      (cam_fifo_rd_en),
        .avm_address     (port1_address),
        .avm_write       (port1_write),
        .avm_writedata   (port1_writedata),
        .avm_waitrequest (port1_waitrequest),
        .base_addr       (25'h0000000),      
        .max_addr        (25'd960000)         // 【容量】：800 * 600 * 2
    );

    // --- 通道 4：HDMI 画面读取 ---
    wire [24:0] port4_address;
    wire        port4_read;
    wire [15:0] port4_readdata;
    wire        port4_readdatavalid;
    wire        port4_waitrequest;
    
    wire [10:0] hdmi_fifo_wrusedw; 
    wire        hdmi_fifo_wr_en;
    wire [15:0] hdmi_fifo_wr_data;
    
    wire        vga_vs; // VGA 场同步信号 (从下方的模块引上来)

    avalon_read_bridge #(
        .ADDR_WIDTH (25), .DATA_WIDTH (16), .FIFO_THRESHOLD(1024)
    ) u_hdmi_rd_bridge (
        .clk             (clk_100m),
        .rst_n           (rst_n),
        .vsync           (vga_vs),            // 【帧同步】：显示器场同步
        .fifo_usedw      ({5'd0, hdmi_fifo_wrusedw}), 
        .fifo_wr_en      (hdmi_fifo_wr_en),
        .fifo_wr_data    (hdmi_fifo_wr_data),
        .avm_address     (port4_address),
        .avm_read        (port4_read),
        .avm_readdata    (port4_readdata),
        .avm_readdatavalid(port4_readdatavalid),
        .avm_waitrequest (port4_waitrequest),
        .base_addr       (25'h0000000),      
        .max_addr        (25'd960000)         // 【容量】：800 * 600 * 2
    );

    // --- Qsys 4端口 SDRAM 系统 ---
    sdram_4port_sys u_sdram_sys (
        .clk_clk                      (clk_100m),
        .reset_reset_n                (rst_n),
        
        .sdram_wire_addr              (sdram_addr),
        .sdram_wire_ba                (sdram_ba),
        .sdram_wire_cas_n             (sdram_cas_n),
        .sdram_wire_cke               (sdram_cke),
        .sdram_wire_cs_n              (sdram_cs_n),
        .sdram_wire_dq                (sdram_dq),
        .sdram_wire_dqm               (sdram_dqm),
        .sdram_wire_ras_n             (sdram_ras_n),
        .sdram_wire_we_n              (sdram_we_n),

        .port1_cam_wr_address         (port1_address),
        .port1_cam_wr_write           (port1_write),
        .port1_cam_wr_writedata       (port1_writedata),
        .port1_cam_wr_waitrequest     (port1_waitrequest),
        
        .port4_eth_rd_address         (port4_address),
        .port4_eth_rd_read            (port4_read),
        .port4_eth_rd_readdata        (port4_readdata),
        .port4_eth_rd_readdatavalid   (port4_readdatavalid),
        .port4_eth_rd_waitrequest     (port4_waitrequest)
    );

    // =========================================================
    // 4. HDMI 显示终端 (VGA 时序与 TMDS 编码发送)
    // =========================================================
    
    wire [15:0] vga_pixel_data;
    wire        vga_fifo_rd_en;

    // HDMI 专用视频 FIFO (写 100MHz -> 读 40MHz，深度 2048，Normal 模式)
    hdmi_fifo u_hdmi_fifo (
        .data    (hdmi_fifo_wr_data),
        .wrclk   (clk_100m),          
        .wrreq   (hdmi_fifo_wr_en),
        .wrusedw (hdmi_fifo_wrusedw), 
        .wrfull  (),                  
        
        .rdclk   (clk_40m),           // 40MHz 像素时钟
        .rdreq   (vga_fifo_rd_en),
        .q       (vga_pixel_data),
        .rdempty ()                   
    );

    // 800x600 VGA 时序发生器
    wire        vga_hs, vga_de;
    wire [15:0] vga_rgb565;
    
    vga_ctrl u_vga_ctrl (
        .vga_clk    (clk_40m),        // 40MHz
        .sys_rst_n  (rst_n),
        .data_in    (vga_pixel_data),
        .data_req   (vga_fifo_rd_en), // 提前一拍要数据
        .rgb_valid  (vga_de),
        .hsync      (vga_hs),
        .vsync      (vga_vs),         // 吐出 VSYNC 给读取桥接器用于帧对齐
        .rgb        (vga_rgb565)
    );

    // 格式转换：16位 RGB565 -> 24位 RGB888 (利用低位补齐，保持色彩平滑)
    wire [23:0] rgb888;
    assign rgb888 = {vga_rgb565[15:11], vga_rgb565[15:13], // Red (5 -> 8)
                     vga_rgb565[10:5],  vga_rgb565[10:9],  // Green (6 -> 8)
                     vga_rgb565[4:0],   vga_rgb565[4:2]};  // Blue (5 -> 8)

    // HDMI 驱动控制核心 (包含 encode 与 par_to_ser)
    hdmi_ctrl u_hdmi_ctrl (
        .clk_1x      (clk_40m),       // 像素时钟 40MHz
        .clk_5x      (clk_200m),      // 高速串行时钟 200MHz
        .sys_rst_n   (rst_n),
        
        .rgb_red     (rgb888[23:16]),
        .rgb_green   (rgb888[15:8]),
        .rgb_blue    (rgb888[7:0]),
        
        .hsync       (vga_hs),
        .vsync       (vga_vs),
        .de          (vga_de),
        
        // 差分输出引脚
        .hdmi_clk_p  (tmds_clk_p),
        .hdmi_clk_n  (tmds_clk_n),
        .hdmi_r_p    (tmds_data_p[2]),
        .hdmi_r_n    (tmds_data_n[2]),
        .hdmi_g_p    (tmds_data_p[1]),
        .hdmi_g_n    (tmds_data_n[1]),
        .hdmi_b_p    (tmds_data_p[0]),
        .hdmi_b_n    (tmds_data_n[0])
    );

endmodule