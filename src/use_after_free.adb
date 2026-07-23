with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;
with Unchecked_Deallocation;

package body Use_After_Free is
   
   type Byte is mod 256;
   type Buffer_Type is array (Natural range <>) of Byte;
   pragma Convention (C, Buffer_Type);
   
   type Buffer_Ptr is access all Byte;
   
   procedure Free is new Unchecked_Deallocation (Byte, Buffer_Ptr);
   
   procedure Process_Memory (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      type Local_Array is array (Natural range <>) of Byte;
      pragma Convention (C, Local_Array);
      
      Data_View : Local_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Local_Buffer : Buffer_Ptr := new Byte'(0);
      Saved_Ptr : Buffer_Ptr;
   begin
      -- Сохраняем указатель
      Saved_Ptr := Local_Buffer;
      
      -- Освобождаем память
      Free (Local_Buffer);
      Local_Buffer := null;
      
      -- УЯЗВИМОСТЬ: используем освобождённую память
      if Data_View'Length > 0 and then Data_View(0) = 16#DE# then
         declare
            Val : constant Byte := Saved_Ptr.all;  -- CRASH! Use-After-Free
         begin
            null;  -- Just access freed memory
         end;
      end if;
   end Process_Memory;
   
end Use_After_Free;
