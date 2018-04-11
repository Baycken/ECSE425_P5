library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_stage_tb is
end mem_stage_tb;

architecture behavior of mem_stage_tb is

component mem_stage is
port(
		reset : in std_logic;
		clk : in std_logic;

		--execution stage communication
		ex_result: in std_logic_vector(31 downto 0);
		ex_dest_reg : in std_logic_vector(31 downto 0);	
		ex_load : in std_logic;
		ex_store : in std_logic;

		--writeback stage communication
		wb_data : out std_logic_vector(31 downto 0);
		wb_dest_reg : out std_logic_vector(31 downto 0);

		--cache memory communication
		mem_read_data : in std_logic_vector (31 downto 0);
		mem_waitrequest : in std_logic;
		mem_write : out std_logic;
		mem_read : out std_logic;
		mem_addr : out std_logic_vector(31 downto 0);
		mem_write_data : out std_logic_vector (31 downto 0);

		--memory stall
		stall : out std_logic
);
end component;

component cache IS
	GENERIC(
		ram_size : INTEGER := 32768
	);
	PORT (
		clock: IN STD_LOGIC;
		reset: IN STD_LOGIC;

		s_address: in std_logic_vector (31 downto 0);
		s_memread: in std_logic;	
		s_readdata: out std_logic_vector (31 downto 0);
		s_memwrite: in std_logic;
		s_writedata: in std_logic_vector (31 downto 0);
		s_waitrequest: out std_logic; 
		

		m_address: in integer RANGE 0 TO 8191;
		m_memread: in std_logic;	
		m_readdata: out std_logic_vector (31 downto 0);
		m_memwrite: in std_logic;
		m_writedata: in std_logic_vector (31 downto 0);
		m_waitrequest: out std_logic
	);
end component;
component memory IS
	GENERIC(
		ram_size : INTEGER := 32768;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO ram_size-1;
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest: OUT STD_LOGIC
	);
end component;
signal reset : std_logic;
signal clk : std_logic;

--execution stage communication
signal ex_result: std_logic_vector(31 downto 0);
signal ex_dest_reg : std_logic_vector(31 downto 0);	
signal ex_load : std_logic;
signal ex_store : std_logic;

--writeback stage communication
signal wb_data : std_logic_vector(31 downto 0);
signal wb_dest_reg : std_logic_vector(31 downto 0);

--data memory communication

signal cache_read_data : std_logic_vector (31 downto 0);
signal cache_waitrequest : std_logic;
signal cache_write : std_logic;
signal cache_read : std_logic;
signal cache_addr : std_logic_vector (31 downto 0);
signal cache_write_data : std_logic_vector (31 downto 0);

signal mem_read_data : std_logic_vector (31 downto 0);
signal mem_waitrequest : std_logic;
signal mem_write : std_logic;
signal mem_read : std_logic;
signal mem_addr : integer:=0;
signal mem_write_data : std_logic_vector (31 downto 0);



signal stall : std_logic;

constant clk_period : time := 2 ns;

begin

dut: mem_stage
port map(
	clk => clk,
	reset =>reset,
	ex_result=>ex_result,
	ex_dest_reg=>ex_dest_reg,
	ex_load=>ex_load,
	ex_store=>ex_store,
	wb_data=>wb_data,
	wb_dest_reg=>wb_dest_reg,
	mem_read_data=>cache_read_data,
	mem_waitrequest=>cache_waitrequest,
	mem_write=>cache_write,
	mem_read=>cache_read,
	mem_addr=>cache_addr,
	mem_write_data=>cache_write_data,
	stall=>stall
);

cac: cache
port map(
	clock=>clk,	
	reset=>reset,
	s_writedata=>cache_write_data,
	s_address=>cache_addr,
	s_memwrite=>cache_write,
	s_memread=>cache_read,
	s_readdata=>cache_read_data,
	s_waitrequest=>cache_waitrequest,
	
	m_address=>mem_addr,
	m_memread=>mem_read,
	m_readdata=>mem_read_data,
	m_memwrite=>mem_write,
	m_writedata=>mem_write_data,
	m_waitrequest=>mem_waitrequest
);
mem: memory
port map(
	clock=>clk,
	writedata=>mem_write_data,
	address=>mem_addr,
	memwrite=>mem_write,
	memread=>mem_read,
	readdata=>mem_read_data,
	waitrequest=>mem_waitrequest
);
clk_process : process
begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
end process;

test_process: process
begin
	--initialize
	reset<='1';
	wait for clk_period;
	reset<='0';
	
	wait for clk_period/2;

	--test passing info from ex to wb PASS
	wait for clk_period;
	ex_result<=x"00000044";
	ex_dest_reg<=x"00000002";
	wait for clk_period;
	ex_result<=x"00000022";
	ex_dest_reg<=x"00000003";
	wait for clk_period;
	ex_result<=x"00000000";
	ex_dest_reg<=x"00000000";
	wait for clk_period;

	--test store:write x"00001234" to 12 PASS
	ex_store<='1';
	ex_result<=x"00001234";
	ex_dest_reg<=x"00000012";
	wait for clk_period;
	ex_store<='0';
	ex_result<=x"00000000";
	ex_dest_reg<=x"00000000";
	wait for clk_period;

	--test load: read from 12 PASS
	ex_load <= '1';
	ex_result<=x"00000012";
	ex_dest_reg<=x"00000011";
	wait for clk_period;
	ex_load <= '0';
	ex_result<=x"00000000";
	ex_dest_reg<=x"00000000";
	wait for clk_period;

	wait;

end process;
end;