with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;

package body Null_Pointer is
   
   type Data_Ptr is access all Interfaces.Unsigned_8;
   
   procedure Process_Data (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      type Byte_Array is array (Natural range <>) of Interfaces.Unsigned_8;
      pragma Convention (C, Byte_Array);
      
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Ptr : Data_Ptr := null;  -- УЯЗВИМОСТЬ: нулевой указатель!
   begin
      if Len > 0 and then Data_View(0) = 16#FF# then
         -- Пытаемся разыменовать нулевой указатель
         Ptr.all := Data_View(0);  -- CRASH!
      end if;
   end Process_Data;
   
end Null_Pointer;
