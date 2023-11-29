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
    pci_e_write(1, 'h0, 'h0000DEAD); // MMR_SYS
    pci_e_read (1, 'h0, recv_data);

    pci_e_write(1, 'h400C, 'h00000100); // MMR_MEM offset 100 byte
    pci_e_write(2, 'h0, 'h0000BEEF);    // HP0

    pci_e_write(1, 'h400C, 'h00000000); // MMR_MEM offset 0 byte
    pci_e_read (2, 'h100, recv_data);   // HP0

    // QSPI read write test
    pci_e_write(1, 'h6000, 'h0000DEAD);
    pci_e_write(1, 'h6004, 'h0000BEEF);
    pci_e_read (1, 'h6000, recv_data);
    pci_e_read (1, 'h6004, recv_data);

    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    if (!test_failed_flag) begin 
        $display ("Test Completed Successfully");
    end 
    $finish;
end
