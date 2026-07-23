with Interfaces.C;
with System;

package Use_After_Free is
   procedure Process_Memory (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   );
   pragma Export (C, Process_Memory, "process_memory");
end Use_After_Free;
