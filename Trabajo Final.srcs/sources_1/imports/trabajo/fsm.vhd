----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.11.2021 00:23:04
-- Design Name: 
-- Module Name: fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm is 
    port ( 
        RESET_N : in std_logic; 
        CLK : in std_logic; 
        PUSHBUTTON : in std_logic_vector(3 downto 0); -- Left, Down, Right, Up
        TURN_R : out std_logic ; 
        TURN_L: out std_logic;
        LED : out std_logic_vector(3 downto 0) -- Left, Down, Right, Up (Indica el Estado)
    );
end fsm; 

architecture behavioral of fsm is 
    type STATES is (S0, S1, S2, S3); -- Arriba, Derecha, Abajo, Izquierda
    signal current_state: STATES := S0; --empieza hacia arriba
    signal next_state: STATES; 
    signal s_TURN_L : std_logic := '0';
    signal s_TURN_R : std_logic := '0';
    signal s_LED : std_logic_vector(3 downto 0) := (others => '0');
    
begin 
    
    TURN_R <= s_TURN_R;
    TURN_L <= s_TURN_L;
    LED <= s_LED;
          
    state_register: process (RESET_N, CLK) 
    begin 
        if RESET_N = '0' then
            current_state <= S0;     
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;
    
    nextstate_decod: process (PUSHBUTTON, current_state) 
    begin 
        next_state <= current_state; 
        case current_state is 
        
            when S0 => -- UP
                if PUSHBUTTON = "0010" then -- Button Right
                    next_state <= S1; -- Right
                    --TURN_R<='1'; 
                    --TURN_L<='0';
                elsif PUSHBUTTON = "1000" then -- Button Left
                    next_state <=S3; -- Left
                  --TURN_R<='0'; 
                  --TURN_L<='1';
                end if;
                
            when S1 => -- Right
                if PUSHBUTTON ="0001" then -- Button Up    
                    next_state <= S0; -- UP
                    --TURN_R<='0'; 
                    --TURN_L<='1';        
                elsif PUSHBUTTON ="0100" then -- Button Down
                    next_state <=S2; -- Down
                    --TURN_R<='1'; 
                    --TURN_L<='0'; 
                end if;       
                                 
            when S2 => -- Down
                if PUSHBUTTON ="0010" then -- Button Right  
                    next_state <= S1; -- Right
                    --TURN_R<='0'; 
                    --TURN_L<='1';      
                elsif PUSHBUTTON ="1000" then -- Button Left
                    next_state <=S3; -- Left
                    --TURN_R<='1'; 
                    --TURN_L<='0';
                end if;      
                                 
            when S3 => -- Left
                if PUSHBUTTON ="0001" then  -- Button Up  
                    next_state <= S0; -- Up
                    --TURN_R<='1'; 
                    --TURN_L<='0';        
                elsif PUSHBUTTON ="0100" then -- Button Down
                    next_state <=S2; -- Down
                    --TURN_R<='0'; 
                    --TURN_L<='1';
                end if; 
                
            when others =>
                next_state <= S0; 
                      
        end case; 
    end process; 
    
    output_decod : process (current_state, PUSHBUTTON, RESET_N) -- Mealy 
    begin
    if RESET_N = '0' then
        s_TURN_R <= '0'; 
        s_TURN_L <= '0';
        s_LED <= "0001";
    else
        case current_state is
            when S0 => -- UP
                s_TURN_R <= PUSHBUTTON(1); 
                s_TURN_L <= PUSHBUTTON(3);
                s_LED <= "0001";
            when S1 => -- Right
                s_TURN_R <= PUSHBUTTON(2); 
                s_TURN_L <= PUSHBUTTON(0);
                s_LED <= "0010";
            when S2 => -- Down
                s_TURN_R <= PUSHBUTTON(3); 
                s_TURN_L <= PUSHBUTTON(1);
                s_LED <= "0100";
            when S3 => -- Left
                s_TURN_R <= PUSHBUTTON(0); 
                s_TURN_L <= PUSHBUTTON(2);
                s_LED <= "1000";
            when others =>
                s_TURN_R <= '0'; 
                s_TURN_L <= '0';
                s_LED <= "0000";
        end case;
    end if;
  end process output_decod;
    
end behavioral;
