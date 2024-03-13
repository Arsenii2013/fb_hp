
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

    logic [31:0] data_in;
    logic        data_upd;
    logic        wr_en;

    logic [31:0] data_out;
    logic        rd_en;

    logic        full;
    logic        empty;

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

    assign sr.ready       = ready;
    assign sr.full        = full;
    assign sr.empty       = empty;
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
            cr.start <= tx_state == IDLE;
    end

    assign wr_en = data_upd;

// FIFO read
    //start sequence
    logic [3:0]  start_cnt = 0;
    logic [7:0]  start_byte;
    always_comb begin
        case (start_cnt)
            0 : start_byte = '0;
            1 : start_byte = 'h5C;
            2 : start_byte = '0;
            3 : start_byte = '0;
            default; start_byte = '0;
        endcase
    end 

    //data transmit
    logic [1:0]  tx_cnt = 0;
    logic [31:0] tx_word;
    logic [7:0]  tx_bytes[3:0];
    logic [7:0]  tx_byte;
    assign tx_word  = data_out;
    genvar i;
    generate 
    for (i = 0; i < 4; i++) begin
        assign tx_bytes[i] = tx_word[8 * (i + 1) - 1: 8 * i];
    end
    endgenerate
    assign tx_byte    = tx_bytes[tx_cnt];
    assign rd_en    = tx_state == EVEN && tx_cnt == 0;

    //stop and checksum
    logic [15:0] checksum = 'hFFFF;
    logic [3:0]  stop_cnt = 0;
    logic [7:0]  stop_byte;
    always_comb begin
        case (stop_cnt)
            0 : stop_byte = '0;
            1 : stop_byte = 'h3C;
            2 : stop_byte = '0;
            3 : stop_byte = checksum[15:8];
            2 : stop_byte = '0;
            3 : stop_byte = checksum[7:0];
            default; stop_byte = '0;
        endcase
    end 


    assign tx_data    = tx_state == ODD ? tx_byte : '0;
    assign tx_charisk = (tx_state == START && tx_data == 'h5C) || (tx_state == STOP && tx_data == 'h3C) ? 1 : 0;

    assign ready    = tx_state == IDLE;

    always_ff @(posedge tx_clk) begin
        tx_state <= tx_next;
        case (tx_state)
            IDLE : begin
                checksum  <= 'hFFFF; 
                start_cnt <= '0;
                tx_cnt    <= '0;
                stop_cnt  <= '0;
            end
            ODD  : begin 
                tx_cnt   <= tx_cnt + 1;
                checksum <= checksum - tx_byte;
            end
            EVEN : begin 
            end
            default;
        endcase
    end

    always_comb begin
        case (tx_state)
            IDLE : tx_next = start && tx_odd ? START : IDLE;
            START: tx_next = start_cnt == 3 ? EVEN : START;
            EVEN : tx_next = ODD;
            ODD  : tx_next = empty && tx_cnt == 3 ? STOP : EVEN;
            STOP : tx_next = stop_cnt == 3 ? IDLE : STOP;
            default; tx_next = IDLE;
        endcase
    end




// FIFO
    FIFO36E1 #(
    .DATA_WIDTH(72),                    // Sets data width to 4-36
    .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
    .EN_SYN("FALSE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
    .FIFO_MODE("FIFO36_72"),              // Sets mode to FIFO18 or FIFO18_36
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