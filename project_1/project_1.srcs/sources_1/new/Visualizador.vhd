library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Visualizador is
    Port ( 
        CLK            : in  STD_LOGIC;
        rst_n          : in  STD_LOGIC;
        piso_actual    : in  STD_LOGIC_VECTOR (1 downto 0);
        piso_target    : in  STD_LOGIC_VECTOR (1 downto 0);
        motor_status   : in  STD_LOGIC_VECTOR (1 downto 0);
        puerta_abierta : in  STD_LOGIC;
        
        --ENTRADAS PARA LA ANIMACIÓN
        leds_anim      : in  STD_LOGIC_VECTOR (15 downto 0); 
        anim_activada    : in  STD_LOGIC;                      

        -- Salidas físicas
        seg            : out STD_LOGIC_VECTOR (6 downto 0);
        an             : out STD_LOGIC_VECTOR (7 downto 0);
        LED_FINAL      : out STD_LOGIC_VECTOR (15 downto 0) 
    );
end Visualizador;

architecture Behavioral of Visualizador is

    component decoder
        Port ( 
        code : in STD_LOGIC_VECTOR(3 downto 0); 
        led : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
    
    component Control_Leds
        Port ( 
        piso_actual : in STD_LOGIC_VECTOR(1 downto 0); 
        piso_target : in STD_LOGIC_VECTOR(1 downto 0); 
        leds_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Señales internas 
    constant LIMITE_BARRIDO : unsigned(16 downto 0) := to_unsigned(100000, 17); --1 milisegundo para que no sea perceptible a la vista
    constant DURACION_ANIM : unsigned(27 downto 0) := to_unsigned(200000000, 28); --2 secs
    signal contador_barrido : unsigned(16 downto 0) := (others => '0');
    signal contador_anim    : unsigned(27 downto 0) := (others => '0');
    signal anim_reset_activado : std_logic := '1'; -- Animación de RESET
    signal seleccion_anodo    : integer range 0 to 7 := 0; 

    -- Señales de datos normales
    signal leds_piso_normal : std_logic_vector(3 downto 0);
    signal seg_numero, seg_final, seg_animacion : std_logic_vector(6 downto 0);
    constant CHAR_P : std_logic_vector(6 downto 0) := "0011000";
    constant CHAR_DASH : std_logic_vector(6 downto 0) := "1111110";

begin
    -- Instancias
    Inst_Decoder: decoder port map ("00" & piso_actual, seg_numero);
    Inst_Leds: Control_Leds port map (piso_actual, piso_target, leds_piso_normal);

    -- PROCESO DE BARRIDO Y ANIMACIÓN DE RESET
    process(CLK, rst_n)
    begin
        if rst_n = '0' then
            contador_anim <= (others => '0');
            anim_reset_activado <= '1';
        elsif rising_edge(CLK) then
            -- Timer Reset
            if contador_anim < DURACION_ANIM then
                anim_reset_activado <= '1';
                contador_anim <= contador_anim + 1;
            else
                anim_reset_activado <= '0';
            end if;
            -- Barrido display
            if contador_barrido = LIMITE_BARRIDO then
                 contador_barrido <= (others => '0');
                 if seleccion_anodo = 7 then 
                 seleccion_anodo <= 0; 
                 else seleccion_anodo <= seleccion_anodo + 1; 
                 end if;
            else contador_barrido <= contador_barrido + 1; 
            end if;
        end if;
    end process;

    -- PATRÓN GIRO
    process(contador_anim)
        variable fase : integer;
    begin
        fase := (to_integer(contador_anim) / 10000000) mod 6;
        case fase is
            when 0 => seg_animacion <= "0111111"; 
            when 1 => seg_animacion <= "1011111"; 
            when 2 => seg_animacion <= "1101111"; 
            when 3 => seg_animacion <= "1110111"; 
            when 4 => seg_animacion <= "1111011"; 
            when 5 => seg_animacion <= "1111101"; 
            when others => seg_animacion <= "1111111";
        end case;
    end process;

    -- MUX FINAL
    
    -- DISPLAYS
    process(seleccion_anodo, seg_numero, anim_reset_activado, seg_animacion)
    begin
        an <= (others => '1');
        if anim_reset_activado = '1' then
            an(seleccion_anodo) <= '0'; seg_final <= seg_animacion;
        else
            case seleccion_anodo is
                when 3 => an(4) <= '0'; seg_final <= CHAR_P;
                when 4 => an(3) <= '0'; seg_final <= seg_numero;
                when others => an(seleccion_anodo) <= '0'; seg_final <= CHAR_DASH;
            end case;
        end if;
    end process;
    seg <= seg_final;

    -- LEDS 
    process(anim_activada, leds_anim, leds_piso_normal, motor_status, puerta_abierta)
    begin
        if anim_activada = '1' then
            -- Si estamos abriendo/cerrando puerta, MANDA LA ANIMACIÓN
            LED_FINAL <= leds_anim;
        else
            -- Si no, mostramos lo de siempre
            LED_FINAL <= (others => '0'); 
            LED_FINAL(3 downto 0) <= leds_piso_normal;
            LED_FINAL(7 downto 6) <= motor_status;
            LED_FINAL(15)         <= puerta_abierta;
        end if;
    end process;

end Behavioral;