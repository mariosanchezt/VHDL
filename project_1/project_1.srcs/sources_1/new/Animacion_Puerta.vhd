library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Animacion_Puerta is
    Port ( 
        CLK        : in  STD_LOGIC;
        rst_n      : in  STD_LOGIC;
        aviso_cerrar : in STD_LOGIC; 
        aviso_abrir  : in STD_LOGIC; 
        
        leds_out   : out STD_LOGIC_VECTOR(15 downto 0); 
        anim_activada: out STD_LOGIC; 
        anim_fin  : out STD_LOGIC 
    );
end Animacion_Puerta;

architecture Behavioral of Animacion_Puerta is

    -- Velocidad de la animación
    constant limite_vel : unsigned(23 downto 0) := to_unsigned(10000000, 24); 
    signal contador_veloc : unsigned(23 downto 0) := (others => '0');

    signal salto : integer range 0 to 9 := 0; 
    
    -- Nueva máquina de estados para la animación
    type t_estado is (IDLE, CERRANDO, ABRIENDO, FIN, ESPERA_SOLTAR);
    signal estado : t_estado := IDLE;

begin

    process(CLK, rst_n)
    begin
        if rst_n = '0' then
            estado <= IDLE;
            salto <= 0;
            contador_veloc <= (others => '0');
            anim_fin <= '0';
            anim_activada <= '0';
            leds_out <= (others => '0');

        elsif rising_edge(CLK) then
            
            -- Iniciamos a 0
            anim_fin <= '0';
            
            case estado is
                when IDLE =>
                    anim_activada <= '0';
                    leds_out <= (others => '0');
                    salto <= 0;
                    contador_veloc <= (others => '0');
                    
                    if aviso_cerrar = '1' then
                        estado <= CERRANDO;
                        anim_activada <= '1';
                    elsif aviso_abrir = '1' then
                        estado <= ABRIENDO;
                        anim_activada <= '1';
                        salto <= 8; 
                    end if;

                when CERRANDO => 
                    anim_activada <= '1';
                    -- Velocidad
                    if contador_veloc = limite_vel then
                        contador_veloc <= (others => '0');
                        if salto = 8 then
                            estado <= FIN; 
                        else
                            salto <= salto + 1;
                        end if;
                    else
                        contador_veloc <= contador_veloc + 1;
                    end if;
                    
                    -- Patrón Cierre
                    leds_out <= (others => '0');
                    for i in 1 to 8 loop
                        if salto >= i then
                            leds_out(15 - (i-1)) <= '1'; 
                            leds_out(0 + (i-1))  <= '1'; 
                        end if;
                    end loop;

                when ABRIENDO => 
                    anim_activada <= '1';
                    if contador_veloc = limite_vel then
                        contador_veloc <= (others => '0');
                        if salto = 0 then
                            estado <= FIN;
                        else
                            salto <= salto - 1;
                        end if;
                    else
                        contador_veloc <= contador_veloc + 1;
                    end if;

                    -- Patrón Apertura
                    leds_out <= (others => '0');
                    for i in 1 to 8 loop
                        if salto >= i then
                            leds_out(15 - (i-1)) <= '1';
                            leds_out(0 + (i-1))  <= '1';
                        end if;
                    end loop;

                when FIN =>
                    anim_fin <= '1'; -- Avisamos a la FSM
                    -- No vamos a IDLE todavía, vamos a seguridad
                    estado <= ESPERA_SOLTAR;

                when ESPERA_SOLTAR =>
                    anim_fin <= '0';
                    anim_activada <= '0'; -- Devolvemos el control al visualizador normal
                    
                    -- Solo volvemos a IDLE cuando el controlador haya quitado la orden
                    if aviso_cerrar = '0' and aviso_abrir = '0' then
                        estado <= IDLE;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;