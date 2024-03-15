
`include "top.svh"
`include "axi4_lite_if.svh"

module tx_buffer(
    input  logic       tx_clk,
    input  logic       tx_ready,
    output logic [7:0] tx_data,
    output logic       tx_charisk,
    input  logic       tx_odd,

    input  logic       app_clk,
    input  logic       aresetn,
    axi4_lite_if.s     axi
);
    logic        ready;
    logic        start;

    logic [8:0] data_in;
    logic        data_upd;
    logic        wr_en;

    logic [8:0] data_out;
    logic        rd_en;

    logic        full;
    logic        empty;

    logic        empty_app_clk;
    logic        ready_app_clk;
    logic        tx_run;

    typedef enum  {
        IDLE,
        START,
        STOP,
        ODD,
        EVEN
    } tx_fsm_state_t;
    tx_fsm_state_t tx_state;
    tx_fsm_state_t tx_next;

//MMR logic 
    typedef logic [MMR_DEV_ADDR_W-1:0] addr_t;
    typedef logic [    MMR_DATA_W-1:0] data_t;

    typedef enum addr_t {
        SR            = addr_t'(8'h00),
        CR            = addr_t'(8'h04),
        CR_S          = addr_t'(8'h08),
        CR_C          = addr_t'(8'h0C),
        DATA          = addr_t'(8'h14)
    } tx_regs;

    typedef struct packed {
        logic ready;
        logic full;
        logic empty;
    } sr_t;

    typedef struct packed {
        logic start;
    } cr_t;

    sr_t sr;
    cr_t cr;
    logic [MMR_DEV_ADDR_W-1:0] addr;
    logic [MMR_DATA_W-1:0] data;
    logic read;
    logic write_addr;
    logic write_data;

    assign sr.ready       = ready_app_clk;
    assign sr.full        = full;
    assign sr.empty       = empty_app_clk;
    assign start          = cr.start;

    always_ff @(posedge app_clk) begin
        if (!aresetn) begin
            axi.arready  <= '0;
            axi.rvalid   <= '0;
            axi.awready  <= '0;
            axi.wready   <= '0;
            axi.bvalid   <= '0;
            axi.rresp    <= '0;
            axi.bresp    <= '0;
            axi.rdata    <= '0;
            read         <= '0;
            write_addr   <= '0;
            write_data   <= '0;
            cr.start     <= '0;
            data_upd     <= '0;
        end
        else begin
            axi.arready <= 0;
            if(axi.arvalid && !read) begin
                addr <= axi.araddr;
                read <= 1;
                axi.arready <= 1;
            end 

            axi.rvalid <= read;
            if(axi.rready && read) begin
                read <= 0;
                case (addr)
                    SR            : axi.rdata <= data_t'(sr);
                    CR            : axi.rdata <= data_t'(cr);
                    default       : axi.rdata <= '0;
                endcase 
            end 


            axi.awready <= 0;
            if(axi.awvalid && !write_addr) begin
                addr <= axi.awaddr;
                write_addr  <= 1;
                axi.awready <= 1;
            end 

            axi.wready <= 0;
            if(axi.wvalid && !write_data) begin
                data <= axi.wdata;
                write_data <= 1;
                axi.wready <= 1;
            end 

            axi.bvalid <= write_addr && write_data;
            if(axi.bready && write_addr && write_data) begin
                write_addr <= 0;
                write_data <= 0;
                case (addr)
                    CR        : cr         <= cr_t'(data);
                    CR_S      : cr         <= cr | cr_t'(data);
                    CR_C      : cr         <= cr & ~(cr_t'(data));
                    DATA      : begin
                                data_in    <= data;
                                data_upd   <= 1;
                    end
                    default;
                endcase
            end 
            
        end


        if(data_upd) begin
            data_upd <= '0;
        end 
        if(cr.start)
            cr.start <= !tx_run;
    end

    assign wr_en = data_upd;

// FIFO read
    assign rd_en      = tx_state == EVEN;
    assign tx_data    = tx_state == ODD ? data_out[7:0] : '0;
    assign tx_charisk = tx_state == ODD ? data_out[8]   : '0;;

    assign ready    = tx_state == IDLE;

    always_ff @(posedge tx_clk) begin
        tx_state <= tx_next;
        case (tx_state)
            IDLE : begin
            end
            ODD  : begin 
            end
            EVEN : begin 
            end
            default;
        endcase
    end

    always_comb begin
        case (tx_state)
            IDLE : tx_next = start && tx_odd ? EVEN : IDLE;
            EVEN : tx_next = ODD;
            ODD  : tx_next = empty ? IDLE : EVEN;
            default; 
        endcase
    end

    xpm_cdc_single #(
        .SIM_ASSERT_CHK(1)
    )
    xpm_cdc_empty (
        .dest_out(empty_app_clk),
        .dest_clk(app_clk),
        .src_clk(tx_clk),
        .src_in(empty)
    );

    xpm_cdc_single #(
        .SIM_ASSERT_CHK(1)
    )
    xpm_cdc_run (
        .dest_out(tx_run),
        .dest_clk(app_clk),
        .src_clk(tx_clk),
        .src_in(tx_state != IDLE)
    );

    xpm_cdc_single #(
        .SIM_ASSERT_CHK(1)
    )
    xpm_cdc_ready (
        .dest_out(ready_app_clk),
        .dest_clk(app_clk),
        .src_clk(tx_clk),
        .src_in(ready)
    );


// FIFO
    FIFO18E1 #(
    .DATA_WIDTH(18),                    // Sets data width to 4-36
    .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
    .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
    .FIFO_MODE("FIFO18"),              // Sets mode to FIFO18 or FIFO18_36
    .FIRST_WORD_FALL_THROUGH("FALSE"), // Sets the FIFO FWFT to FALSE, TRUE
    .INIT(36'h000000000),              // Initial values on output port
    .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
    .SRVAL(36'h000000000)              // Set/Reset value for output port
    )
    FIFO18E1_inst (
    // Read Data: 32-bit (each) output: Read output data
    .DO(data_out),                   // 32-bit output: Data output
    .DOP(),                 // 4-bit output: Parity data output
    .EMPTY(empty),             // 1-bit output: Empty flag
    .FULL(full),               // 1-bit output: Full flag
    // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
    .RDCLK(tx_clk),             // 1-bit input: Read clock
    .RDEN(rd_en),               // 1-bit input: Read enable
    .REGCE(1),             // 1-bit input: Clock enable
    .RST(!aresetn),                 // 1-bit input: Asynchronous Reset
    .RSTREG(!aresetn),           // 1-bit input: Output register set/reset
    // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
    .WRCLK(app_clk),             // 1-bit input: Write clock
    .WREN(wr_en),               // 1-bit input: Write enable
    // Write Data: 32-bit (each) input: Write input data
    .DI(data_in)                   // 32-bit input: Data input
    );

endmodule