library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fetch is
generic(
	ram_size : INTEGER := 32768
);
port(
	clock : in std_logic;
	reset : in std_logic;
		if_id_test: out std_logic_vector(31 downto 0);

	--communication with pc (getting and sending back the incremented one or the completely new pc)
	addr : in std_logic_vector (31 downto 0);
	--reply_back_pc : out std_logic_vector (31 downto 0);
	--test
	
	--just used to connect the instructionMemory in instructionFetch (so we can leave them floating in the instructionMemory)
	--s_write : in std_logic; --not using
	s_writedata : in std_logic_vector (31 downto 0); --not using 
	
	--communication with ID stage
	hazard_detect : in std_logic:='0';

	--communication with EX stage
	ex_is_new_pc : in std_logic:='0';
	ex_pc : in std_logic_vector(31 downto 0);

	--communication with decode stage (**no need to write so comment)
	instruction : out std_logic_vector(31 downto 0);
	--instruction_read : out std_logic;
	current_pc_to_dstage : out std_logic_vector(31 downto 0)
);

end fetch;

architecture arch of fetch is

--declarations
signal pc_address : INTEGER RANGE 0 TO 1023:=to_integer(unsigned(addr));
signal instruction_read_sig : std_logic:='0';
signal wait_req : std_logic;
--signal s_write_sig : std_logic:='0';
signal data : std_logic_vector(31 downto 0);
signal program : std_logic_vector(31 downto 0):=x"20010003";

component instr_mem
    GENERIC(
		ram_size : INTEGER := 32768;
		mem_delay : time := 10 ns;
		clock_period : time := 1 ns
	);
	PORT (
		clock: IN STD_LOGIC;
		writedata: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		address: IN INTEGER RANGE 0 TO 1023;
		memwrite: IN STD_LOGIC;
		memread: IN STD_LOGIC;
		readdata: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		waitrequest: OUT STD_LOGIC
	);
end component;

begin

U1: component instr_mem port map (clock,s_writedata,pc_address,'0',instruction_read_sig,data,wait_req);
	
inst_get: process (clock)
variable pc : integer:=0;
begin
	if (clock'event and clock='1') then 
		instruction <= program;
		if_id_test <= program;
		current_pc_to_dstage<= std_logic_vector(to_unsigned(pc, current_pc_to_dstage'length));
		pc:=pc+1;
	end if;
end process;
end arch;
