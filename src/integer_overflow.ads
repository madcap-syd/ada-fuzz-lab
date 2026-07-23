with Interfaces.C;
with System;

package Integer_Overflow is
   procedure Process_Buffer (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   );
   pragma Export (C, Process_Buffer, "process_buffer");
end Integer_Overflow;
