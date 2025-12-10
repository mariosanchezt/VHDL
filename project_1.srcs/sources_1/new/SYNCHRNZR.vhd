library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity SYNCHRNZR is
    port (
        CLK      : in std_logic;
        rst_n      : in std_logic; -- NUEVO PUERTO
        ASYNC_IN : in std_logic;
        SYNC_OUT : out std_logic
    );
end SYNCHRNZR;

architecture Behavioral of SYNCHRNZR is
    signal sreg : std_logic_vector(1 downto 0);
begin
    process (CLK, rst_n) -- Añadimos rst_n a la lista de sensibilidad
    begin
        if rst_n = '0' then
            sreg <= "00";      -- Limpieza inmediata
            sync_out <= '0';
        elsif rising_edge(CLK) then
            sync_out <= sreg(1);
            sreg <= sreg(0) & async_in;
        end if;
    end process;
end Behavioral;