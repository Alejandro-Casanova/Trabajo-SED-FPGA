----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.01.2022 11:50:53
-- Design Name: 
-- Module Name: fsm_tb - Behavioral
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




-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity tb_fsm is
end;

architecture tb of tb_fsm is

    component fsm 
        port ( 
            RESET_N       : in std_logic; 
            CLK           : in std_logic; 
            PUSHBUTTON    : in std_logic_vector(3 downto 0); 
            TURN_R        : out std_logic ; 
            TURN_L        : out std_logic;
            LED : out std_logic_vector(3 downto 0)
        );
    end component;

  signal RESET_N: std_logic;
  signal CLK: std_logic := '1';
  signal PUSHBUTTON: std_logic_vector(3 downto 0);
  signal TURN_R: std_logic;
  signal TURN_L: std_logic;
  signal LED : std_logic_vector(3 downto 0);

  constant TbPeriod: time := 10 ns;
  --signal stop_the_clock: boolean;

begin

    uut: fsm port map(RESET_N      => RESET_N,
                      CLK          => CLK,
                      PUSHBUTTON   => PUSHBUTTON,
                      TURN_R       => TURN_R,
                      TURN_L       => TURN_L,
                      LED          => LED 
    );

    clocking: CLK <= not CLK after TbPeriod/2;
    
    stimulus: process -- Asumimos pulsaciones sin rebote y sincronizadas
    begin
        PUSHBUTTON <= "0000";
        RESET_N <= '0';
        wait for TbPeriod;
        assert TURN_R = '0' and TURN_L = '0' report "Reset Failed" severity failure;
        RESET_N <= '1';
        wait for TbPeriod * 5;
    
        PUSHBUTTON <= "0010";--desde "S0" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="0100";--desde "S1" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="0010";--desde "S2" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        PUSHBUTTON <="0100";--desde "S1" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="1000";--desde "S2" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="0001";--desde "S3" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="1000";--desde "S0" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        PUSHBUTTON <="0100";--desde "S3" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        PUSHBUTTON <="1000";--desde "S2" giramos a derechas
        wait for TbPeriod * 5;
        --assert TURN_R='0'report "correcto";
        --assert TURN_R='1'report "fallo";
        
        PUSHBUTTON <="0100";--desde "S3" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        PUSHBUTTON <="0010";--desde "S2" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        PUSHBUTTON <="0001";--desde "S1" giramos a izquierdas
        wait for TbPeriod * 5;
        --assert TURN_L='0'report "correcto";
        --assert TURN_L='1'report "fallo";
        
        assert false report "Test Complete" severity failure;
    end process;

end architecture tb;
