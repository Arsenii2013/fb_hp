`ifndef __AFE_MODEL_SV__
`define __AFE_MODEL_SV__

`include "top.svh"
`include "afe.svh"
`include "axi4_lite_if.svh"

//------------------------------------------------
//
//      LLRF initialization synchronization module
//
module afe_model import afe_pkg::*;
(
    input  logic   clk,
    input  logic   clk_d2,
    input  logic   aresetn,

    output logic   afe_ready,
    input  logic   sync_x2,
    input  logic   align_x2,
    axi4_lite_if.s afe_ctrl_i,
    axi4_lite_if.s test_mmr
);
    logic [32:0] dds_prd      = 0;
    logic [32:0] cnt          = 0;
    logic        aligned      = 0;
    logic        synchronized = 0;

    assign afe_ready = aresetn;

    always_ff @(posedge clk_d2) begin
        if(align_x2)
            aligned <= 1;
        if(sync_x2)
            synchronized <= 1;

        if(sync_x2) begin
            dds_prd <= (dds_prd + cnt) >> 1;
            cnt <= 0;
        end 
        else if(synchronized)
            cnt <= cnt + 1;
    end

    mem_wrapper
    mem_wrapper_i (
        .aclk(clk),
        .aresetn(aresetn),
        .axi(afe_ctrl_i),
        .offset(0)
    );

    axi_slave_afe axi_slave_afe_i(
        .aclk(clk),
        .aresetn(aresetn),
        .bus(test_mmr),
        .dds_prd(dds_prd),
        .align(aligned)
    );

endmodule : afe_model

`timescale 1 ns / 1 ps

