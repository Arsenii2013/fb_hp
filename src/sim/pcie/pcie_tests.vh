else if(testname == "pio_writeReadBack_test0")
begin
    //integer recv_data;  


    `ifdef PCIE_PIPE_STACK
    topTB.RP.tx_usrapp.TSK_SIMULATION_TIMEOUT(10050);
    topTB.RP.tx_usrapp.TSK_SYSTEM_INITIALIZATION;
    topTB.RP.tx_usrapp.TSK_BAR_INIT;
    `endif //PCIE_PIPE_STACK

//--------------------------------------------------------------------------
// Event : Testing BARs
//--------------------------------------------------------------------------
    pci_e_write(0, 'h0, 'h0000DEAD); // MMR_SYS
    pci_e_read (0, 'h0, recv_data);

    pci_e_write(0, 'h1410, 'h00000100); // MMR_MEM offset 100 byte
    pci_e_read (0, 'h1410, recv_data);
    //pci_e_write(2, 'h0, 'h0000BEEF);    // HP0

    pci_e_write(0, 'h1410, 'h00000000); // MMR_MEM offset 0 byte
    //pci_e_read (2, 'h100, recv_data);   // HP0

    // bar 1 test

    //pci_e_write(1, 'h0, 'hbeef); 
    //pci_e_read (1, 'h0, recv_data); 
    //pci_e_read (1, 'h7FC, recv_data); 

    //pci_e_write(1, 'h7FC, 'hdeadbeef); 
    //pci_e_read (1, 'h7FC, recv_data); 

    // EVR
    pci_e_write(0, 'hC04, 'h01); // DC enable
    #10000;
    pci_e_read (0, 'hC14, recv_data); 
    $display ("EVR link delay %x", recv_data);

    if(topTB.DUT.evr_i.parser_delay != '0)
        pci_e_write(0, 32'hC18, topTB.DUT.evr_i.parser_delay + 32'h00080500); //  tgt delay = 8 clock cycles + 195 ps
    else begin
        $display ("EVR hasn't gotten a delay yet!");
    end

    // SCC

    pci_e_read(0, 32'h400, recv_data); // check cdr_locked
    pci_e_write(0, 32'h410, 32'h15); // write sync_ev
    pci_e_write(0, 32'h414, 32'd10); // write sync_prd
    pci_e_write(0, 32'h418, 32'h15); // write align_ev
    pci_e_write(0, 32'h41c, 32'h15); // write test0_ev


    // TX start        
    pci_e_read(0, 32'h2000, recv_data); 
    //start
    pci_e_write(0, 32'h2014, 32'h15C); 
    pci_e_write(0, 32'h2014, 32'h000); 
    //addr
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h002);
    //cnt 
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h000); 
    pci_e_write(0, 32'h2014, 32'h004);
    //data
    pci_e_write(0, 32'h2014, 32'h0DE); 
    pci_e_write(0, 32'h2014, 32'h0AD); 
    pci_e_write(0, 32'h2014, 32'h0BE); 
    pci_e_write(0, 32'h2014, 32'h0EF); 
    //stop
    pci_e_write(0, 32'h2014, 32'h13C); 
    pci_e_write(0, 32'h2014, 32'h0FC); 
    pci_e_write(0, 32'h2014, 32'h0C7); 

    pci_e_read(0, 32'h2000, recv_data); 
    pci_e_write(0, 32'h2004, 32'b1); 
    pci_e_read(0, 32'h2000, recv_data); 
    #300;
    pci_e_read(0, 32'h2000, recv_data); 
    pci_e_write(0, 32'h2004, 32'b1); 


    // QSPI read write test
    pci_e_write(0, 'h1800, 'h0000DEAD);
    pci_e_write(0, 'h1804, 'h0000BEEF);
    pci_e_read (0, 'h1800, recv_data);
    pci_e_read (0, 'h1804, recv_data);

    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    if (!test_failed_flag) begin 
        $display ("Test Completed Successfully");
    end 
    $finish;
end
