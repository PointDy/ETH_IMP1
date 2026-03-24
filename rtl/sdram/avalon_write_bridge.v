module avalon_write_bridge #(
    parameter ADDR_WIDTH = 25,
    parameter DATA_WIDTH = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   vsync,         // 【新增】接摄像头的 cam_vsync

    input  wire                   fifo_empty,
    input  wire [DATA_WIDTH-1:0]  fifo_rd_data,
    output reg                    fifo_rd_en,

    output reg  [ADDR_WIDTH-1:0]  avm_address,
    output reg                    avm_write,
    output reg  [DATA_WIDTH-1:0]  avm_writedata,
    input  wire                   avm_waitrequest,

    input  wire [ADDR_WIDTH-1:0]  base_addr,
    input  wire [ADDR_WIDTH-1:0]  max_addr
);

    // VSYNC 边沿检测
    reg vsync_d1, vsync_d2;
    always @(posedge clk) begin
        vsync_d1 <= vsync;
        vsync_d2 <= vsync_d1;
    end
    wire vsync_pos = vsync_d1 & ~vsync_d2; // 捕捉一帧开始的上升沿

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            avm_write     <= 1'b0;
            avm_writedata <= 16'd0;
            avm_address   <= base_addr;
            fifo_rd_en    <= 1'b0;
        end else if (vsync_pos) begin
            // 【核心修复】：每帧开始，强行将写指针拨回起点，杜绝永久性错位！
            avm_address   <= base_addr;
            avm_write     <= 1'b0;
            fifo_rd_en    <= 1'b0;
        end else begin
            fifo_rd_en <= 1'b0;
            if (avm_write) begin
                if (!avm_waitrequest) begin
                    avm_write <= 1'b0;
                    if (avm_address >= max_addr - 2) 
                        avm_address <= base_addr;
                    else 
                        avm_address <= avm_address + 2;
                end
            end 
            else if (!fifo_empty) begin
                avm_write     <= 1'b1;
                avm_writedata <= fifo_rd_data;
                fifo_rd_en    <= 1'b1;
            end
        end
    end
endmodule