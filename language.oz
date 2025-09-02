declare

class Expression
   meth print
      {System.showInfo "Base method does nothing"}
   end
   meth eval(R)
      {System.showInfo "Base method does nothing"}
   end
   meth toString(R)
      R = "base expression"
   end
end

class Num from Expression
   attr n:0
   meth init(Val)
      n := Val
   end
   meth print
      {System.showInfo @n}
   end
   meth eval(R)
      R = @n
   end
   meth toString(R)
      local Word in
         {self numberToWord(@n Word)}
         R = Word
      end
   end
   meth numberToWord(N R)
      case N of 0 then R = "zero"
      [] 1 then R = "one"
      [] 2 then R = "two"
      [] 3 then R = "three"
      [] 4 then R = "four"
      [] 5 then R = "five"
      [] 6 then R = "six"
      [] 7 then R = "seven"
      [] 8 then R = "eight"
      [] 9 then R = "nine"
      else R = {IntToString N}
      end
   end
end

class Sum from Expression
   attr left right
   meth init(L R)
      left := L
      right := R
   end
   meth print
      {@left print} {System.showInfo "+"} {@right print}
   end
   meth eval(R)
      local LR RR in
         {@left eval(LR)}
         {@right eval(RR)}
         R = LR + RR
      end
   end
   meth toString(R)
      local LeftStr RightStr in
         {@left toString(LeftStr)}
         {@right toString(RightStr)}
         R = LeftStr # " plus " # RightStr
      end
   end
end

class Difference from Expression
   attr left right
   meth init(L R)
      left := L
      right := R
   end
   meth print
      {@left print} {System.showInfo "-"} {@right print}
   end
   meth eval(R)
      local LR RR in
         {@left eval(LR)}
         {@right eval(RR)}
         R = LR - RR
      end
   end
   meth toString(R)
      local LeftStr RightStr in
         {@left toString(LeftStr)}
         {@right toString(RightStr)}
         R = LeftStr # " minus " # RightStr
      end
   end
end

class Multiplication from Expression
   attr left right
   meth init(L R)
      left := L
      right := R
   end
   meth print
      {@left print} {System.showInfo "*"} {@right print}
   end
   meth eval(R)
      local LR RR in
         {@left eval(LR)}
         {@right eval(RR)}
         R = LR * RR
      end
   end
   meth toString(R)
      local LeftStr RightStr in
         {@left toString(LeftStr)}
         {@right toString(RightStr)}
         R = LeftStr # " times " # RightStr
      end
   end
end

class Modulo from Expression
   attr left right
   meth init(L R)
      left := L
      right := R
   end
   meth print
      {@left print} {System.showInfo "%"} {@right print}
   end
   meth eval(R)
      local LR RR in
         {@left eval(LR)}
         {@right eval(RR)}
         R = LR mod RR
      end
   end
   meth toString(R)
      local LeftStr RightStr in
         {@left toString(LeftStr)}
         {@right toString(RightStr)}
         R = LeftStr # " modulo " # RightStr
      end
   end
end

% Test code
N1 = {New Num init(3)}
N2 = {New Num init(4)}
N3 = {New Num init(2)}
N4 = {New Num init(7)}

S = {New Sum init(N1 N2)}
D = {New Difference init(N4 N3)}
M = {New Multiplication init(N1 N2)}
Mod = {New Modulo init(N4 N3)}

{System.showInfo "=== Testing all operations ==="}

{System.showInfo "Sum: 3 + 4"}
{S print}
local Result in {S eval(Result)} {System.showInfo "Result: " # Result} end
local Str in {S toString(Str)} {System.showInfo "ToString: " # Str} end

{System.showInfo "\nDifference: 7 - 2"}
{D print}
local Result in {D eval(Result)} {System.showInfo "Result: " # Result} end
local Str in {D toString(Str)} {System.showInfo "ToString: " # Str} end

{System.showInfo "\nMultiplication: 3 * 4"}
{M print}
local Result in {M eval(Result)} {System.showInfo "Result: " # Result} end
local Str in {M toString(Str)} {System.showInfo "ToString: " # Str} end

{System.showInfo "\nModulo: 7 % 2"}
{Mod print}
local Result in {Mod eval(Result)} {System.showInfo "Result: " # Result} end
local Str in {Mod toString(Str)} {System.showInfo "ToString: " # Str} end