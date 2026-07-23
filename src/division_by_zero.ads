with Interfaces.C;
with System;

package Division_By_Zero is
   procedure Calculate (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   );
   pragma Export (C, Calculate, "calculate");
end Division_By_Zero;
