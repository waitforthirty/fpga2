library verilog;
use verilog.vl_types.all;
entity uart_tx is
    generic(
        TXIdle          : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        TXLoad          : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        TXStartBit      : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        TXDataBit       : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        TXParity_check_EVEN: vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0);
        TXParity_check_ODD: vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi1);
        TXStopBit       : vl_logic_vector(0 to 5) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0);
        TXDone          : vl_logic_vector(0 to 5) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        clk_i           : in     vl_logic;
        resetn_i        : in     vl_logic;
        clk_en_i        : in     vl_logic;
        Ctrl            : in     vl_logic_vector(2 downto 0);
        datain_i        : in     vl_logic_vector(7 downto 0);
        uart_tx_o       : out    vl_logic;
        uart_busy_o     : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TXIdle : constant is 1;
    attribute mti_svvh_generic_type of TXLoad : constant is 1;
    attribute mti_svvh_generic_type of TXStartBit : constant is 1;
    attribute mti_svvh_generic_type of TXDataBit : constant is 1;
    attribute mti_svvh_generic_type of TXParity_check_EVEN : constant is 1;
    attribute mti_svvh_generic_type of TXParity_check_ODD : constant is 1;
    attribute mti_svvh_generic_type of TXStopBit : constant is 1;
    attribute mti_svvh_generic_type of TXDone : constant is 1;
end uart_tx;
