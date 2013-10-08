-- File: network.vhdl
-- Philip Watts, UCL, June 2012
--
-- An example of a network structure in VHDL to interface
-- with the top level code 'net_emulation'

LIBRARY ieee;
USE     ieee.std_logic_1164.ALL;

entity network is
    Generic (
            PORTS : integer := 16;
            DEST_WIDTH : integer := 4;
            FIFO_DEPTH : integer := 4;
            PAYLOAD : integer := 32);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           din : in  STD_LOGIC_VECTOR (PORTS*(PAYLOAD+(2*DEST_WIDTH)+1)-1 downto 0);
           dout : out  STD_LOGIC_VECTOR (PORTS*(PAYLOAD+(2*DEST_WIDTH)+1)-1 downto 0);
           full : out  STD_LOGIC_VECTOR(PORTS-1 downto 0));
end network;

architecture Behavioral of network is

begin
  
  -- Internal signals
  
  
  -- Break din/dout into an array for easier management
  type pkt_array is array (0 to PORTS-1) of std_logic_vector(PAYLOAD+(2*DEST_WIDTH) downto 0);
  signal packets : pkt_array;
  
  -- This is the 1st fifo full signal to be routed back to the packet generator
  -- (currently always accepts packets)
  full <= (others => '0');

  -- A trivial network! (delivers packets incorrectly)
  test_reg: process (clk) is 
  begin
      if clk = '1' then
        dout <= din;
      end if;
  end process test_reg;  

end Behavioral;