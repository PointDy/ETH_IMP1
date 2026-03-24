module  vga_ctrl
(
    input   wire            vga_clk     ,   //输入工作时钟,必须提供 40MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [15:0]  data_in     ,   //待显示数据输入 (接 FIFO 的 q)

    output  wire            rgb_valid   ,   //VGA有效显示区域 (可直接作为 HDMI 的 DE 信号)
    output  wire            data_req    ,   //数据请求信号 (接 FIFO 的 rdreq)
    output  wire            hsync       ,   //输出行同步信号
    output  wire            vsync       ,   //输出场同步信号
    output  wire    [15:0]  rgb         //输出像素信息
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//

// 【核心修改】：替换为 800x600 @ 60Hz 的标准时序参数 (Pixel Clock = 40MHz)
parameter   H_SYNC    = 11'd128 , //行同步
            H_BACK    = 11'd88  , //行时序后沿
            H_LEFT    = 11'd0   , //行时序左边框 (标准里通常为0)
            H_VALID   = 11'd800 , //行有效数据
            H_RIGHT   = 11'd0   , //行时序右边框 (标准里通常为0)
            H_FRONT   = 11'd40  , //行时序前沿
            H_TOTAL   = 11'd1056; //行扫描周期

parameter   V_SYNC    = 11'd4   , //场同步
            V_BACK    = 11'd23  , //场时序后沿
            V_TOP     = 11'd0   , //场时序左边框
            V_VALID   = 11'd600 , //场有效数据
            V_BOTTOM  = 11'd0   , //场时序右边框
            V_FRONT   = 11'd1   , //场时序前沿
            V_TOTAL   = 11'd628 ; //场扫描周期

//reg   define
reg   [10:0]     cnt_h       ;   //行同步信号计数器
reg   [10:0]     cnt_v       ;   //场同步信号计数器

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//cnt_h:行同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_h <=  11'd0 ;
    else    if(cnt_h == (H_TOTAL-1'b1))
        cnt_h <=  11'd0 ;
    else
        cnt_h <=  cnt_h + 1'b1 ;

//hsync:行同步信号
assign  hsync = (cnt_h <= H_SYNC-1) ? 1'b1 : 1'b0  ;

//cnt_v:场同步信号计数器
always@(posedge vga_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_v <=  11'd0 ;
    else    if((cnt_v == V_TOTAL- 1'b1)&&(cnt_h == H_TOTAL - 1'b1))
        cnt_v <=  11'd0 ;
    else    if(cnt_h == H_TOTAL - 1'b1)
        cnt_v <=  cnt_v + 1'b1 ;
    else
        cnt_v <=  cnt_v ;

//vsync:场同步信号
assign  vsync = (cnt_v <= V_SYNC - 1'b1) ? 1'b1 : 1'b0  ;

//data_valid:有效显示区域标志
assign  rgb_valid = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT)) && (cnt_h < (H_SYNC + H_BACK + H_LEFT + H_VALID)))
                    &&((cnt_v >= (V_SYNC + V_BACK + V_TOP)) && (cnt_v < (V_SYNC + V_BACK + V_TOP + V_VALID)));

//data_req:数据请求信号 (巧妙地提前 1 个周期，完美适配 Normal FIFO)
assign  data_req = ((cnt_h >= (H_SYNC + H_BACK + H_LEFT) - 1'b1) && (cnt_h < ((H_SYNC + H_BACK + H_LEFT + H_VALID) - 1'b1)))
                    &&((cnt_v >= ((V_SYNC + V_BACK + V_TOP))) && (cnt_v < ((V_SYNC + V_BACK + V_TOP + V_VALID))));

//rgb:输出像素信息
assign  rgb = (rgb_valid == 1'b1) ? data_in : 16'b0 ;

endmodule