
`include "top.svh"
`include "axi4_lite_if.svh"

module event_fifo(
    input  logic       aclk,
    input  logic       aresetn,

    input  logic       wr_en,
    input  logic [7:0] data_in,

    axi4_lite_if.s     axi
);
    logic [7:0] data_out;
    logic        rd_en;

    logic        full;
    logic        empty;

    typedef enum  {
        IDLE,
        START,
        STOP
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
        logic full;
        logic empty;
    } sr_t;

    typedef struct packed {
        logic none;
    } cr_t;

    sr_t sr;
    cr_t cr;
    logic [MMR_DEV_ADDR_W-1:0] addr;
    logic [MMR_DATA_W-1:0]     data;
    logic read;
    logic write_addr;
    logic write_data;
    logic delay1;
    logic delay2;
    logic delay3;

    assign sr.full        = full;
    assign sr.empty       = empty;

    always_ff @(posedge aclk) begin
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
            rd_en        <= 0;
            delay1       <= 0;
            delay2       <= 0;
            delay3       <= 0;
        end
        else begin
            axi.arready <= 0;
            rd_en       <= 0;

            if(axi.arvalid && !read) begin
                addr <= axi.araddr;
                read <= 1;
                axi.arready <= 1;
            end 

            axi.rvalid <= delay3;
            if(axi.rready && read) begin
                delay1    <= 1;
                read      <= 0;  
                case (addr)
                    DATA          : begin 
                                    rd_en     <= 1;
                    end
                    default       : ;
                endcase 
            end 

            if(delay1) begin
                delay1 <= 0;
                delay2 <= 1;
            end
            if(delay2) begin
                delay2 <= 0;
                delay3 <= 1;
            end

            if(delay3) begin
                delay3 <= 0;
                case (addr)
                    SR            : axi.rdata <= data_t'(sr);
                    CR            : axi.rdata <= data_t'(cr);
                    DATA          : begin 
                                    axi.rdata <= data_t'(data_out);
                    end
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
                    default;
                endcase
            end 
            
        end
    end

// FIFO
    FIFO18E1 #(
    .DATA_WIDTH(9),                    // Sets data width to 4-36
    .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
    .EN_SYN("TRUE"),                  // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
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
    .RDCLK(aclk),             // 1-bit input: Read clock
    .RDEN(rd_en),               // 1-bit input: Read enable
    .REGCE(1),             // 1-bit input: Clock enable
    .RST(!aresetn),                 // 1-bit input: Asynchronous Reset
    .RSTREG(!aresetn),           // 1-bit input: Output register set/reset
    // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
    .WRCLK(aclk),             // 1-bit input: Write clock
    .WREN(wr_en),               // 1-bit input: Write enable
    // Write Data: 32-bit (each) input: Write input data
    .DI(data_in)                   // 32-bit input: Data input
    );

endmodule