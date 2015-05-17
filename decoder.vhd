--this is the code for the decoder
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:14:08 03/11/2014 
-- Design Name: 
-- Module Name:    decoder - Behavioral 
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
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
port(
   clk:in STD_LOGIC;   -- 50 Mhz
	carry:in std_logic;
	zero: in std_logic;
	negative: in std_logic;
	overflow:in std_logic;
	inst_in:in STD_LOGIC_VECTOR(15 downto 0); -- instruction from queue
	ready:in std_logic;
	--outputs
	alu_select:out STD_LOGIC_VECTOR(3 downto 0):="ZZZZ"; -- what operation alu has to do during execution cycle
	inp1_addr:out STD_LOGIC_VECTOR(3 downto 0):="ZZZZ";    -- 4 bit input to register bank RM
	inp2_addr:out STD_LOGIC_VECTOR(3 downto 0):="ZZZZ";    -- RN 
	inp3_addr:out std_logic_vector(3 downto 0):="ZZZZ";
	wr_addr:out STD_LOGIC_VECTOR(3 downto 0):="ZZZZ"; -- write register no. during write cycle
	wr:out STD_LOGIC:='0';  --write signal to register bank
	mux_imm:out STD_LOGIC:='0';  -- 2nd operand for alu select signal(reg bank vs immediate data)
	pc_sign:out STD_LOGIC_VECTOR(1 downto 0):="00"; -- To distinguish between 3,5,8 and 11 bit offset
	stck_ram:out STD_LOGIC:='0'; -- activate stack/ram, make high for stack else low for ram
	push:out STD_LOGIC:='0'; 
	pop:out STD_LOGIC:='0';
	barrel_shift:out STD_LOGIC_VECTOR(3 downto 0):="ZZZZ"; -- amount of shift sent to barrel shifter 
	barr_sel:out STD_LOGIC_VECTOR(1 downto 0):="ZZ"; --to select which direction of rotate
	imm_data:out STD_LOGIC_VECTOR(15 downto 0);-- immediate data being sent to sgn_ext
	cpsr_en:out std_logic;
	mem_rd: out STD_LOGIC:='0'; --Make high for LOAD
   mem_wr: out STD_LOGIC:='0' ;--Make high for Store
	clk_out:out std_logic:='0';
	pc_en:out std_logic
--	inst_enable:out std_logic

	); 
	
end decoder;

architecture Behavioral of decoder is

shared variable i:integer:= 7;
shared variable j:integer:= 0;
shared variable hlt: std_logic:='1';
shared variable B : integer range 0 to 7:=0;	
begin
process(clk)

variable inp1:STD_LOGIC_VECTOR(3 downto 0) ; -- rm
variable shift:STD_LOGIC_VECTOR(3 downto 0);  --shift value for lsl,lsr
variable inp2:STD_LOGIC_VECTOR(3 downto 0) ; -- rn
variable temp:STD_LOGIC_VECTOR(7 downto 0) ;

variable inp3:STD_LOGIC_VECTOR(3 downto 0); -- rd/rn
variable dest:STD_LOGIC_VECTOR(3 downto 0);  -- rd

variable imm_data3:STD_LOGIC_VECTOR(2 downto 0); -- 3 bit imm data
variable imm_data8:STD_LOGIC_VECTOR(7 downto 0) ; -- 8 bit imm data
variable imm_data5:STD_LOGIC_VECTOR(4 downto 0) ; -- 5 bit imm data
variable imm_data11:STD_LOGIC_VECTOR(10 downto 0) ;

	
	