`include "axi4_lite_if.svh"

module axi_slave_afe 
    (
        input  logic          aclk,
        input  logic          aresetn,
        axi4_lite_if.s        bus,
        input  logic [31:0]   dds_prd,
        input  logic [31:0]   align
    );
        
    localparam DW	= 32;
    localparam AW	= 5;
    // AXI4LITE signals
    reg [AW-1 : 0] 	axi_awaddr;
    reg  	axi_awready;
    reg  	axi_wready;
    reg [1 : 0] 	axi_bresp;
    reg  	axi_bvalid;
    reg [AW-1 : 0] 	axi_araddr;
    reg  	axi_arready;
    reg [DW-1 : 0] 	axi_rdata;
    reg [1 : 0] 	axi_rresp;
    reg  	axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit DW
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (DW/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 2;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 4
    reg [DW-1:0]	slv_reg0;
    reg [DW-1:0]	slv_reg1;
    reg [DW-1:0]	slv_reg2;
    reg [DW-1:0]	slv_reg3;
    reg [DW-1:0]	slv_reg4;
    reg [DW-1:0]	slv_reg5;
    reg [DW-1:0]	slv_reg6;
    reg [DW-1:0]	slv_reg7;
    wire	 slv_reg_rden;
    wire	 slv_reg_wren;
    reg [DW-1:0]	 reg_data_out;
    integer	 byte_index;
    reg	 aw_en;

    // I/O Connections assignments

    assign bus.awready	= axi_awready;
    assign bus.wready	= axi_wready;
    assign bus.bresp	= axi_bresp;
    assign bus.bvalid	= axi_bvalid;
    assign bus.arready	= axi_arready;
    assign bus.rdata	= axi_rdata;
    assign bus.rresp	= axi_rresp;
    assign bus.rvalid	= axi_rvalid;
    // Implement axi_awready generation
    // axi_awready is asserted for one aclk clock cycle when both
    // bus.awvalid and bus.wvalid are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_awready <= 1'b0;
            aw_en <= 1'b1;
        end 
        else
        begin    
            if (~axi_awready && bus.awvalid && bus.wvalid && aw_en)
            begin
                // slave is ready to accept write address when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_awready <= 1'b1;
                aw_en <= 1'b0;
            end
            else if (bus.bready && axi_bvalid)
                begin
                    aw_en <= 1'b1;
                    axi_awready <= 1'b0;
                end
            else           
            begin
                axi_awready <= 1'b0;
            end
        end 
    end       

    // Implement axi_awaddr latching
    // This process is used to latch the address when both 
    // bus.awvalid and bus.wvalid are valid. 

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_awaddr <= 0;
        end 
        else
        begin    
            if (~axi_awready && bus.awvalid && bus.wvalid && aw_en)
            begin
                // Write Address latching 
                axi_awaddr <= bus.awaddr;
            end
        end 
    end       

    // Implement axi_wready generation
    // axi_wready is asserted for one aclk clock cycle when both
    // bus.awvalid and bus.wvalid are asserted. axi_wready is 
    // de-asserted when reset is low. 

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_wready <= 1'b0;
        end 
        else
        begin    
            if (~axi_wready && bus.wvalid && bus.awvalid && aw_en )
            begin
                // slave is ready to accept write data when 
                // there is a valid write address and write data
                // on the write address and data bus. This design 
                // expects no outstanding transactions. 
                axi_wready <= 1'b1;
            end
            else
            begin
                axi_wready <= 1'b0;
            end
        end 
    end       

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, bus.wvalid, axi_wready and bus.wvalid are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && bus.wvalid && axi_awready && bus.awvalid;

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end 
        else begin
        if (slv_reg_wren)
            begin
            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                3'h0:
                for ( byte_index = 0; byte_index <= (DW/8)-1; byte_index = byte_index+1 )
                    if ( bus.wstrb[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes 
                    // Slave register 0
                    slv_reg0[(byte_index*8) +: 8] <= bus.wdata[(byte_index*8) +: 8];
                    end  
                3'h1:
                for ( byte_index = 0; byte_index <= (DW/8)-1; byte_index = byte_index+1 )
                    if ( bus.wstrb[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes 
                    // Slave register 1
                    slv_reg1[(byte_index*8) +: 8] <= bus.wdata[(byte_index*8) +: 8];
                    end  
                3'h2:
                for ( byte_index = 0; byte_index <= (DW/8)-1; byte_index = byte_index+1 )
                    if ( bus.wstrb[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes 
                    // Slave register 2
                    slv_reg2[(byte_index*8) +: 8] <= bus.wdata[(byte_index*8) +: 8];
                    end  
                3'h3:
                for ( byte_index = 0; byte_index <= (DW/8)-1; byte_index = byte_index+1 )
                    if ( bus.wstrb[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes 
                    // Slave register 3
                    slv_reg3[(byte_index*8) +: 8] <= bus.wdata[(byte_index*8) +: 8];
                    end  
                3'h4:
                for ( byte_index = 0; byte_index <= (DW/8)-1; byte_index = byte_index+1 )
                    if ( bus.wstrb[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes 
                    // Slave register 3
                    slv_reg4[(byte_index*8) +: 8] <= bus.wdata[(byte_index*8) +: 8];
                    end 
                default : begin
                            slv_reg0 <= dds_prd;
                            slv_reg1 <= align;
                            slv_reg2 <= slv_reg2;
                            slv_reg3 <= slv_reg3;
                            slv_reg4 <= slv_reg4;
                            slv_reg5 <= slv_reg5;
                            slv_reg6 <= slv_reg6;
                            slv_reg7 <= slv_reg7;
                        end
            endcase
            end
        end
    end    

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave 
    // when axi_wready, bus.wvalid, axi_wready and bus.wvalid are asserted.  
    // This marks the acceptance of address and indicates the status of 
    // write transaction.

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_bvalid  <= 0;
            axi_bresp   <= 2'b0;
        end 
        else
        begin    
            if (axi_awready && bus.awvalid && ~axi_bvalid && axi_wready && bus.wvalid)
            begin
                // indicates a valid write response is available
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b0; // 'OKAY' response 
            end                   // work error responses in future
            else
            begin
                if (bus.bready && axi_bvalid) 
                //check if bready is asserted while bvalid is high) 
                //(there is a possibility that bready is always asserted high)   
                begin
                    axi_bvalid <= 1'b0; 
                end  
            end
        end
    end   

    // Implement axi_arready generation
    // axi_arready is asserted for one aclk clock cycle when
    // bus.arvalid is asserted. axi_awready is 
    // de-asserted when reset (active low) is asserted. 
    // The read address is also latched when bus.arvalid is 
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_arready <= 1'b0;
            axi_araddr  <= 32'b0;
        end 
        else
        begin    
            if (~axi_arready && bus.arvalid)
            begin
                // indicates that the slave has acceped the valid read address
                axi_arready <= 1'b1;
                // Read address latching
                axi_araddr  <= bus.araddr;
            end
            else
            begin
                axi_arready <= 1'b0;
            end
        end 
    end       

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one aclk clock cycle when both 
    // bus.arvalid and axi_arready are asserted. The slave registers 
    // data are available on the axi_rdata bus at this instance. The 
    // assertion of axi_rvalid marks the validity of read data on the 
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    // is deasserted on reset (active low). axi_rresp and axi_rdata are 
    // cleared to zero on reset (active low).  
    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_rvalid <= 0;
            axi_rresp  <= 0;
        end 
        else
        begin    
            if (axi_arready && bus.arvalid && ~axi_rvalid)
            begin
                // Valid read data is available at the read data bus
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b0; // 'OKAY' response
            end   
            else if (axi_rvalid && bus.rready)
            begin
                // Read data is accepted by the master
                axi_rvalid <= 1'b0;
            end                
        end
    end    

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & bus.arvalid & ~axi_rvalid;
    always @(*)
    begin
            // Address decoding for reading registers
            case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            3'h0   : reg_data_out <= slv_reg0;
            3'h1   : reg_data_out <= slv_reg1;
            3'h2   : reg_data_out <= slv_reg2;
            3'h3   : reg_data_out <= slv_reg3;
            3'h4   : reg_data_out <= slv_reg4;
            default : reg_data_out <= 'hDEAD;
            endcase
    end

    // Output register or memory read data
    always @( posedge aclk )
    begin
        if ( aresetn == 1'b0 )
        begin
            axi_rdata  <= 0;
        end 
        else
        begin    
            // When there is a valid read address (bus.arvalid) with 
            // acceptance of read address by the slave (axi_arready), 
            // output the read dada 
            if (slv_reg_rden)
            begin
                axi_rdata <= reg_data_out;     // register read data
            end   
        end
    end    

    // Add user logic here
    // User logic ends

endmodule

`endif//__AFE_MODEL_SV__