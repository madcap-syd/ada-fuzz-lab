with Interfaces.C;
with System;

package body Vulnerable_Parser is
   procedure Abort_Program;
   pragma Import (C, Abort_Program, "abort");

   type Buffer_Type is array (Integer range <>) of Character;

   procedure Parse_From_C (
      Data_Address : in System.Address;
      Data_Length  : in Interfaces.C.size_t
   ) is
      Len : Integer := Integer (Data_Length);
      Data_View : Buffer_Type (0 .. Len - 1) 
         with Import, Address => Data_Address;
   begin
      for I in Data_View'Range loop
         if Data_View (I) = 'X' then
            -- Уязвимость: выход за границу при Len = 1
            if Data_View (I + 1) = 'Y' then
               null;
            end if;
         end if;
      end loop;
   exception
      when Constraint_Error =>
         -- Принудительно роняем процесс, чтобы AFL++ увидел краш (SIGABRT)
         Abort_Program;
      when others =>
         Abort_Program;
   end Parse_From_C;
end Vulnerable_Parser;
