
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:04:45 03/31/2014 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
port
(
rm_reg:in std_logic_vector(15 downto 0);
rm_mem:in std_logic_vector(15 downto 0);
rm_wb:in std_logic_vector(15 downto 0);
rn:in std_logic_vector(15 downto 0);
rd:out std_logic_vector(15 downto 0);
psr:out std_logic_vector(3 downto 0);--currently using last four flag bits (NZCV)
alu_sel:in std_logic_vector(3 downto 0);
alu_cy:in std_logic ;--take this signal from decoder
write_address:  in std_logic_vector(3 downto 0);  -- connect wr_addr of control
mem_address:  in std_logic_vector(3 downto 0);   -- connect to wr_addr_mem.. of control
input1: in std_logic_vector(3 downto 0)
);

end alu;

--0000 add
--0001 sub
--0010 compare
-- 0011 move
--0100 and
-- 0101 xor
-- 0110 or
--0111 compliment
--1000 multiply
--1001 ADDC
-- 1010 SUBC

architecture Behavioral of alu is
signal rm:std_logic_vector(15 downto 0);
begin

process(rm_wb,rm_mem,rm_reg)
begin
if(write_address = input1) then
			rm<= rm_wb;
		elsif(input1= mem_address) then
			rm<=rm_mem;
		else
		  rm<=rm_reg  ;  		
end if;
end process;

process(rn,rm,alu_sel,alu_cy)
variable temp:STD_LOGIC_VECTOR(16 downto 0);
variable result:STD_LOGIC_VECTOR(15 downto 0);
variable cfv,zfv:STD_LOGIC;
variable mul_ans:STD_LOGIC_VECTOR(15 downto 0); 
begin
--temp:=(OTHERS=>'0');
--zfv:='0';
--psr(1 downto 0)<="00";
--result:=(OTHERS=>'0');

case alu_sel is 
--arithmetic inst
when "0000" =>--add
temp:=('0' & rn) + ('0' & rm);
cfv:=temp(16);
result:=temp(15 downto 0);
psr(0)<=result(15) xor rn(15) xor rm(15) xor cfv;
psr(1)<=cfv;
zfv:='0';

when "0001" =>--sub 
temp:=('0' & rn) - ('0' & rm);
result:=temp(15 downto 0);
cfv:=temp(16);
psr(0)<=result(15) xor rn(15) xor rm(15) xor cfv;
psr(1)<=cfv;
zfv:='0';
--
when "1000" => -- mul
mul_ans:=rn(7 downto 0)*rm(7 downto 0);
result:=mul_ans;
zfv:='0';

----
when "1001" =>  -- add with carry
temp:=('0' & rn) + ('0' & rm)+ alu_cy;
result:=temp(15 downto 0);
cfv:=temp(16);
psr(0)<=result(15) xor rn(15) xor rm(15) xor cfv;
psr(1)<=cfv;
zfv:='0';

when "1010" =>-- sub with carry
temp:=('0' & rn) - ('0' & rm) - alu_cy;
result:=temp(15 downto 0);
cfv:=temp(16);
psr(0)<=result(15) xor rn(15) xor rm(15) xor cfv;
psr(1)<=cfv;
zfv:='0';

---------------------------
-----logical inst
when "0010" => -- compare
temp:=('0' & rn) - ('0' & rm);
cfv:=temp(16);
psr(0)<=temp(15) xor rn(15) xor rm(15) xor cfv;
psr(1)<=cfv;
zfv:='0';

when "0100" =>
result:=(rn and rm);
zfv:='0';

when "0101" =>
result:=(rn xor rm);
zfv:='0';

when "0110" => -- OR
result:=(rn or rm);
zfv:='0';

-- data tansfer inst
when "0011" =>
result:=rn; 

when "0111" => -- complement
result:= not rn; 
zfv:='0';

when others =>
temp:=temp;
result:=result;

end case;
for i in 0 to 15 loop
 zfv:=zfv or result(i);
end loop;

rd<=result;
psr(2)<=not zfv;
psr(3)<=result(15);

end process;

end Behavioral;

