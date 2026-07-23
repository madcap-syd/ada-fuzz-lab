with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with System; use System;

package body Division_By_Zero is
   
   procedure Calculate (
      Data : in System.Address;
      Len  : in Interfaces.C.size_t
   ) is
      type Byte_Array is array (Natural range <>) of Interfaces.Unsigned_8;
      pragma Convention (C, Byte_Array);
      
      Data_View : Byte_Array (0 .. Natural(Len) - 1);
      for Data_View'Address use Data;
      
      Divisor : Integer := 1;
      Result : Float := 0.0;
   begin
      if Len > 0 then
         Divisor := Integer(Data_View(0)) - 1;  -- Если Data_View(0) = 1, то Divisor = 0!
      end if;
      
      -- УЯЗВИМОСТЬ: деление на ноль!
      Result := 100.0 / Float(Divisor);
      
      Put_Line("Result: " & Float'Image(Result));
   end Calculate;
   
end Division_By_Zero;
