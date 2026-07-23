with Interfaces.C;
with System;

package Null_Pointer is
   procedure Process_Data (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   );
   pragma Export (C, Process_Data, "process_data");
end Null_Pointer;
