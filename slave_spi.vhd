	LIBRARY IEEE;
		USE IEEE.STD_LOGIC_1164.ALL;
		USE IEEE.NUMERIC_STD.ALL;

	ENTITY slave_spi IS
		PORT (clk :	IN 	STD_LOGIC;
			  rst : IN STD_LOGIC;
			  sdo: OUT STD_LOGIC:= '1';
			  sdi: IN STD_LOGIC;
			  sck : IN STD_LOGIC;
			  ss : IN STD_LOGIC;
			  data_Tx : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			  data_Rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
			 );
	END ENTITY;

	ARCHITECTURE behave OF slave_spi IS
		TYPE state IS ( IDLE, START, DATATxRx );
		SIGNAL SpiState : state;
		SIGNAL load : STD_LOGIC;
		SIGNAL SlvRegRx : unsigned(7 downto 0);
		SIGNAL SlvRegTx : unsigned(7 downto 0);
		SIGNAL count : integer range 0 to 9;
		SIGNAL FsmTicks : integer range 0 to 9;
		
		BEGIN 
------------------------------------------------------------------------------------
----				FSM
------------------------------------------------------------------------------------
  FSM:	process(rst,sck)			
		 begin
			if(rst = '1')then
				SpiState <= IDLE;
				--SlvRegTx <= unsigned(data_Tx);
				load <= '1';
				SlvRegRx <= "00000000";
			elsif(falling_edge(sck))then
				case(SpiState) is
					when IDLE => 
						if(ss = '1')then
							SpiState <= IDLE;		
							--assert('0') report"Slaveload is 1" severity note;			  
						else
							load <= '0'; 
							SpiState <= DATATxRx;	
						    --assert(load= '1') report"Slaveload is 0" severity note;
							
						end if;
--					when START =>
--						 load <= '0';
--						 SpiState <= DATATxRx;
					when DATATxRx => 
							if(count = 8)then
								sdo <= SlvRegTx(7);
								SlvRegRx <= (sdi & SlvRegRx(7 downto 1));
								SpiState <= IDLE;
								data_Rx <= std_logic_vector(SlvRegRx);
						  	else
								sdo <= SlvRegTx(7);
								SlvRegRx <= (sdi & SlvRegRx(7 downto 1));
								SpiState <= DATATxRx;
							end if;
					when others => SpiState <= IDLE;
				end case;
				if(load = '1')then --load value is unchanged
					SlvRegTx <= unsigned(data_Tx);
				else 
					if(count = 8)then
						count <= 0;
				  	else
						SlvRegTx <= shift_left(SlvRegTx,1);	
						count <= count + 1;					
					end if;
				end if;
			end if;
		end process;
---------------------------------------------------
--				FSM Counter
---------------------------------------------------
 Counter: process(rst,sck)			
		 begin
			if(rst = '1')then
				FsmTicks <= 0;
				
			elsif(falling_edge(SCK) )then
				
				if(FsmTicks = 9)then
					--BClk <= not(BClk);
					FsmTicks <= 0;
				else
					FsmTicks <= FsmTicks+ 1;
				end if;
			end if;
		end process Counter;
end behave;