begin

	if(rising_edge(clk) and ready='1' and hlt='1') then 
		pc_en<='1';
		if(i=7) then
		--inst_enable<='1';
		inp1:= '0' & inst_in(8 downto 6); -- rm
		shift:= inst_in(9 downto 6);  --shift value for lsl,lsr
		inp2:= '0' & inst_in(5 downto 3); -- rn
		inp3:= '0' & inst_in(10 downto 8);
		imm_data3 := inst_in(8 downto 6); -- 3 bit imm data
		imm_data8 := inst_in(7 downto 0); -- 8 bit imm data
		imm_data5 := inst_in(10 downto 6); -- 5 bit imm data
	   imm_data11 := inst_in(10 downto 0); -- during branching
		dest:= '0' & inst_in(2 downto 0); --rd
		else
      pc_en<='0';
		end if;		
		
		 if(inst_in(15 downto 13)="000") then -- data processing operations
		    cpsr_en<='1';
			 mem_rd<='0';
			 mem_wr<='0';
			 stck_ram<='Z';
			   if(inst_in(12 downto 10)="000") then -- LSL
				  barrel_shift <= shift;
				  inp2_addr <= inp2;
				  inp1_addr<="ZZZZ";
				  mux_imm<='0';-- register operand selected
				  barr_sel<= "00";
				  wr<='1';
				  wr_addr <= dest;
				  alu_select<="0011";
			   elsif(inst_in(12 downto 10)="001") then -- LSR
				  barrel_shift <= shift;
			     inp2_addr <= inp2;
				  inp1_addr<="ZZZZ";
				  mux_imm<='0';
				  barr_sel<= "01";
				  wr<='1';
				  wr_addr <= dest;
				  alu_select <="0011";
			   elsif(inst_in(12 downto 10)="010") then -- ASL
				  barrel_shift <= shift;
			     inp2_addr <= inp2;
				  inp1_addr<="ZZZZ";
				  mux_imm<='0';
				  barr_sel<= "10";
				  wr<='1';
				  wr_addr <= dest;
				  alu_select<="0011";
			  elsif(inst_in(12 downto 10)="011") then -- ASR
				  barrel_shift <= shift;
			     inp2_addr <= inp2;
				  inp1_addr<="ZZZZ";
				  mux_imm<='0';
				  barr_sel<= "11";
              wr<='1';				
				  wr_addr <= dest;
				  alu_select<="0011";
			  elsif(inst_in(12 downto 10)="100") then -- ADD in register addressing
              inp1_addr <= inp1;
				  inp2_addr <= inp2;
				  mux_imm<='0';
					barrel_shift<="0000"; -- no shift required
				  alu_select<="0000"; --ADD
				  wr<='1';
				  wr_addr <= dest;	
			  elsif(inst_in(12 downto 10)="101") then --SUB in register addressing
	           inp1_addr <= inp1;
				  inp2_addr <= inp2;
				  mux_imm<='0';
					barrel_shift<="0000";
				  alu_select<="0001"; -- SUB 
				  wr_addr <= dest;
				  wr<='1';
			  elsif(inst_in(12 downto 10)="110") then -- ADD in immed addressing
				  alu_select <="0000"; -- ADD
				  imm_data <= "0000000000000" & imm_data3;
				  mux_imm <='1';   -- immediate operand selected
				
				  pc_sign<="00"; -- 3 bit offset
				  barrel_shift <="0000";
				  inp1_addr <= inp2;
			     inp2_addr<="ZZZZ";
				  wr_addr <= dest;	
				  wr<='1';
			  elsif(inst_in(12 downto 10)="111") then -- SUB in immed addressing
				  alu_select<="0001"; -- SUB
				  mux_imm<='1'; -- immediate operand selected
				 
				  pc_sign<="00";-- 3 bit offset
				  imm_data<= "0000000000000" & imm_data3;
				  barrel_shift<="0000";
				  inp1_addr <= inp2;
				  inp2_addr<="ZZZZ";
				  wr_addr <= dest;
				  wr<='1';
		     else
				  alu_select <="ZZZZ";
				  inp1_addr <= "ZZZZ";
				  inp2_addr <= "ZZZZ";
				  wr<='Z';
				  barrel_shift<="ZZZZ";
				  wr_addr<="ZZZZ";
				  mux_imm <='Z';
				  pc_sign<="ZZ";
				  cpsr_en<='Z';
			     mem_rd<='0';
			     mem_wr<='0';
			     stck_ram<='Z';
			  end if;
			
		  elsif(inst_in(15 downto 13)="001") then -- ADD/SUB/CMP/MOV in immed addressing 8 bit immd data
	        cpsr_en<='1';
			  mem_rd<='0';
			  mem_wr<='0';
			  stck_ram<='Z';
			   if(inst_in(12 downto 11) ="00") then
			     alu_select <="0000"; --ADD
				  imm_data <="00000000" & imm_data8;
				  inp1_addr <= inp3; 
				  inp2_addr <= "ZZZZ";
				  mux_imm <='1'; -- immediate operand selected
				  pc_sign<="10";-- 8 bit offset
				  barrel_shift <="0000";
				  wr<='1';
				  wr_addr <= inp3;
			   elsif(inst_in(12 downto 11) = "01" ) then 
              alu_select<="0001"; --SUB
				  imm_data<="00000000" & imm_data8;
				  inp1_addr <= inp3;
				  inp2_addr <= "ZZZZ";
				  mux_imm<='1';
				  pc_sign<="10";
				  barrel_shift<="0000";
				  wr<='1';
				  wr_addr <= inp3;
			   elsif(inst_in(12 downto 11) ="10") then 
			     alu_select<="0010"; --COMPARE
				  imm_data<="00000000" & imm_data8;
				  inp1_addr <= inp3;
				  inp2_addr <="ZZZZ";
				  mux_imm<='1';
				  pc_sign<="10";
				  barrel_shift<="0000";
				  wr<='0';
			   elsif(inst_in(12 downto 11) ="11") then 
			     alu_select<="0011"; --MOV
				  cpsr_en<='0';
				  imm_data<="00000000" & imm_data8;
				  inp1_addr <= inp3;
				  inp2_addr <= "ZZZZ";
				  mux_imm<='1';
				  pc_sign<="10";
				  barrel_shift<="0000";
				  wr<='1';
				  wr_addr <= inp3;
			   else 
			     alu_select<="ZZZZ";
				  inp1_addr <= "ZZZZ";
				  inp2_addr <= "ZZZZ";
				  barrel_shift<="ZZZZ";
				  mux_imm<='Z';
				  wr<='Z';
				  wr_addr <= "ZZZZ";
				  pc_sign<="ZZ";
				  cpsr_en<='Z';
				  mem_rd<='0';
			     mem_wr<='0';
			     stck_ram<='Z';
			   end if;
		
		
		  elsif(inst_in(15 downto 13)="010") then -- Data transfer operations Load/Store
		     cpsr_en<='0';
		       if(inst_in(12 downto 10)="110") then --Load with reg as offset
			      inp1_addr <= inp1;
			      inp2_addr <= inp2;
				   mux_imm<='0';	
				   barrel_shift<="0000";
				   alu_select <= "0000"; --ADD contents of rn and rm to form the 16 bit mem addr
				   wr<='1';
				   wr_addr <= dest;
				   stck_ram<='0';
				   mem_rd <='1';
				   mem_wr <='0';
			    elsif(inst_in(12 downto 10)="100") then --Store with reg as offset
			      inp1_addr <= inp1;
			      inp2_addr <= inp2;
				   mux_imm<='0';	
				   barrel_shift<="0000";
				   alu_select <= "0000"; --ADD contents of rn and rm to form the 16 bit mem addr
				   wr<='0';
				   inp3_addr <= dest;
				   mem_rd<='0';
				   mem_wr<='1';
				   stck_ram<='0';
			    elsif(inst_in(12 downto 10)="001") then
                 stck_ram<='Z';
					  mem_rd<='0';
					  mem_wr<='0';
					   if(inst_in(9 downto 8)="00") then -- ADD contents of any of the registers from R0-R15
				        inp1_addr <= ((inst_in(7) & "000") or inp2);
				        inp2_addr <= ((inst_in(6) & "000") or dest);
				        alu_select<="0000";
				        mux_imm<='0';
				        barrel_shift<="0000"; -- no shift required
				        alu_select<="0000"; --ADD
				        wr<='1';
				        wr_addr <= ((inst_in(6) & "000") or dest);
						  cpsr_en<='1';
					   elsif(inst_in(9 downto 8)="10") then --MOV  contents of any of the registers from R0-R15
					     cpsr_en<='0';
				        inp2_addr <= ((inst_in(7) & "000") or inp2);
				        inp1_addr <= "ZZZZ";
				        alu_select<="0011";
				        mux_imm<='0';
				        barrel_shift<="0000"; -- no shift required
				        alu_select<="0000"; --ADD
				        wr<='1';
				        wr_addr <= ((inst_in(6) & "000") or dest);
					   end if;
						
					   
				
			elsif(inst_in(12 downto 10)="000") then--Logical operations
					 mem_rd <='0';
					 mem_wr <='0';
					 cpsr_en<='1';
					 stck_ram<='Z';
			       if(inst_in(9 downto 6)="0000") then ---AND
			          inp2_addr <= inp2;
				       inp1_addr <= dest;
				       mux_imm<='0';
				       barrel_shift<="0000";
				       alu_select<= "0100"; ---AND contents of rn and rd
                   wr<='1';						 
				       wr_addr <= dest;
					 elsif(inst_in(9 downto 6)="0001") then -- EXOR
						 inp2_addr <= inp2;
				       inp1_addr <= dest;
				       mux_imm <= '0';
				       barrel_shift<="0000";
				       alu_select<= "0101"; ---ExOR contents of rn and rd  
						 wr<='1';
				       wr_addr <= dest;
					 elsif(inst_in(9 downto 6)="1100") then -- OR
						 inp2_addr <= inp2;
				       inp1_addr <= dest;
				       mux_imm<='0';
				       barrel_shift<="0000";
				       alu_select<= "0110"; ---OR contents of rn and rd 
						 wr<='1';
				       wr_addr <= dest;
					 elsif(inst_in(9 downto 6)="1111") then -- MVN
						 inp2_addr <= inp2;
				       mux_imm<='0';
			          barrel_shift<="0000";
				       alu_select<= "0111"; -- Complement
						 wr<='1';
				       wr_addr <= dest;
						 cpsr_en<='0';
					 elsif(inst_in(9 downto 6)="1101") then -- MUL
					    cpsr_en<='1';
						 inp2_addr <= inp2;
						 inp1_addr <= dest;
				       mux_imm<='0';
			          barrel_shift<="0000";
				       alu_select<= "1000"; -- Multiply contents of rn and rd
						 wr<='1';
				       wr_addr <= dest;	 
					 elsif(inst_in(9 downto 6)="0101") then -- ADC
					    cpsr_en<='1';
						 inp2_addr <= inp2;
						 inp1_addr <= dest;
				       mux_imm<='0';
			          barrel_shift<="0000";
				       alu_select<= "1001"; -- Add contents of rd and rn along with carry
						 wr<='1';
				       wr_addr <= dest;	 
					elsif(inst_in(9 downto 6)="0110") then -- SBC
					    cpsr_en<='1';
						 inp2_addr <= inp2;
						 inp1_addr <= dest;
				       mux_imm<='0';
			          barrel_shift<="0000";
				       alu_select<= "1010"; -- Sub contents of rd and rn along with carry
						 wr<='1';
				       wr_addr <= dest;	 
			       else 
				       alu_select<="ZZZZ";
				       inp1_addr <= "ZZZZ";
				       inp2_addr <= "ZZZZ";
				       barrel_shift<="ZZZZ";
				       wr<='0';
				       mux_imm<='Z';
						 cpsr_en<='Z';
			      end if;
			else 
				  alu_select<="ZZZZ";
				  inp1_addr <= "ZZZZ";
				  inp2_addr <= "ZZZZ";
				  barrel_shift<="ZZZZ";
				  wr<='0';
				  mux_imm<='Z';
				  mem_rd<='0';
				  mem_wr<='0';
				  stck_ram<='Z';
				  cpsr_en<='Z';
			end if;
				
		elsif(inst_in(15 downto 13)="011") then 
			cpsr_en<='0';
			pc_sign<="01"; -- 5 bit offset
		      if(inst_in(12 downto 11)="01") then --Load with immd as offset
				   inp1_addr <= inp1;
				   imm_data <= "00000000000" & imm_data5;
				   mux_imm<='1'; 
				   barrel_shift<="0010";--immd value multiplied by 4
				   alu_select <= "0000"; --ADD contents of rm and rotated immd value to form the 16 bit mem addr
					wr<='1';
					wr_addr <= dest;
					mem_rd<='1';
					mem_wr<='0';
					stck_ram<='0';
				 elsif(inst_in(12 downto 11)="00") then --Store with immd as offset
					inp1_addr <= inp1;
				   imm_data <= "00000000000" & imm_data5;
				   mux_imm<='1'; 
				   barrel_shift<="0010";--immd value multiplied by 4
				   alu_select <= "0000"; --ADD contents of rm and rotated immd value to form the 16 bit mem addr
					wr<='0';
					inp3_addr <= dest;
					mem_rd<='0';
					mem_wr<='1';
					stck_ram<='0';
		       else
				   alu_select<="ZZZZ";
				   inp1_addr <= "ZZZZ";
				   inp2_addr <= "ZZZZ";
				   barrel_shift<="ZZZZ";
				   wr<='0';
				   mux_imm<='Z';
					stck_ram<='Z';
					mem_wr<='0';
					mem_rd<='0';
					pc_sign<="ZZ";
					cpsr_en<='Z';
			    end if;
					
		elsif(inst_in(15 downto 13)="101") then ---Stack operations
				 mem_rd<='0';
				 mem_wr<='0';
				 cpsr_en<='0';
		    if(inst_in(12 downto 10)="110")  then --PUSH
			    mem_rd<='0';
				 mem_wr<='0';
				 wr<='0';
				 alu_select<="0011";
			    temp:=imm_data8;
			       if(i/=-1) then
						  if (imm_data8(i)='1') then
							stck_ram<='1';
							push<='1';
							pop<='0';
							inp2_addr <= std_logic_vector(to_unsigned(i,4));
						  elsif(imm_data8(i)='0') then
							stck_ram <= 'Z';
							push<='0';
							pop<='0';
						  else
							stck_ram <= 'Z';
							push<='0';
						  end if;
					     i:=i-1;
					  end if;
				    if(i=-1) then 
				      i:=7;
				    end if;
				 
			 elsif(inst_in(12 downto 10)="001") then --Breakpoint
				 alu_select<="ZZZZ";
				 mux_imm<='Z';
				 --inst_enable<= '0';
				 inp1_addr<="ZZZZ";
				 inp2_addr<="ZZZZ";
					pc_en<='0';
					hlt:='0';
				 
			 elsif(inst_in(12 downto 10)="101") then --nop
				 alu_select<="ZZZZ";
				 mux_imm<='Z';
				 inp1_addr<="ZZZZ";
				 inp2_addr<="ZZZZ";
				 mem_rd<='Z';
				 mem_wr<='Z';				
				 wr<='Z';
				 wr_addr<="ZZZZ";
				 pop<='Z';
				 push<='Z';
				 stck_ram<='Z';
				
			 elsif(inst_in(12 downto 10)="010") then -- MOV in register mode
				alu_select<="0011"; --MOV
				inp2_addr <= inp2;
				inp1_addr <="ZZZZ";
				mux_imm<='0';
				barrel_shift<="0000";
				wr<='1';
				wr_addr <= dest;
				stck_ram<='Z';
				
			elsif(inst_in(12 downto 10)="111") then --POP
				wr<='0';
				alu_select<="0011";
			       if(j/=8) then
					    if(imm_data8(j)='1') then
						   stck_ram<='1';
						   pop<='1';
						   push<='0';
						   inp2_addr <= std_logic_vector(to_unsigned(j,4));
				       elsif(imm_data8(j)='0') then
						   stck_ram<='Z';
						   pop<='0';
						   push<='0';
				       else
						   stck_ram<='Z';
						   pop<='0';
						   push<='0';
				       end if;
						   j:=j+1;
				    end if;	
		              if(j=8) then
					       j:=0;
		              end if;
			end if;
				
		  
		  elsif(inst_in(15 downto 13)="111") then
            cpsr_en<='0';		  
			   stck_ram<='Z';
				mem_rd<='0';
				mem_wr<='0';
		      if(inst_in(12 downto 11)="00") then--unconditional 11 bit immediate branch
					mux_imm<='1';
					inp1_addr<="1111";
					imm_data<="00000" & imm_data11;
					barrel_shift<="0000"; --left shift by one 
					alu_select<="0000";--Handle address calculation
					pc_sign<="11";
					wr<='1';
					wr_addr<="1111";  -- program counter
			   else
					mux_imm<='Z';
					imm_data<="ZZZZZZZZZZZZZZZZ";
					alu_select<="ZZZZ";
					wr_addr<="ZZZZ";
               pc_sign<="ZZ";	
					inp1_addr<="ZZZZ";
					stck_ram<='Z';
					mem_rd<='0';
					mem_wr<='0';
					wr<='Z';
					barrel_shift<="ZZZZ";
					cpsr_en<='Z';
			   end if;
					
		  elsif(inst_in(15 downto 13)="110") then
		       stck_ram<='Z';
				 mem_rd<='0';
				 mem_wr<='0';
		        if(inst_in(12)='1') then --conditional branch
			       cpsr_en<='0';
					    if(inst_in(11 downto 8)="0000") then
						     if(zero='1') then --check the flag
							    mux_imm<='1';
							    barrel_shift<="0000";
							    inp1_addr<="1111";
							    wr<='1';
							    imm_data<="00000000" & imm_data8;
						      
							    pc_sign<="10";
							    alu_select<="0000";
							    wr_addr<="1111";  -- program counter
						      else 
							    mux_imm<='Z';
							    imm_data<="ZZZZZZZZZZZZZZZZ";
							    alu_select<="ZZZZ";
							    wr_addr<="ZZZZ";
							    pc_sign<="ZZ";	
							    inp1_addr<="ZZZZ";
							  
							    wr<='Z';
							    barrel_shift<="ZZZZ";
						      end if;
					elsif(inst_in(11 downto 8)="0001") then -- one condition MAYBE CARRY
					      if(carry ='1') then
								mux_imm<='1';
								barrel_shift<="0000";
								wr<='1';
								imm_data<="00000000" & imm_data8;
							
								pc_sign<="10";
								inp1_addr<="1111";
								alu_select<="0000";
								wr_addr<="1111";  -- program counter
						   else
								mux_imm<='Z';
								barrel_shift<="ZZZZ";
								wr<='Z';
								imm_data<="00000000" & imm_data8;
								
								pc_sign<="ZZ";
								inp1_addr<="ZZZZ";
								alu_select<="ZZZZ";
								wr_addr<="ZZZZ";  -- program counter
						   end if;
					elsif(inst_in(11 downto 8)="0010") then --negative
						   if(negative ='1') then
								mux_imm<='1';
								barrel_shift<="0000";
								wr<='1';
								imm_data<="00000000" & imm_data8;
								
								pc_sign<="10";
								inp1_addr<="1111";
								alu_select<="0000";
								wr_addr<="1111";  -- program counter
						   else
								mux_imm<='Z';
								barrel_shift<="ZZZZ";
								wr<='Z';
								imm_data<="ZZZZZZZZZZZZZZZZ";
								
								pc_sign<="ZZ";
								inp1_addr<="ZZZZ";
								alu_select<="ZZZZ";
								wr_addr<="ZZZZ";  -- program counter
							end if;
					elsif(inst_in(11 downto 8)="0011") then -- jump if no carry
						   if(carry='0') then
								mux_imm<='1';
								barrel_shift<="0000";
								wr<='1';
								imm_data<="00000000" & imm_data8;
							
								pc_sign<="10";
								inp1_addr<="1111";
								alu_select<="0000";
								wr_addr<="1111";  -- program counter
						   else
								mux_imm<='Z';
								barrel_shift<="ZZZZ";
								wr<='Z';
								imm_data<="ZZZZZZZZZZZZZZZZ";
								inp1_addr<="ZZZZ";
								alu_select<="ZZZZ";
								wr_addr<="ZZZZ";  -- program counter
                     end if;

		          else
					    mux_imm<='Z';
					    imm_data<="ZZZZZZZZZZZZZZZZ";
					    alu_select<="ZZZZ";
					    inp1_addr<="ZZZZ";
					    wr_addr<="ZZZZ";  -- program counter
					    wr<='0';
						 barrel_shift<="ZZZZ";
			       end if;
		      end if;
		else
			alu_select<="ZZZZ";
		   inp1_addr <= "ZZZZ";
			inp2_addr <= "ZZZZ";
			wr_addr<="ZZZZ";
			imm_data<="ZZZZZZZZZZZZZZZZ";
			stck_ram<='Z';
			wr<='0';
			mux_imm<='Z';
			pc_sign<="ZZ";
			barrel_shift<="ZZZZ";
			mem_rd<='0';
			mem_wr<='0';
			cpsr_en<='Z';
		
		end if;
		
	end if;


end process;

clk_out<=clk;
end Behavioral;
 
