----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:27:41 04/01/2014 
-- Design Name: 
-- Module Name:    pc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pc is
port(
en:in STD_LOGIC;
pcout:out STD_LOGIC_VECTOR(15 downto 0);
clk:in STD_LOGIC;
pcin:in std_logic_VECTOR(15 downto 0);
wr_en:in std_logic;
sel:in std_logic_vector(3 downto 0)
);
end pc;

architecture Behavioral of pc is
shared variable count :STD_LOGIC_VECTOR(15 downto 0):=(OTHERS=>'0');
begin
process(clk,en,sel,wr_en,pcin)
begin
if(en='1') then
if(rising_edge(clk)) then
count:=count+1;
end if;
if(sel="1111" and wr_en='1' ) then
count:=pcin;
end if;
end if;
pcout<=count;
end process;

end Behavioral;

