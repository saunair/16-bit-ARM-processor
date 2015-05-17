----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:33 04/07/2014 
-- Design Name: 
-- Module Name:    sign_ext - Behavioral 
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

entity sign_ext is
port(
datain:in std_logic_vector(15 downto 0);
imm:in std_logic_vector(1 downto 0); --00 for 3bit,01 for 5 bit,10 for 8 bit,11 for 11 bit
dataout:out std_logic_vector(15 downto 0)
);
end sign_ext;

architecture Behavioral of sign_ext is
begin
process(imm,datain)
variable temp:std_logic;
begin
	if(imm="00") then   -- 3 bit immediate
		temp:=datain(2);  
		if(temp='1') then
			dataout<="1111111111111000" or datain;
		elsif(temp='0') then
			dataout<=datain;
		end if;
	elsif(imm="01") then  -- 5 bit immediate
		temp:=datain(4);
		if(temp='1') then
			dataout<="1111111111100000" or datain;
		elsif(temp='0') then
			dataout<=datain;
		end if;
	elsif(imm="10") then  -- 8 bit immediate
		temp:=datain(7);
		if(temp='1') then
			dataout<="1111111100000000" or datain;
		elsif(temp='0') then
			dataout<=datain;
		end if;
	elsif(imm="11") then  -- 11 bit immediate
		temp:=datain(10);
		if(temp='1') then
			dataout<="1111100000000000" or datain;
		elsif(temp='0') then
			dataout<=datain;
		end if;	
end if;

end process;


end Behavioral;

