library verilog;
use verilog.vl_types.all;
entity uart_rx is
    generic(
        VERIFY_ON       : vl_logic := Hi0;
        VERIFY_EVEN     : vl_logic := Hi0
    );
    port(
        clk_i           : in     vl_logic;
        resetn_i        : in     vl_logic;
        uart_rx_i       : in     vl_logic;
        dataout_valid_o : out    vl_logic;
        dataout_o       : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of VERIFY_ON : constant is 1;
    attribute mti_svvh_generic_type of VERIFY_EVEN : constant is 1;
end uart_rx;
