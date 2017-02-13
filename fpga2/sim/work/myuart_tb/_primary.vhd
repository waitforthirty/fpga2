library verilog;
use verilog.vl_types.all;
entity myuart_tb is
    generic(
        DIVISOR_TX      : vl_logic_vector(0 to 9) := (Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0);
        DIVISOR_RX      : vl_logic_vector(0 to 9) := (Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DIVISOR_TX : constant is 1;
    attribute mti_svvh_generic_type of DIVISOR_RX : constant is 1;
end myuart_tb;
