
@(posedge rx_reset_done);
receive(16'h1234, 2'b00);
@(posedge rx_clk);
receive(16'h4567, 2'b00);
@(posedge rx_clk);
receive(16'hDEAD, 2'b00);
@(posedge rx_clk);
receive(16'hBCBC, 2'b11);
forever begin
    @(posedge rx_clk);
    @(posedge rx_clk);
    @(posedge rx_clk);
    @(posedge rx_clk);
    receive(16'hBCBC, 2'b11);
end