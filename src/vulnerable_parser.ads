with Interfaces.C;
with System;

package Vulnerable_Parser is
   procedure Parse_From_C (
      Data_Address : in System.Address;
      Data_Length  : in Interfaces.C.size_t
   );
   pragma Export (C, Parse_From_C, "parse_from_c");
end Vulnerable_Parser;
