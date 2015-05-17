----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:57:36 04/08/2014 
-- Design Name: 
-- Module Name:    cpsr - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cpsr is
port(
cpsr_en:in std_logic;
clk:in std_logic;
n:in std_logic;
z:in std_logic;
c:in std_logic;
v:in std_logic;
cpsr_out:out std_logic_vector(15 downto 0):=(OTHERS=>'0')
);
end cpsr;

architecture Behavioral of cpsr is
begin
process(clk)
begin
if(clk'event and clk='1' and cpsr_en='1') then
cpsr_out(15)<=n;
cpsr_out(14)<=z;
cpsr_out(13)<=c;
cpsr_out(12)<=v;
end if;
end process;
end Behavioral;

