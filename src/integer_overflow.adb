with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;

package body Integer_Overflow is
   
   procedure Process_Buffer (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      type Byte_Array is array (Natural range <>) of Interfaces.Unsigned_8;
      pragma Convention (C, Byte_Array);
      
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Sum : Interfaces.Unsigned_8 := 0;
   begin
      -- УЯЗВИМОСТЬ: Integer Overflow при суммировании
      for I in Data_View'Range loop
         Sum := Sum + Data_View(I);  -- Может переполниться!
      end loop;
      
      Put_Line("Sum: " & Unsigned_8'Image(Sum));
   end Process_Buffer;
   
end Integer_Overflow;
