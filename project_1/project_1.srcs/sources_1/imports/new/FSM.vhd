library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controlador is
    Port ( 
        CLK           : in  STD_LOGIC;
        rst_n         : in  STD_LOGIC; -- Reset Activo Bajo 
        
        -- ENTRADAS
        botones_piso  : in  STD_LOGIC_VECTOR(3 downto 0); -- Desde Entradas.vhd
        tick_mover    : in  STD_LOGIC;                    -- Desde Simulador
        fin_timer     : in  STD_LOGIC;                    -- Desde Timer Puerta/Freno
        
        -- SALIDAS FÍSICAS
        motor         : out STD_LOGIC_VECTOR(1 downto 0); -- 00:Parado, 01:Subir, 10:Bajar
        puerta_abierta: out STD_LOGIC;                    -- 1:Abierta, 0:Cerrada
        
        -- SALIDAS DE INFORMACIÓN (Para Display)
        piso_actual   : out STD_LOGIC_VECTOR(1 downto 0);
        piso_destino  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Controlador;

architecture Behavioral of Controlador is

    
    type estados_t is (IDLE, CERRANDO, SUBIENDO, BAJANDO, LLEGADA_FRENO); --ABRIENDO (duda)
    signal estado_actual, estado_siguiente : estados_t;

    -- Registros internos
    signal r_piso_actual : integer range 0 to 3 := 0;
    signal r_piso_target : integer range 0 to 3 := 0;

begin

    
    process (CLK, rst_n)
    begin
        if rst_n = '0' then
            -- Reset del sistema
            estado_actual <= IDLE;
            r_piso_actual <= 0;
            r_piso_target <= 0;
            
        elsif rising_edge(CLK) then
            -- Actualización de estado
            estado_actual <= estado_siguiente;
            
            
            -- Si se mueve, ignorar botones
            if estado_actual = IDLE then
                if botones_piso(0) = '1' then r_piso_target <= 0; end if;
                if botones_piso(1) = '1' then r_piso_target <= 1; end if;
                if botones_piso(2) = '1' then r_piso_target <= 2; end if;
                if botones_piso(3) = '1' then r_piso_target <= 3; end if; --En caso de que se pulsen todos a la vez, tendra prioridad la ultima señal asignada (teoria)
            end if;

           
            -- Cambia el número de piso cuando llega el 'tick' del simulador
            if tick_mover = '1' then
                if estado_actual = SUBIENDO and r_piso_actual < 3 then
                    r_piso_actual <= r_piso_actual + 1;
                elsif estado_actual = BAJANDO and r_piso_actual > 0 then
                    r_piso_actual <= r_piso_actual - 1;
                end if;
            end if;
            
        end if;
    end process;

    
    process (estado_actual, r_piso_actual, r_piso_target, fin_timer)
    begin
        -- Valores por defecto para evitar latches
        estado_siguiente <= estado_actual;
        motor <= "00";          -- Por defecto motor parado
        puerta_abierta <= '1';  -- Por defecto puerta abierta 

        case estado_actual is
            
           
            when IDLE =>
                motor <= "00";
                puerta_abierta <= '1'; -- Mantenemos abierta esperando gente
                
                if r_piso_target /= r_piso_actual then
                    estado_siguiente <= CERRANDO;
                end if;

            
            when CERRANDO =>
                motor <= "00";
                puerta_abierta <= '0'; 
                
                -- Decidimos dirección
                if r_piso_target > r_piso_actual then
                    estado_siguiente <= SUBIENDO;
                elsif r_piso_target < r_piso_actual then
                    estado_siguiente <= BAJANDO;
                else
                    estado_siguiente <= IDLE; 
                end if;

            when SUBIENDO =>
                motor <= "01";         
                puerta_abierta <= '0'; 
                if r_piso_actual = r_piso_target then
                    estado_siguiente <= LLEGADA_FRENO;
                end if;

            when BAJANDO =>
                motor <= "10";         
                puerta_abierta <= '0'; 
                if r_piso_actual = r_piso_target then
                    estado_siguiente <= LLEGADA_FRENO;
                end if;

         
            when LLEGADA_FRENO =>
                motor <= "00";          
                puerta_abierta <= '0';  
                
              
                if fin_timer = '1' then  --Caution porque si justo es 1 en el instante que entra aqui, saltaria la etapa, habra que tocar posiblemente algo del edge detector
                    estado_siguiente <= IDLE;
                end if;

            
           -- when ABRIENDO => --Vamos a probar asi pero creo que nos podriamos saltar este paso ya que es fugaz
           --     motor <= "00";
            --    puerta_abierta <= '1';  
             --   estado_siguiente <= IDLE;

        end case;
    end process;

   
    piso_actual  <= std_logic_vector(to_unsigned(r_piso_actual, 2));
    piso_destino <= std_logic_vector(to_unsigned(r_piso_target, 2));

end Behavioral;