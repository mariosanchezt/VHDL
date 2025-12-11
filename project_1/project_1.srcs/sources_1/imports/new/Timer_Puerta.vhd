library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Timer_Puerta is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        tick_clk : out std_logic
    );
end Timer_Puerta;

architecture Behavioral of Timer_Puerta is -- Este timer ira asociado al funcionamiento de la puerta en FSM (fin_timer)

    constant LIMIT : unsigned(31 downto 0) := to_unsigned(250000000, 32); --Dos segundos y medio cada tick
    signal counter : unsigned(31 downto 0) := (others => '0');

begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            counter  <= (others => '0');
            tick_clk <= '0';

        elsif rising_edge(clk) then

            if counter = LIMIT then
                tick_clk <= '1';         -- pulso de un ciclo
                counter  <= (others => '0');

            else
                tick_clk <= '0';
                counter  <= counter + 1;

            end if;

        end if;
    end process;

end Behavioral;

