with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;

package body Null_Pointer is
   
   type Byte is mod 256;
   type Byte_Array is array (Natural range <>) of Byte;
   pragma Convention (C, Byte_Array);
   
   type Byte_Ptr is access all Byte;
   
   procedure Process_Data (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Ptr : Byte_Ptr := null;  -- УЯЗВИМОСТЬ: нулевой указатель!
   begin
      if Len > 0 and then Data_View(0) = 16#FF# then
         -- Разыменовываем нулевой указатель
         Ptr.all := Data_View(0);  -- CRASH!
      end if;
   end Process_Data;
   
end Null_Pointer;
