library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Visualizador is
    Port ( 
        CLK            : in  STD_LOGIC; 
        piso_actual    : in  STD_LOGIC_VECTOR (1 downto 0);
        piso_target    : in  STD_LOGIC_VECTOR (1 downto 0);
        motor_status   : in  STD_LOGIC_VECTOR (1 downto 0);
        puerta_abierta : in  STD_LOGIC;
        rst_n          : in  STD_LOGIC;
        -- Salidas físicas
        seg            : out STD_LOGIC_VECTOR (6 downto 0);
        an             : out STD_LOGIC_VECTOR (7 downto 0);
        leds_piso      : out STD_LOGIC_VECTOR (3 downto 0);
        leds_motor     : out STD_LOGIC_VECTOR (1 downto 0);
        led_puerta     : out STD_LOGIC
    );
end Visualizador;

architecture Behavioral of Visualizador is

    component decoder
        Port ( code : in STD_LOGIC_VECTOR (3 downto 0);
               led  : out STD_LOGIC_VECTOR (6 downto 0));
    end component;


    component Control_Leds
        Port ( piso_actual : in STD_LOGIC_VECTOR (1 downto 0);
               piso_target : in STD_LOGIC_VECTOR (1 downto 0);
               leds_out    : out STD_LOGIC_VECTOR (3 downto 0));
    end component;


    -- Contador para dividir el reloj (de 100MHz a aprox 1kHz)
    -- 100,000 ciclos = 1ms por dígito
    constant LIMIT_REFRESH : unsigned(16 downto 0) := to_unsigned(100000, 17);
    signal refresh_counter : unsigned(16 downto 0) := (others => '0');
    
    signal anode_select    : integer range 0 to 7 := 0; 
    
-- Duración total de la animación (ej. 2 segundos a 100MHz = 200.000.000)
    constant ANIM_DURATION : unsigned(27 downto 0) := to_unsigned(200000000, 28);

-- Velocidad de giro (Cada cuánto cambia de palito a->b->c)
    -- Ej: 100ms = 10.000.000 ciclos.
    constant ANIM_SPEED    : unsigned(27 downto 0) := to_unsigned(10000000, 28);
    
    -- Señales para segmentos
    signal code_numero     : std_logic_vector(3 downto 0);
    signal seg_numero      : std_logic_vector(6 downto 0); -- Salida del decoder
    signal seg_final       : std_logic_vector(6 downto 0);

    signal anim_counter    : unsigned(27 downto 0) := (others => '0');
    signal anim_active     : std_logic := '1'; -- Empieza activa al arrancar
    signal seg_animacion   : std_logic_vector(6 downto 0); -- Los palitos girando

    -- 'P': a,b,e,f,g ON -> "0011000"
    -- '-': g ON        -> "1111110" 
    constant CHAR_P     : std_logic_vector(6 downto 0) := "0011000";
    constant CHAR_DASH  : std_logic_vector(6 downto 0) := "1111110";

begin    
    -- Preparamos entrada para el decoder (Piso actual)
    code_numero <= "00" & piso_actual;

    Inst_Decoder: decoder
    port map (
        code => code_numero,
        led  => seg_numero
    );

    Inst_Leds: Control_Leds
    port map (
        piso_actual => piso_actual,
        piso_target => piso_target,
        leds_out    => leds_piso
    );

    -- Multiplexación

    process(CLK,rst_n)
    begin
   if rst_n = '0' then
            anim_counter    <= (others => '0');
            anim_active     <= '1'; -- Activamos modo animación
            refresh_counter <= (others => '0');
            anode_select    <= 0;
            
        elsif rising_edge(CLK) then
            
            -- CONTROL DE LA ANIMACIÓN
            if anim_counter < ANIM_DURATION then
                anim_active <= '1';
                anim_counter <= anim_counter + 1;
            else
                anim_active <= '0'; 
                -- Se queda aquí hasta el próximo reset
            end if;

            --BARRIDO DE DISPLAYS
            if refresh_counter = LIMIT_REFRESH then
                refresh_counter <= (others => '0');
                if anode_select = 7 then
                    anode_select <= 0;
                else
                    anode_select <= anode_select + 1;
                end if;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
            
        end if;
    end process;
    
    --GENERADOR DEL PATRÓN GIRATORIO
    process(anim_counter)
        variable fase : integer;
    begin
        -- Velocidad del giro
        fase := (to_integer(anim_counter) / 10000000) mod 6;
        
        case fase is
            when 0 => seg_animacion <= "0111111"; -- a
            when 1 => seg_animacion <= "1011111"; -- b
            when 2 => seg_animacion <= "1101111"; -- c
            when 3 => seg_animacion <= "1110111"; -- d
            when 4 => seg_animacion <= "1111011"; -- e
            when 5 => seg_animacion <= "1111101"; -- f
            when others => seg_animacion <= "1111111";
        end case;
    end process;

    -- SELECTOR FINAL

    process(anode_select, seg_numero, anim_active, seg_animacion)
    begin
        an <= (others => '1'); 
        
        if anim_active = '1' then
            --Giro en todos los displays
            an(anode_select) <= '0'; 
            seg_final <= seg_animacion; 
        else
            --P, Numero y Guiones
            case anode_select is
                when 3 => -- 'P'
                    an(4) <= '0';     
                    seg_final <= CHAR_P; 
                when 4 => -- Número Planta
                    an(3) <= '0';     
                    seg_final <= seg_numero; 
                when others => -- Guiones
                    an(anode_select) <= '0'; 
                    seg_final <= CHAR_DASH; 
            end case;
        end if;
    end process;

    seg <= seg_final;
    leds_motor <= motor_status;
    led_puerta <= puerta_abierta;

end Behavioral;