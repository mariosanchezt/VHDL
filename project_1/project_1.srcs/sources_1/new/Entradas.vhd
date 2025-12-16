library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Entradas is
    Port ( 
        CLK       : in  STD_LOGIC;
        rst_n       : in  STD_LOGIC; -- Reset Global
        entrada   : in  STD_LOGIC_VECTOR(3 downto 0);
        button_in : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Entradas;

architecture Behavioral of Entradas is

  
    component SYNCHRNZR
        port (
            CLK      : in std_logic;
            rst_n      : in std_logic; 
            ASYNC_IN : in std_logic;
            SYNC_OUT : out std_logic
        );
    end component;

    component EDGEDTCTR
        port (
            CLK     : in std_logic;
            rst_n     : in std_logic; 
            SYNC_IN : in std_logic;
            EDGE    : out std_logic
        );
    end component;

    signal s_sync_mid : std_logic_vector(3 downto 0);

begin

    Gen_Entradas: for i in 0 to 3 generate
    begin
        
        Inst_Sincronizador: SYNCHRNZR
        port map (
            CLK      => CLK,
            rst_n      => rst_n,          -- Conectamos el Reset
            ASYNC_IN => entrada(i),
            SYNC_OUT => s_sync_mid(i)
        );

        Inst_Detector: EDGEDTCTR
        port map (
            CLK     => CLK,
            rst_n     => rst_n,           -- Conectamos el Reset
            SYNC_IN => s_sync_mid(i),
            EDGE    => button_in(i)
        );
        
    end generate Gen_Entradas;

end Behavioral;