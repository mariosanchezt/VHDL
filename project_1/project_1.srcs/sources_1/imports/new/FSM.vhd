library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controlador is
    Port ( 
        CLK           : in  STD_LOGIC;
        rst_n         : in  STD_LOGIC; -- CAMBIADO A NEGADO
        
        -- ENTRADAS
        button_in  : in  STD_LOGIC_VECTOR(3 downto 0); -- Vienen de Entradas.vhd
        tick    : in  STD_LOGIC;                    -- Viene del Simulador de Tiempos
        fin_timer     : in  STD_LOGIC;                    -- Viene del Timer Puerta
        
        -- SALIDAS
        motor         : out STD_LOGIC_VECTOR(1 downto 0); -- 00:Parado, 01:Subir, 10:Bajar
        puerta_abierta: out STD_LOGIC;                    -- 1:Abierta
        
        -- INFO VISUAL
        piso_actual   : out STD_LOGIC_VECTOR(1 downto 0);
        piso_destino  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Controlador;

architecture Behavioral of Controlador is

    -- Definición de Estados 
    type estados_t is (IDLE, CERRANDO, SUBIENDO, BAJANDO, ABRIENDO, ESPERA_PUERTA);
    signal estado_actual, estado_siguiente : estados_t;

    -- Registros para guardar dónde estamos y a dónde vamos
    signal r_piso_actual : integer range 0 to 3 := 0; 
    signal r_piso_target : integer range 0 to 3 := 0;

begin

    -- PROCESO SECUENCIAL (Memoria)
    process (CLK, rst_n)
    begin
        if rst_n = '0' then  -- Reset Activo Bajo
            estado_actual <= IDLE;
            r_piso_actual <= 0;
            r_piso_target <= 0;
        elsif rising_edge(CLK) then
            estado_actual <= estado_siguiente;
            
            -- Lógica para capturar llamadas (Solo en IDLE o ABRIENDO)
            -- Esto guarda en memoria a qué piso queremos ir
            if button_in(0) = '1' then r_piso_target <= 0; 
            end if;
            if button_in(1) = '1' then r_piso_target <= 1; 
            end if;
            if button_in(2) = '1' then r_piso_target <= 2; 
            end if;
            if button_in(3) = '1' then r_piso_target <= 3; 
            end if;

            -- Actualización de posición física (Simulada)
            if tick = '1' then
                if estado_actual = SUBIENDO and r_piso_actual < 3 then
                    r_piso_actual <= r_piso_actual + 1;
                elsif estado_actual = BAJANDO and r_piso_actual > 0 then
                    r_piso_actual <= r_piso_actual - 1;
                end if;
            end if;
        end if;
    end process;

    -- PROCESO COMBINACIONAL (Lógica de Estados)
    -- Aquí definimos las flechas del diagrama
    process (estado_actual, r_piso_actual, r_piso_target, tick, fin_timer)
    begin
        -- Valores por defecto (para evitar latches)
        estado_siguiente <= estado_actual;
        motor <= "00";      -- Parado
        puerta_abierta <= '0'; -- Cerrada

        case estado_actual is
            
            when IDLE =>
                puerta_abierta <= '1'; -- En reposo la puerta suele estar abierta o esperando
                -- Si el destino es diferente al actual, empezamos a movernos
                if r_piso_target /= r_piso_actual then
                    estado_siguiente <= CERRANDO;
                end if;

            when CERRANDO =>
                puerta_abierta <= '0'; -- Cerramos
                -- Decidimos dirección
                if r_piso_target > r_piso_actual then
                    estado_siguiente <= SUBIENDO;
                elsif r_piso_target < r_piso_actual then
                    estado_siguiente <= BAJANDO;
                else
                    estado_siguiente <= ABRIENDO; -- Ya estamos ahí
                end if;

            when SUBIENDO =>
                motor <= "01"; -- Código Subir
                if r_piso_actual = r_piso_target then
                    estado_siguiente <= ABRIENDO;
                end if;

            when BAJANDO =>
                motor <= "10"; -- Código Bajar
                if r_piso_actual = r_piso_target then
                    estado_siguiente <= ABRIENDO;
                end if;

            when ABRIENDO =>
                motor <= "00";
                puerta_abierta <= '1';
                -- Aquí deberíamos disparar el timer, pasamos a espera
                estado_siguiente <= ESPERA_PUERTA;

            when ESPERA_PUERTA =>
                puerta_abierta <= '1';
                if fin_timer = '1' then
                    estado_siguiente <= IDLE;
                end if;

        end case;
    end process;

    -- Salidas auxiliares
    piso_actual <= std_logic_vector(to_unsigned(r_piso_actual, 2));
    piso_destino <= std_logic_vector(to_unsigned(r_piso_target, 2));

end Behavioral;