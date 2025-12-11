library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Visualizador is
    Port ( 
        -- ENTRADAS (Vienen del Controlador FSM)
        piso_actual    : in  STD_LOGIC_VECTOR (1 downto 0);
        piso_target    : in  STD_LOGIC_VECTOR (1 downto 0);
        motor_status   : in  STD_LOGIC_VECTOR (1 downto 0);
        puerta_abierta : in  STD_LOGIC;
        
        -- SALIDAS FÍSICAS
        seg            : out STD_LOGIC_VECTOR (6 downto 0);
        an             : out STD_LOGIC_VECTOR (7 downto 0);
        leds_piso      : out STD_LOGIC_VECTOR (3 downto 0);
        leds_motor     : out STD_LOGIC_VECTOR (1 downto 0);
        led_puerta     : out STD_LOGIC
    );
end Visualizador;

architecture Structural of Visualizador is

    -- Declaramos los componentes 
    component decoder
        Port ( code : in STD_LOGIC_VECTOR (3 downto 0);
               led  : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    component Control_Leds
        Port ( piso_actual : in STD_LOGIC_VECTOR (1 downto 0);
               piso_target : in STD_LOGIC_VECTOR (1 downto 0);
               leds_out    : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Señal auxiliar para conectar el piso (2 bits) al decoder (4 bits)
    signal code_para_decoder : std_logic_vector(3 downto 0);

begin

    -- Preparamos el dato para el decoder
    code_para_decoder <= "00" & piso_actual;

    -- DECODIFICADOR 7 SEGMENTOS
    Inst_Decoder: decoder
    port map (
        code => code_para_decoder,
        led  => seg
    );

    -- CONTROLADOR DE LEDS TARGET
    Inst_Leds: Control_Leds
    port map (
        piso_actual => piso_actual,
        piso_target => piso_target,
        leds_out    => leds_piso
    );

    -- CONEXIONES DIRECTAS (Cables que vienen de fuera del bloque)
    an         <= "11111110";   -- Encender solo el display derecho
    leds_motor <= motor_status; -- Cable directo desde la FSM
    led_puerta <= puerta_abierta;

end Structural;
