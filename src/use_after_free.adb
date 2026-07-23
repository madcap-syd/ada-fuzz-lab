with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;
with Unchecked_Deallocation;

package body Use_After_Free is
   
   type Buffer_Type is array (Natural range <>) of Interfaces.Unsigned_8;
   pragma Convention (C, Buffer_Type);
   
   type Buffer_Ptr is access Buffer_Type;
   
   procedure Free is new Unchecked_Deallocation (Buffer_Type, Buffer_Ptr);
   
   Global_Ptr : Buffer_Ptr := null;  -- Глобальный указатель
   
   procedure Process_Memory (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      type Byte_Array is array (Natural range <>) of Interfaces.Unsigned_8;
      pragma Convention (C, Byte_Array);
      
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Temp_Val : Interfaces.Unsigned_8 := 0;
   begin
      -- Выделяем память
      Global_Ptr := new Buffer_Type (0 .. 99);
      
      -- Копируем данные
      for I in 0 .. 99 loop
         if I < Natural(Len) then
            Global_Ptr(I) := Data_View(I);
         end if;
      end loop;
      
      -- Сохраняем значение ПЕРЕД освобождением
      Temp_Val := Global_Ptr(0);
      
      -- Освобождаем память
      Free (Global_Ptr);
      Global_Ptr := null;
      
      -- УЯЗВИМОСТЬ: используем сохранённое значение (симуляция UAF)
      -- В реальности здесь был бы доступ к уже освобождённой памяти
      if Temp_Val = 16#DE# then
         -- Здесь мог бы быть краш при обращении к Global_Ptr
         declare
            Fake_Access : Buffer_Ptr := Buffer_Ptr'Val(16#DEAD#);  -- Недействительный адрес
            pragma Warnings (Off, Fake_Access);
         begin
            if Fake_Access(0) = 16#BE# then  -- CRASH! Use-After-Free
               Put_Line("UAF triggered!");
            end if;
         end;
      end if;
   end Process_Memory;
   
end Use_After_Free;
