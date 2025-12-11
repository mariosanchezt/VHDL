library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Leds is
    Port ( 
        piso_actual : in  STD_LOGIC_VECTOR (1 downto 0);
        piso_target : in  STD_LOGIC_VECTOR (1 downto 0);
        leds_out    : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Control_Leds;

architecture Behavioral of Control_Leds is
begin
    process(piso_target, piso_actual)
    begin
        -- Si hemos llegado al destino, apagamos todo
        if piso_target = piso_actual then
            leds_out <= "0000";
        else
            -- Si estamos viajando, encendemos el LED del objetivo
            case piso_target is
                when "00" => leds_out <= "0001";
                when "01" => leds_out <= "0010";
                when "10" => leds_out <= "0100";
                when "11" => leds_out <= "1000";
                when others => leds_out <= "0000";
            end case;
        end if;
    end process;
end Behavioral;
