library ieee;
use ieee.std_logic_1164.all;

entity interrupt_logic is
port(
  interrupt1_i   : in  std_logic;
  interrupt2_i   : in  std_logic;
  interrupt_en_i : in  std_logic;
  interrupt_o    : out std_logic
);
end interrupt_logic;

architecture arch of interrupt_logic is
begin
  interrupt_o <= interrupt_en_i and (interrupt1_i or interrupt2_i);
end arch;
