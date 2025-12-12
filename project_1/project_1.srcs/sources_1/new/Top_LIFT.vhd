library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_LIFT is -- Primer top sin visualizer 
Port (
        CLK    : in  std_logic;
        rst_n         : in  std_logic;
        botones_fisicos  : in  std_logic_vector(3 downto 0);
        motor         : out std_logic_vector(1 downto 0);
        puerta_abierta: out std_logic;
        piso_actual   : out std_logic_vector(1 downto 0);
        piso_destino  : out std_logic_vector(1 downto 0)

 );
end Top_LIFT;

architecture Structural of Top_LIFT is
-- Señales internas para los timers ambos
    signal tick_mover_int : std_logic;
    signal fin_timer_int  : std_logic;
    signal botones_clean : std_logic_vector(3 downto 0); --Señal ya clean post edge y sync

        --Declaramos los diferentes componentes a continuacion

    COMPONENT Entradas
        port (
         CLK       : in  STD_LOGIC;
        rst_n       : in  STD_LOGIC; 
        entrada   : in  STD_LOGIC_VECTOR(3 downto 0);
        button_in : out STD_LOGIC_VECTOR(3 downto 0)
        );
    END COMPONENT;
    
    COMPONENT Timer_Lift
        port (
            clk      : in  std_logic;
            rst_n    : in  std_logic;
            tick_clk : out std_logic
        );
    END COMPONENT;
-- En ambos timers las señales se llaman igual pero las vamos a asignar a diferentes salidas por asi decirlo ya que  cada una tiene una funcion y un tiempo
    COMPONENT Timer_Puerta
        port (
            clk      : in  std_logic;
            rst_n    : in  std_logic;
            tick_clk : out std_logic
        );
    END COMPONENT;
-- Para la FSM
COMPONENT Controlador
        port (
            CLK            : in  std_logic;
            rst_n          : in  std_logic;
            botones_piso   : in  std_logic_vector(3 downto 0);
            tick_mover     : in  std_logic;
            fin_timer      : in  std_logic;
            motor          : out std_logic_vector(1 downto 0);
            puerta_abierta : out std_logic;
            piso_actual    : out std_logic_vector(1 downto 0);
            piso_destino   : out std_logic_vector(1 downto 0)
        );
    END COMPONENT;
begin
--Una vez declarados los componentes, vamos a instanciar cada uno de elllos
    inst_Entradas : Entradas
        PORT MAP (
            CLK       => CLK,
            rst_n     => rst_n,
            entrada   => botones_fisicos,
            button_in => botones_clean
        );

    inst_Timer_Lift : Timer_Lift
        PORT MAP (
            clk      => CLK,
            rst_n    => rst_n,
            tick_clk => tick_mover_int -- Este lo instanciamos a la variable interna de mover (Plantas ascensor)
        );
        
    inst_Timer_Puerta : Timer_Puerta
        PORT MAP (
            clk      => CLK,
            rst_n    => rst_n,
            tick_clk => fin_timer_int --Y este otro al timer asociado a la puerta
        );
        
        inst_Controlador : Controlador
        PORT MAP (
            CLK            => CLK,
            rst_n          => rst_n,
            botones_piso   => botones_clean, --Le asociamos los botones limpitos ya
            tick_mover     => tick_mover_int, --Aqui asociamos la variable con su correspondiente interna
            fin_timer      => fin_timer_int,
            motor          => motor,
            puerta_abierta => puerta_abierta,
            piso_actual    => piso_actual,
            piso_destino   => piso_destino
        );


end Structural;
