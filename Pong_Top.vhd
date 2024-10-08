entity Pong_Top is
    port (
        --25MHz Clock
        i_Clk   : in std_logic;
        --switch initialization
        i_Switch_1 : in std_logic;
        i_Switch_2 : in std_logic;
        i_Switch_3 : in std_logic;
        i_Switch_4 : in std_logic;

        --UART initialization
        i_UART_RX : in std_logic;

        --VGA initialization
        o_VGA_HSync : out std_logic;
        o_VGA_VSync : out std_logic;
        o_VGA_Red_0 : out std_logic;
        o_VGA_Red_1 : out std_logic;
        o_VGA_Red_2 : out std_logic;
        o_VGA_Grn_0 : out std_logic;
        o_VGA_Grn_1 : out std_logic;
        o_VGA_Grn_2 : out std_logic;
        o_VGA_Blu_0 : out std_logic;
        o_VGA_Blu_1 : out std_logic;
        o_VGA_Blu_2 : out std_logic
    );
end entity;

architecture rtl of Pong_Top is

    --Constats for frame size of VGA display
    constant c_Vid_Width : integer:= 3;
    constant c_Col_Total: integer := 800;
    constant c_Row_Total : integer := 525;
    constant c_Col_Active : integer := 640;
    constant c_Row_Active : integer := 480;

    --VGA signals
    signal w_Red_Video_Porch : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_Green_Video_Porch : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_Blue_Video_Porch : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_HSync_VGA : std_logic;
    signal w_VSync_VGA : std_logic;

    --UART
    signal w_RX_DV : std_logic;

    --switches 
    signal w_Switch_1 : std_logic;
    signal w_Switch_2 : std_logic;
    signal w_Switch_3 : std_logic;
    signal w_Switch_4 : std_logic;

    --Pong Signals
    signal w_Red_Video_Pong : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_Green_Video_Pong : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_Blue_Video_Pong : std_logic_vector(c_Vid_Width-1 downto 0);
    signal w_HSync_Pong : std_logic;
    signal w_VSync_Pong : std_logic;

begin
    --Switch Debounce
    -- Instantiate Debounce Switches
    Debounce1_Inst : entity work.Debounce_Switch
        port map (
            i_Clk => i_Clk,
            i_Switch => i_Switch_1,
            o_Switch => w_Switch_1
        );

    Debounce2_Inst : entity work.Debounce_Switch
        port map (
            i_Clk => i_Clk,
            i_Switch => i_Switch_2,
            o_Switch => w_Switch_2
        );

    Debounce3_Inst : entity work.Debounce_Switch
        port map (
            i_Clk => i_Clk,
            i_Switch => i_Switch_3,
            o_Switch => w_Switch_3
        );

    Debounce4_Inst : entity work.Debounce_Switch
        port map (
            i_Clk => i_Clk,
            i_Switch => i_Switch_4,
            o_Switch => w_Switch_4
        );

    --UART Instantiation
    UART_RX_Inst : entity work.UART_RX
        generic map (
            g_CLKS_PER_BIT => 217;
        )
        port map (
            i_Clk => i_Clk,  
            i_RX_Serial => i_UART_RX,
            o_RX_DV => w_RX_DV,
            o_RX_Byte => open
        );

    --VGA
    VGA_Sync_Pulses_inst : entity work.VGA_Sync_Pulses
        generic map(
            g_TOTAL_COLS => c_Col_Total,
            g_TOTAL_ROWS => c_Row_Total,
            g_ACTIVE_COLS => c_Col_Active,
            g_ACTIVE_ROWS => c_Row_Active
        );
        port map (
            i_Clk       => i_Clk,
            o_HSync     => w_HSync_VGA,
            o_VSync     => w_VSync_VGA,
            o_Col_Count => open,
            o_Row_Count => open
        );

    Pong_Draw_inst : entity work.Pong_Draw
        generic map (
            g_Vid_Width => c_Vid_Width,
            g_Col_Tot => c_Col_Total,
            g_Row_Tot => c_Row_Total,
            g_Rows_Active => c_Row_Active,
            g_Cols_Active => c_Col_Active
        )
        port map (
            i_Clk => i_Clk,
            i_HSync => w_HSync_VGA,
            i_VSync => w_VSync_VGA,
            i_start => w_RX_DV,--starts when UART recieves an input
            --player movement
            i_P1_Up => w_Switch_1,
            i_P1_Down => w_Switch_2,
            i_P2_Up => w_Switch_3,
            i_P2_Down => w_Switch_4,
            --output for VGA 
            o_HSync => w_HSync_Pong,
            o_VSync => w_VSync_Pong,
            o_Red_Video => w_Red_Video_Pong
            o_Blu_Video => w_Blu_Video_Pong,
            o_Grn_Video => w_Grn_Video_Pong
        );
    
        VGA_Sync_Porch_inst : entity work.VGA_Sync_Porch
        generic map (
            g_Vid_Width => c_Vid_Width,
            g_Col_Tot => c_Col_Total,
            g_Row_Tot => c_Row_Total,
            g_Rows_Active => c_Row_Active,
            g_Cols_Active => c_Col_Active
        )
        port map(
            i_Clk => i_Clk,
            i_HSync => w_HSync_Pong,
            i_VSync => w_VSync_Pong,
            i_Red_Video => w_Red_Video_Pong,
            i_Grn_Video => w_Blu_Video_Pong,
            i_Blu_Video => w_Grn_Video_Pong,

            o_HSync => o_VGA_HSync,
            o_VSync => o_VGA_VSync,
            o_Red_Video => w_Red_Video_Porch,
            o_Grn_Video => w_Blu_Video_Porch,
            o_Blu_Video => w_Grn_Video_Porch
        );

    o_VGA_Red_0 <= w_Red_Video_Porch(0);
    o_VGA_Red_1 <= w_Red_Video_Porch(1);
    o_VGA_Red_2 <= w_Red_Video_Porch(2);
        
    o_VGA_Grn_0 <= w_Grn_Video_Porch(0);
    o_VGA_Grn_1 <= w_Grn_Video_Porch(1);
    o_VGA_Grn_2 <= w_Grn_Video_Porch(2);
    
    o_VGA_Blu_0 <= w_Blu_Video_Porch(0);
    o_VGA_Blu_1 <= w_Blu_Video_Porch(1);
    o_VGA_Blu_2 <= w_Blu_Video_Porch(2);

    


    
    
    
    

end architecture;