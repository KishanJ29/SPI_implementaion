		 LIBRARY IEEE;
			USE IEEE.STD_LOGIC_1164.ALL;
			USE IEEE.NUMERIC_STD.ALL;
			use std.textio.all;
	entity test_spi is 
	end entity;

architecture test of test_spi is 
	COMPONENT master_spi IS
	PORT	(clk :	IN 	STD_LOGIC;
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
	end COMPONENT;
	COMPONENT slave_spi IS
		PORT (clk :	IN 	STD_LOGIC;
			  rst : IN STD_LOGIC;
			  sdo: OUT STD_LOGIC;
			  sdi: IN STD_LOGIC;
			  sck : IN STD_LOGIC;
			  ss : IN STD_LOGIC;
			  data_Tx : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			  data_Rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
			 );
	END COMPONENT;
	   signal CLK :STD_LOGIC;
	   signal rst :  STD_LOGIC;
	   signal rts_mas : STD_LOGIC;
	   signal miso_slv_mas: STD_LOGIC;
	   signal mosi_mas_slv: STD_LOGIC;
	   signal baud_mas: STD_LOGIC;
	   signal sck_mas_slv :  STD_LOGIC:= '1';
	   signal ss_mas_slv:  STD_LOGIC;
	   signal data_Tx_mas : STD_LOGIC_VECTOR(7 DOWNTO 0);
	   signal data_Rx_mas :STD_LOGIC_VECTOR(7 DOWNTO 0);
	   signal data_Rx_slv : STD_LOGIC_VECTOR(7 DOWNTO 0);
	   signal data_Tx_slv : STD_LOGIC_VECTOR(7 DOWNTO 0);
	
 

		BEGIN
	Master:	ENTITY 	work.master_spi port map( clk => CLK,
											  rst => rst,
											  rts => rts_mas,
											  miso=> miso_slv_mas,
											  mosi=> mosi_mas_slv,
											  baud=> baud_mas,
											  sck => sck_mas_slv,
											  ss => ss_mas_slv,
											  data_Tx => data_Tx_mas,
											  data_Rx => data_Rx_mas 
											);
	Slave: ENTITY work.slave_spi port map (   clk => CLK,
											  rst => rst,
											  sdo => miso_slv_mas,
											  sdi => mosi_mas_slv,
											  sck => sck_mas_slv,
											  ss => ss_mas_slv,
											  data_Tx => data_Tx_slv,
											  data_Rx => data_Rx_slv
											 );

	clockProcess: process
					begin 
				  	clk <= '1';wait for 1 ns;
					clk <= '0'; wait for 1 ns;
					
				  end process clockProcess;
-----------------------------------------------------------------------------------------
--							Test Vector
-----------------------------------------------------------------------------------------
	Testing: process
					  variable var1 : line;
					  variable var2 : line; 	 
						procedure test_vector (constant Mas_Data  :in  std_logic_vector(7 downto 0);
							constant Slv_Data : in std_logic_vector(7 downto 0))is
					begin
						rst <= '1'; 
						rts_mas <= '0';
						baud_mas <= '1';
						data_Tx_mas <= Mas_Data; 
						data_Tx_slv <= Slv_Data;
						wait for 100 ns;
						rst  <= '0';
						wait for 100 ns;
						rts_mas <= '1';-- wait for 15 ns;
						--rts_mas <= '0'; 
						 wait for 700 ns;
						write(var1, string'("Master->"));
						write(var1, data_Tx_mas);
						write(var1, string'(","));
						write(var1, string'("Slave->"));
						write(var1, data_Tx_slv);
						report "Testing Master and slave with "&var1.all;
						--wait on data_Tx_mas;
						if(data_Tx_mas = data_Rx_slv)then
							report" Master to Slave transaction Success" severity note;
						else
							report" Master to Slave transaction Failure" severity error;						
						end if;
						if(data_Tx_slv = data_Rx_mas)then
							report" Slave to Master transaction Success" severity note;
						else
							report" Slave to Master transaction Failure" severity error;						
						end if;
					wait;

	 end procedure;
	begin
--						rst <= '1'; 
--						rst  <= '0'after 50 ns;
--						rts_mas <= '0'; wait for 100 ns;
--						rts_mas <= '1';-- wait for 15 ns;
--						rts_mas <= '0'; 
--						baud_mas <= '1';
--						data_Tx_mas <= "11111111"; 
--						data_Tx_slv <= "11111111"; 
--						if(data_Tx_mas = data_Rx_slv)then
--							report" Master to Slave transaction Success" severity note;
--						else
--							report" Master to Slave transaction Failure" severity error;						
--						end if;
--					wait;
						--test_vector("11111111","11111111");
						wait for 1 us;
						test_vector("11100111","11111001");
						wait for 3 us;
						test_vector("11100101","10111001");
					end process;

	end test;
						
	