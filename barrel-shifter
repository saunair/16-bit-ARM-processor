----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:03:33 03/18/2014 
-- Design Name: 
-- Module Name:    barrelshifter - Behavioral 
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
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity barrelshifter is
port
(
-- 	clk:in std_logic:='0';
--inp_addr_register1:in std_logic_vector(3 downto 0); -- connect this to control and timings' inp1_addr
	inp_addr_register2:in std_logic_vector(3 downto 0):=(others=>'0');--  connect this to control and timings inp2_addr
	data_writeback_cycle:in std_logic_vector(15 downto 0):=(others=>'0'); -- connect this to memory access's data o/p
	data_memory_cycle:in std_logic_vector(15 downto 0):=(others=>'0');  -- connect this to alu's o/p
	address_writeback: in std_logic_vector(3 downto 0):=(others=>'0');  -- conenct this to wr_addr of control and timing
	address_memaccess: in std_logic_vector(3 downto 0):=(others=>'0'); -- connect this to control and timing's wr_addr_forward_mem
	datain: in std_logic_vector(31 downto 0):=(others=>'0');
	direction: in std_logic;
	rotation : in std_logic;
	count: in std_logic_vector(3 downto 0);
	dataout: out std_logic_vector(15 downto 0);
	mux_imm:in std_logic);
end barrelshifter;

architecture Behavioral of barrelshifter is

 signal data: std_logic_vector(15 downto 0); 
function barrel_shift(din: in std_logic_vector(15 downto 0);
	dir: in std_logic;
	cnt: in std_logic_vector(3 downto 0)) 
return std_logic_vector  is
	begin
	
	if (dir = '1') then
		return std_logic_vector((SHR(unsigned(din), unsigned(cnt))));
	else
		return std_logic_vector((SHL(unsigned(din), unsigned(cnt))));
	end if;
end barrel_shift;

-- ROTATE LEFT/RIGHT FUNCTION
function barrel_rotate(din: in std_logic_vector(15 downto 0);
dir: in std_logic;
cnt: in std_logic_vector(3 downto 0)) 
return std_logic_vector is
variable temp1, temp2: std_logic_vector(31 downto 0);
	begin
	case
	dir is
	when '1'=> -- rotate right cnt times
	temp1 := din & din;
	temp2 := std_logic_vector(SHR(unsigned(temp1),unsigned(cnt)));
	return temp2(15 downto 0);
when others => -- rotate left cnt times
	temp1 := din & din;
	temp2 := std_logic_vector(SHL(unsigned(temp1),unsigned(cnt)));
	return temp2(31 downto 16);
	end case;
end barrel_rotate;



begin



P1: process (data, direction, rotation, count)
begin
if  (rotation = '0') then -- only shift 
dataout <= barrel_shift(data, direction, count);
else --  only rotate
dataout <= barrel_rotate(data, direction, count);
end if;
end process;

input_mux:process(mux_imm,datain,data_writeback_cycle,data_memory_cycle )
 begin -- clock removed from here 
	if( mux_imm = '0') then
		if(inp_addr_register2 = address_writeback ) then-- from write back cycle
			data<= data_writeback_cycle;
		elsif(inp_addr_register2 = address_memaccess) then  -- from mem access cycle
			data<= data_memory_cycle;
		else     -- normal case without forwarding
			data<=datain(15 downto 0); --data changed to dataout
 end if;
	elsif(mux_imm='1') then  -- select immediate data
		data<=datain(31 downto 16);--changed from data
	else
		data<=datain(15 downto 0);
	end if;
end process;
	

end Behavioral;

