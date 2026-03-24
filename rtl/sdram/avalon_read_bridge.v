module avalon_read_bridge #(
    parameter ADDR_WIDTH = 25,
    parameter DATA_WIDTH = 16,
    parameter FIFO_THRESHOLD = 512
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   vsync,

    input  wire [15:0]            fifo_usedw,
    output reg                    fifo_wr_en,
    output reg  [DATA_WIDTH-1:0]  fifo_wr_data,

    output reg  [ADDR_WIDTH-1:0]  avm_address,
    output reg                    avm_read,
    input  wire [DATA_WIDTH-1:0]  avm_readdata,
    input  wire                   avm_readdatavalid,
    input  wire                   avm_waitrequest,

    input  wire [ADDR_WIDTH-1:0]  base_addr,
    input  wire [ADDR_WIDTH-1:0]  max_addr
);

    reg [15:0] pending_reads;
    wire read_accepted = avm_read && !avm_waitrequest;
    // 判断 FIFO 是否还有充足的空间接收数据
    wire can_request = (fifo_usedw + pending_reads) < FIFO_THRESHOLD;

    // VSYNC 边沿检测 (用于帧对齐)
    reg vsync_d1, vsync_d2;
    always @(posedge clk) begin
        vsync_d1 <= vsync;
        vsync_d2 <= vsync_d1;
    end
    wire vsync_pos = vsync_d1 & ~vsync_d2;

    // 超高速流水线读取状态机 (允许背靠背连续读取)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            avm_read    <= 1'b0;
            avm_address <= base_addr;
        end else if (vsync_pos) begin
            avm_read    <= 1'b0;
            avm_address <= base_addr;
        end else begin
            // 只要 FIFO 有空位，就死死拉高读请求，榨干总线带宽
            if (can_request) begin
                avm_read <= 1'b1;
            end else if (!avm_waitrequest) begin
                avm_read <= 1'b0;
            end

            // 只要总线响应了请求，地址立刻 +2
            if (avm_read && !avm_waitrequest) begin
                if (avm_address >= max_addr - 2)
                    avm_address <= base_addr;
                else
                    avm_address <= avm_address + 2;
            end
        end
    end

    // 精准跟踪在途数据，并写入 FIFO
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending_reads <= 16'd0;
            fifo_wr_en    <= 1'b0;
            fifo_wr_data  <= 0;
        end else if (vsync_pos) begin
            pending_reads <= 16'd0;
            fifo_wr_en    <= 1'b0;
        end else begin
            fifo_wr_en   <= avm_readdatavalid;
            fifo_wr_data <= avm_readdata;

            if (read_accepted && !avm_readdatavalid)
                pending_reads <= pending_reads + 1'b1;
            else if (!read_accepted && avm_readdatavalid)
                pending_reads <= pending_reads - 1'b1;
        end
    end
endmodule