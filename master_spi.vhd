	 LIBRARY IEEE;
		USE IEEE.STD_LOGIC_1164.ALL;
		USE IEEE.NUMERIC_STD.ALL;

	ENTITY master_spi IS
		PORT (clk :	IN 	STD_LOGIC;
			  rst : IN STD_LOGIC;
			  rts : IN STD_LOGIC;
			  miso: IN STD_LOGIC;
			  mosi: OUT STD_LOGIC;
			  baud: IN STD_LOGIC;
			  sck : OUT STD_LOGIC;
			  ss : OUT STD_LOGIC;
			  data_Tx : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			  data_Rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
			 );
	END ENTITY;

	ARCHITECTURE behave OF master_spi IS
		TYPE state IS ( IDLE, START, DATASEND );
		SIGNAL SpiState : state;
		SIGNAL BClk : STD_LOGIC;
		SIGNAL MasterRegRx : unsigned(7 downto 0);
		SIGNAL MasterRegTx : unsigned(7 downto 0);
		SIGNAL load : STD_LOGIC;
		SIGNAL count : integer range 0 to 9;
		CONSTANT ClkFreq :integer := 50000000;
		CONSTANT Clk_1 :integer := 5000000;
		CONSTANT Clk_2 :integer := 3000000; --Default Frequency, To change the frequency change baud signal to '1' 
		SIGNAL BaudCount : integer;
		SIGNAL clkcount : integer;
		
		SIGNAL FsmTicks : integer range 0 to 9;	
		BEGIN 
	BaudCount <= (ClkFreq / Clk_1) when baud = '1' else (ClkFreq / Clk_2);
	--sck <= BClk when ss = '0' else '1';
----------------------------------------------------------------------------------
--				SCK Generator
---------------------------------------------------------------------------------
  DesSCK:  process(rst,clk)
			begin
			if(rst = '1')then
				clkcount <= 0;
				BClk <= '1';
				
			elsif(rising_edge(clk) )then
				if(clkcount = BaudCount)then
					BClk <= not(BClk);
					clkcount <= 0;
				else
					clkcount <= clkcount + 1;
				end if;
				if(ss = '0')then
					sck <= BClk;
				else
					sck <= '1';
				end if;
			end if;
		end process DesSCK;				
				
----------------------------------------------------------------------------------
--				FSM
----------------------------------------------------------------------------------
  FSM:	process(rst,BClk,SCK)
			begin
			if(rst = '1')then
				SpiState <= IDLE;
				mosi <= '1';
				ss <= '1';
				count <= 0;
				MasterRegRx <= "00000000";
			elsif(falling_edge(BClk))then
				case(SpiState) is
					when IDLE => 
						if(rts = '0')then
							SpiState <= IDLE;
							ss <= '1'; 
							load <= '1'; 
							
						--assert('0') report"load is 0" severity note;
						else 
						 ss <= '0';
						 
						 load <= '0';
						--assert('0') report"load is 1" severity note;
							SpiState <= DATASEND;
						end if;
--					when START =>
--						 ss <= '0';

--						 load <= '0';
--						 SpiState <= DATASEND;
					when DATASEND => 
							if(count = 9)then
								mosi <= MasterRegTx(7); ---TX 
								MasterRegRx <= ( miso & MasterRegRx(7 downto 1));-- Rx
								SpiState <= IDLE;
								data_Rx <= std_logic_vector(MasterRegRx);
	--					  	elsif(count = 9)then
	--							data_Rx <= std_logic_vector(MasterRegRx);
							else
								mosi <= MasterRegTx(7);
								MasterRegRx <= (miso & MasterRegRx(7 downto 1));
								SpiState <= DATASEND;
							end if;
					when others => SpiState <= IDLE;
				end case;
		---------------------------
---				SHIFT REG
		---------------------------		
				if(load = '1')then
					MasterRegTx <= unsigned(data_Tx);
				else 
					if(count = 9)then
						count <= 0;
				  	else
						MasterRegTx <= shift_left(MasterRegTx,1);	
						count <= count + 1;					
					end if;
				end if;
			end if;
-----------------------------------------------------
----				FSM Counter
-----------------------------------------------------
-- --Counter: process(rst,sck)			
--		-- begin
--			if(rst = '1')then
--				FsmTicks <= 0;
--				
--			elsif(falling_edge(SCK) )then
--				
--				if(FsmTicks = 9)then
--					--BClk <= not(BClk);
--					FsmTicks <= 0;
--				else
--					FsmTicks <= FsmTicks+ 1;
--				end if;
--			end if;
--		--end process Counter;
		end process;
end behave;