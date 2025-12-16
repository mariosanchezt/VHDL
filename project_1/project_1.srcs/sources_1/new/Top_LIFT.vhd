library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_LIFT is
    Port (
        CLK             : in  std_logic;
        rst_n           : in  std_logic; -- CPU_RESETN (Botón Rojo)
        botones_fisicos : in  std_logic_vector(3 downto 0);
        
        -- SALIDAS FÍSICAS (Conectadas a Visualizador)
        SEG             : out std_logic_vector(6 downto 0);
        AN              : out std_logic_vector(7 downto 0);
        LED             : out std_logic_vector(15 downto 0)
    );
end Top_LIFT;

architecture Structural of Top_LIFT is

    -- SEÑALES INTERNAS
    signal s_botones_clean : std_logic_vector(3 downto 0);
    
    -- Señales de la FSM
    signal s_tick_mover    : std_logic;
    signal s_fin_timer     : std_logic;
    signal s_motor         : std_logic_vector(1 downto 0);
    signal s_puerta        : std_logic;
    signal s_piso_actual   : std_logic_vector(1 downto 0);
    signal s_piso_destino  : std_logic_vector(1 downto 0);
    
    -- Señales visuales
    signal s_leds_target   : std_logic_vector(3 downto 0);
    signal s_leds_motor    : std_logic_vector(1 downto 0);
    signal s_led_puerta    : std_logic;

    -- COMPONENTES 
    
    COMPONENT Entradas
        port ( CLK : in STD_LOGIC; rst_n : in STD_LOGIC; 
               entrada : in STD_LOGIC_VECTOR(3 downto 0); button_in : out STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;
    
    
    COMPONENT Timer_Lift 
        port ( clk : in std_logic; rst_n : in std_logic; tick_clk : out std_logic );
    END COMPONENT;

   
    COMPONENT Timer_Puerta
        port (
         clk : in std_logic; 
        rst_n : in std_logic;
         tick_clk : out std_logic );
    END COMPONENT;

    COMPONENT Controlador
        port ( 
        CLK : in std_logic; 
        rst_n : in std_logic; 
        botones_piso : in std_logic_vector(3 downto 0);
        tick_mover : in std_logic; 
        fin_timer : in std_logic; 
        motor : out std_logic_vector(1 downto 0);
       puerta_abierta : out std_logic; 
       piso_actual : out std_logic_vector(1 downto 0);
        piso_destino : out std_logic_vector(1 downto 0));
    END COMPONENT;

    COMPONENT Visualizador
        Port ( 
        CLK            : in  STD_LOGIC;
        rst_n          : in  STD_LOGIC;
        piso_actual : in STD_LOGIC_VECTOR(1 downto 0); 
        piso_target : in STD_LOGIC_VECTOR(1 downto 0);
        motor_status : in STD_LOGIC_VECTOR(1 downto 0); 
        puerta_abierta : in STD_LOGIC;
        seg : out STD_LOGIC_VECTOR(6 downto 0); 
        an : out STD_LOGIC_VECTOR(7 downto 0);
        leds_piso : out STD_LOGIC_VECTOR(3 downto 0); 
        leds_motor : out STD_LOGIC_VECTOR(1 downto 0);
        led_puerta : out STD_LOGIC);
    END COMPONENT;

begin

    -- ENTRADAS
    inst_Entradas : Entradas
        PORT MAP ( CLK => CLK, 
        rst_n => rst_n, 
        entrada => botones_fisicos, 
        button_in => s_botones_clean );

    --  TIMERS 
    
    inst_Timer_Lift : Timer_Lift
        PORT MAP ( 
        clk => CLK, 
        rst_n => rst_n, 
        tick_clk => s_tick_mover );
        
    inst_Timer_Puerta : Timer_Puerta
        PORT MAP ( 
        clk => CLK, 
        rst_n => rst_n, 
        tick_clk => s_fin_timer );

   -- CONTROLADOR
    inst_Controlador : Controlador
        PORT MAP (
            CLK => CLK, 
            rst_n => rst_n, 
            botones_piso => s_botones_clean,
            tick_mover => s_tick_mover, 
            fin_timer => s_fin_timer,
            motor => s_motor, 
            puerta_abierta => s_puerta,
            piso_actual => s_piso_actual, 
            piso_destino => s_piso_destino
        );

    -- VISUALIZADOR
    inst_Visualizador : Visualizador
        PORT MAP (
            CLK            => CLK,
            rst_n          => rst_n,
            piso_actual => s_piso_actual, 
            piso_target => s_piso_destino,
            motor_status => s_motor,
            puerta_abierta => s_puerta,
            seg => SEG,
            an => AN,
            leds_piso => s_leds_target, 
            leds_motor => s_leds_motor, 
            led_puerta => s_led_puerta
        );

    -- SALIDAS A LA PLACA
    LED(3 downto 0) <= s_leds_target;
    LED(7 downto 6) <= s_leds_motor;
    LED(15) <= s_led_puerta;
    LED(5 downto 4) <= "00";
    LED(14 downto 8) <= (others => '0');


end Structural;