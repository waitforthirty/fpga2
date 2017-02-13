library verilog;
use verilog.vl_types.all;
entity myuart_reg is
    generic(
        IDLE            : integer := 0;
        SET             : integer := 1;
        pWriteEN        : integer := 2;
        pReadEN         : integer := 3
    );
    port(
        pclk            : in     vl_logic;
        presetn         : in     vl_logic;
        psel            : in     vl_logic;
        pwrite          : in     vl_logic;
        penable         : in     vl_logic;
        paddr           : in     vl_logic_vector(5 downto 0);
        pwdata          : in     vl_logic_vector(31 downto 0);
        prdata          : out    vl_logic_vector(31 downto 0);
        interrupt       : out    vl_logic;
        pready          : out    vl_logic;
        tx_shoot        : out    vl_logic;
        datatx          : out    vl_logic_vector(7 downto 0);
        Ctrl_reg        : out    vl_logic_vector(2 downto 0);
        datarx          : in     vl_logic_vector(7 downto 0);
        ready_rx        : in     vl_logic;
        busy_tx         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of SET : constant is 1;
    attribute mti_svvh_generic_type of pWriteEN : constant is 1;
    attribute mti_svvh_generic_type of pReadEN : constant is 1;
end myuart_reg;
