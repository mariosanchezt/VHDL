library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY top IS
    PORT ( 
        pushbutton : IN std_logic;
        CLK : IN std_logic;
        RESET : IN std_logic;
        Light : OUT std_logic_vector (0 to 5)--5
    );
END top;

architecture BEHAVIORAL of top is
    signal sync_o: std_logic;
    signal juan: std_logic;
    
    COMPONENT SYNCHRNZR
        PORT (
            async_in : IN std_logic;
            CLK: IN std_logic;
            sync_out: out std_logic
        );
    END COMPONENT;
    COMPONENT EDGEDTCTR
        PORT (
            sync_in : IN std_logic;
            CLK: IN std_logic;
            edge: out std_logic
        );
    END COMPONENT;
    COMPONENT FMS
        PORT (
            pushbutton: IN std_logic;
            CLK: IN std_logic;
            reset: in std_logic;
            light: out std_logic_vector (0 to 5) --5

        );
    END COMPONENT;
begin
    inst_SYNCHRNZR: SYNCHRNZR PORT MAP (
        async_in => pushbutton,
        CLK => CLK,
        sync_out => sync_o
    );
    inst_EDGEDTCTR: EDGEDTCTR PORT MAP (
         sync_in => sync_o,
         CLK => CLK,
         edge => juan
    );
    inst_FMS: FMS PORT MAP (
         pushbutton => juan,
         CLK => CLK,
         reset => RESET,
         light => LIGHT
    );
end BEHAVIORAL;