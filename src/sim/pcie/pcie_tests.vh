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
    pci_e_write(0, 'h0, 'h0000DEAD);
    pci_e_write(2, 'h0, 'h0000BEEF);
    pci_e_read(0, 'h0, recv_data);
    pci_e_read(2, 'h0, recv_data);

    pci_e_write(1, 'h0, 'h0000DEAD);
    pci_e_write(1, 'h4, 'h0000BEEF);
    pci_e_read(1, 'h0, recv_data);
    pci_e_read(1, 'h4, recv_data);
    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    if (!test_failed_flag) begin 
        $display ("Test Completed Successfully");
    end 
    $finish;
end
