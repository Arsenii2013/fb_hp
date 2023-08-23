else if(testname == "pio_writeReadBack_test0")
begin

    // This test performs a 32 bit write to a 32 bit Memory space and performs a read back

    topTB.RP.tx_usrapp.TSK_SIMULATION_TIMEOUT(10050);

    topTB.RP.tx_usrapp.TSK_SYSTEM_INITIALIZATION;

    topTB.RP.tx_usrapp.TSK_BAR_INIT;

//--------------------------------------------------------------------------
// Event : Testing BARs
//--------------------------------------------------------------------------
    pci_e_write(0, 'h0, 'hDEAD);
    pci_e_read(0, 'h0, recv_data);
    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    if (!test_failed_flag) begin 
        $display ("Test Completed Successfully");
    end 
    $finish;
end
