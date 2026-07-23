with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;

package body Integer_Overflow is
   
   type Byte is mod 256;
   type Byte_Array is array (Natural range <>) of Byte;
   pragma Convention (C, Byte_Array);
   
   procedure Process_Buffer (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Sum : Byte := 0;
   begin
      -- УЯЗВИМОСТЬ: Integer Overflow при суммировании
      for I in Data_View'Range loop
         Sum := Sum + Data_View(I);  -- Переполнение!
      end loop;
      
      Put_Line("Sum: " & Byte'Image(Sum));
   end Process_Buffer;
   
end Integer_Overflow;
