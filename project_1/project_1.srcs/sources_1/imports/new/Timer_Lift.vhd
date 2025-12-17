library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Timer_Lift is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        tick_clk : out std_logic
    );
end Timer_Lift;

architecture Behavioral of Timer_Lift is -- Este timer ira asociado al funcionamiento de las plantas en FSM (tick_mover)

    constant LIMIT : unsigned(31 downto 0) := to_unsigned(350000000, 32); --Dos segundos cada tick
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

