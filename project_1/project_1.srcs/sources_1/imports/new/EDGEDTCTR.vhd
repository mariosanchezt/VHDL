library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity EDGEDTCTR is
    port (
        CLK     : in std_logic;
        rst_n     : in std_logic; -- NUEVO PUERTO
        SYNC_IN : in std_logic;
        EDGE    : out std_logic
    );
end EDGEDTCTR;

architecture BEHAVIORAL of EDGEDTCTR is
    signal sreg : std_logic_vector(2 downto 0); --  3 bits
begin
    process (CLK, rst_n)
    begin
        if rst_n = '0' then
            sreg <= "000"; -- Limpieza inmediata
        elsif rising_edge(CLK) then
            sreg <= sreg(1 downto 0) & SYNC_IN;
        end if;
    end process;

    with sreg select
        EDGE <= '1' when "100",
                '0' when others;
end BEHAVIORAL;