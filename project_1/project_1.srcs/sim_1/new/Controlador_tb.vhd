library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controlador_tb is

end Controlador_tb;

architecture Behavioral of Controlador_tb is

    -- Componente (Coincide con FSM.vhd)
    component Controlador
    Port ( 
        CLK           : in  STD_LOGIC;
        rst_n         : in  STD_LOGIC;
        botones_piso  : in  STD_LOGIC_VECTOR(3 downto 0);
        tick_mover    : in  STD_LOGIC;
        fin_timer     : in  STD_LOGIC;
        motor         : out STD_LOGIC_VECTOR(1 downto 0);
        puerta_abierta: out STD_LOGIC;
        piso_actual   : out STD_LOGIC_VECTOR(1 downto 0);
        piso_destino  : out STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;

    -- Señales internas
    signal s_CLK           : STD_LOGIC := '0';
    signal s_rst_n         : STD_LOGIC := '0';
    signal s_botones_piso  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal s_tick_mover    : STD_LOGIC := '0';
    signal s_fin_timer     : STD_LOGIC := '0';
    
    -- Salidas
    signal s_motor         : STD_LOGIC_VECTOR(1 downto 0);
    signal s_puerta_abierta: STD_LOGIC;
    signal s_piso_actual   : STD_LOGIC_VECTOR(1 downto 0);
    signal s_piso_destino  : STD_LOGIC_VECTOR(1 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: Controlador Port map (
        CLK => s_CLK,
        rst_n => s_rst_n,
        botones_piso => s_botones_piso,
        tick_mover => s_tick_mover,
        fin_timer => s_fin_timer,
        motor => s_motor,
        puerta_abierta => s_puerta_abierta,
        piso_actual => s_piso_actual,
        piso_destino => s_piso_destino
    );

    -- Generador de Reloj
    p_clk: process
    begin
        s_CLK <= '0';
        wait for CLK_PERIOD/2;
        s_CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

   
    --  (0 -> 3 -> 1)
   
    p_stim: process
    begin
        report "=== INICIO SECUENCIA COMPLETA ===";
        
        -- Pone el ascensor en el piso 0
        s_rst_n <= '0'; 
        wait for 50 ns;
        s_rst_n <= '1'; 
        wait for 100 ns;
        
        
        -- 1: SUBIR DEL PISO 0 AL PISO 3
    
        report ">>> PASO 1: Llamada al Piso 3";
        
        -- Pulsamos botón del piso 3 ("1000")
        s_botones_piso <= "1000"; 
        wait for CLK_PERIOD * 4;
        s_botones_piso <= "0000"; 
        
        -- Esperamos a que cierre la puerta y arranque
        wait for 50 ns;
        if s_motor /= "01" then report "ERROR: No está subiendo" severity error; end if;

        -- Simulamos el viaje (necesitamos 3 ticks: 0->1, 1->2, 2->3)
        report "   ... Viajando: 0 -> 1";
        wait for 50 ns; s_tick_mover <= '1'; wait for CLK_PERIOD; s_tick_mover <= '0';
        
        report "   ... Viajando: 1 -> 2";
        wait for 50 ns; s_tick_mover <= '1'; wait for CLK_PERIOD; s_tick_mover <= '0';
        
        report "   ... Viajando: 2 -> 3";
        wait for 50 ns; s_tick_mover <= '1'; wait for CLK_PERIOD; s_tick_mover <= '0';

        -- Llegada al piso 3 (Estado LLEGADA_FRENO)
        -- El motor se para, pero la puerta sigue cerrada esperando el timer
        wait for 20 ns;
        if s_motor /= "00" then report "ERROR: No paró en el 3" severity error; end if;
        
        -- Simulamos que pasa el tiempo de frenado
        report "   ... Frenando y Abriendo Puerta";
        s_fin_timer <= '1'; 
        wait for CLK_PERIOD; 
        s_fin_timer <= '0';
        
        -- Esperamos a que la puerta se abra y estemos en IDLE
        wait for 100 ns; 
        if s_puerta_abierta /= '1' then report "ERROR: Puerta no se abrió en piso 3" severity error; end if;

        
        -- 2: BAJAR DEL PISO 3 AL PISO 1
        
        report ">>> PASO 2: Llamada al Piso 1";
        
        -- Pulsamos botón del piso 1 ("0010")
        s_botones_piso <= "0010"; 
        wait for CLK_PERIOD * 4;
        s_botones_piso <= "0000";

        -- Esperamos a que cierre la puerta y arranque hacia abajo
        wait for 50 ns;
        if s_motor /= "10" then report "ERROR: No está bajando" severity error; end if;

        -- Simulamos el viaje (necesitamos 2 ticks: 3->2, 2->1)
        report "   ... Viajando: 3 -> 2";
        wait for 50 ns; s_tick_mover <= '1'; wait for CLK_PERIOD; s_tick_mover <= '0';
        
        report "   ... Viajando: 2 -> 1";
        wait for 50 ns; s_tick_mover <= '1'; wait for CLK_PERIOD; s_tick_mover <= '0';

        -- Llegada al piso 1
        wait for 20 ns;
        if s_motor /= "00" then report "ERROR: No paró en el 1" severity error; end if;
        
        -- Simulamos fin de frenado para abrir puerta
        report "   ... Frenando y Abriendo Puerta";
        s_fin_timer <= '1'; 
        wait for CLK_PERIOD; 
        s_fin_timer <= '0';
        
        wait for 50 ns;
        if s_piso_actual /= "01" then 
            report "FALLO FINAL: El ascensor no terminó en el piso 1" severity failure;
        else
            report "=== EXITO: SECUENCIA 0 -> 3 -> 1 COMPLETADA ===";
        end if;

        wait;
    end process;

end Behavioral;