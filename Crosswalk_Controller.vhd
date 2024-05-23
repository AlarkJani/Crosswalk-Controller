-- Project Title: Crosswalk Controller
-- Created on   : 04/03/2023
-- Created by   : Alark Jani
-- Overview     : VHDL Code stating 3 states where crosswalk light is designed
--					 : for pedestrian which can be initiated by push button with a
--					 :	counter which allows some seconds to change the red to green light.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Crosswalk_Controller is
 port ( sw : in STD_LOGIC; 						-- Reset for Push Button
        clk  : in STD_LOGIC;                 -- clock for Push button
		  HEX : out STD_LOGIC_VECTOR(6 downto 0);   -- HEX[0] for counter
		  HEX1 : out STD_LOGIC_VECTOR (6 downto 0); -- HEX[5] for GO/Stop
        LED_out: out STD_LOGIC_VECTOR(2 downto 0) -- LED for traffic Lights
   );
end Crosswalk_Controller;

architecture crosswalk of Crosswalk_Controller is 
	type 	state_variables is (green ,green_wait,yellow,yellow_wait,red,red_wait);
		signal CLK_DIV : STD_LOGIC;														-- Clock input
		signal state : state_variables;
		signal currentState : STD_LOGIC;
		signal nextStage: STD_LOGIC;								                	-- next stage
		signal count : STD_LOGIC_VECTOR(3 DOWNTO 0);                       	-- counter 
		signal crosswalk_timer : STD_LOGIC_VECTOR(3 downto 0):="0000";     	-- crosswalk timer
		constant GREEN_WAIT_COUNT : STD_LOGIC_VECTOR(3 downto 0) :="0011"; 	-- green wait
		constant YELLOW_WAIT_COUNT : STD_LOGIC_VECTOR(3 downto 0) :="0101"; 	-- yellow wait
		constant RED_WAIT_COUNT : STD_LOGIC_VECTOR(3 downto 0) :="1010";
		signal counter_1s : std_logic_vector(27 downto 0):= x"0000000";
		
		
		begin 
		process(clk)                                                       -- clock
		begin
		if rising_edge(CLK_DIV) then 
			case state is 
				when green =>																 -- green
						crosswalk_timer <= "0001";
						if sw ='1' then 
						state <= green;
						else 
						state <= green_wait;
						count <= x"1";
						end if;
				when green_wait =>
						crosswalk_timer <="0001";
						crosswalk_timer <= crosswalk_timer+1;
						if count < GREEN_WAIT_COUNT then
						state <= green_wait;
						count <= count+1;
						else 
						state <= yellow;
						count <= x"1";
						end if;
				when yellow =>																-- yellow
						crosswalk_timer <= "0001";
						state <= yellow_wait;
						count <= x"1";
				when yellow_wait => 
						crosswalk_timer <= "0110";
						crosswalk_timer <= crosswalk_timer+1;
						if count < YELLOW_WAIT_COUNT then
						state <= yellow_wait;
						count <= count+1;
						else
						state <= red;
						count <= x"1";
						end if;
				when red =>																   -- red
						crosswalk_timer <= "0001";
						state <= red_wait;
						count <= x"1";
				when red_wait => 
						if count <RED_WAIT_COUNT then 
						crosswalk_timer <= crosswalk_timer+1;
						state <= red_wait;
						count <= count+1;
						else
						crosswalk_timer <= "0000";
						state <= green;
						count <= x"1";
						end if;
					when others =>
						crosswalk_timer <="0000";
						state <= green;
					end case;
			end if;
		end process;
		
		crosswalk_controller : process(state)
		begin
			case state is 
				when green => LED_out <= "001";
				HEX1 <= "0010010";											-- GO light 
				when green_wait => LED_out <= "001";
				HEX1 <= "0010010";											-- GO light
				when yellow => LED_out <= "010";
				HEX1 <= "0010010";											-- S light
				when yellow_wait => LED_out <= "010";
				HEX1 <= "0010010";											-- S light
				when red=> LED_out <= "100";
				HEX1 <= "0010000";											-- S light
				when red_wait => LED_out <= "100";
				HEX1 <= "0010000";											-- S light
				when others => LED_out <= "001";
			end case;
		end process;

hexadecimal :process (crosswalk_timer)
		begin
		case crosswalk_timer is
			when "0000" => HEX <= "1111111"; 								-- "NULL"
			when "0001" => HEX <= "1000000"; 								-- "0"
			when "0010" => HEX <= "1111001"; 								-- "1"
			when "0011" => HEX <= "0100100"; 								-- "2"
			when "0100" => HEX <= "0110000"; 								-- "3"
			when "0101" => HEX <= "0011001"; 								-- "4"
			when "0110" => HEX <= "0010010"; 								-- "5"
			when "0111" => HEX <= "0000010"; 								-- "6"
			when "1000" => HEX <= "1111000"; 								-- "7"
			when "1001" => HEX <= "0000000"; 								-- "8"
			when "1010" => HEX <= "0010000"; 								-- "9"
			
			when others => HEX <= "0000000";
		end case;
	end process;
	
																						-- clock division process 
process(clk)
begin
if (rising_edge(clk)) then 
	counter_1s <= counter_1s + x"0000001";
	if (counter_1s >= x"2FAF080") 
then 
	counter_1s <= x"0000000";
end if ;
	if (counter_1s < x"2FAF080") then 
	CLK_DIV <= '0';
	else 
	CLK_DIV <= '1';
	end if;
end if ;
end process;
end crosswalk;
