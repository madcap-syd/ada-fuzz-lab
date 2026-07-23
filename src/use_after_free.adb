with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;
with Unchecked_Deallocation;

package body Use_After_Free is
   
   type Buffer_Type is array (Natural range <>) of Interfaces.Unsigned_8;
   pragma Convention (C, Buffer_Type);
   
   type Buffer_Ptr is access Buffer_Type;
   
   procedure Free is new Unchecked_Deallocation (Buffer_Type, Buffer_Ptr);
   
   procedure Process_Memory (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      Data_View : Buffer_Type (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Local_Buffer : Buffer_Ptr := new Buffer_Type (0 .. 99);
   begin
      -- Копируем данные
      for I in 0 .. 99 loop
         if I < Natural(Len) then
            Local_Buffer(I) := Data_View(I);
         end if;
      end loop;
      
      -- Освобождаем память
      Free (Local_Buffer);
      
      -- УЯЗВИМОСТЬ: используем после освобождения!
      if Local_Buffer(0) = 16#DE# then
         Put_Line("Use-After-Free detected!");
      end if;
   end Process_Memory;
   
end Use_After_Free;
