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
   meth numberToWord(N R) %% hasta 999
      if N < 0 then
         R = "negative " # {self numberToWord(~N $)}
      elseif N == 0 then
         R = "zero"
      elseif N < 10 then
         R = {self getDigitWord(N $)}
      elseif N < 20 then
         R = {self getTeenWord(N $)}
      elseif N < 100 then
         local Tens Ones in
            Tens = N div 10
            Ones = N mod 10
            if Ones == 0 then
               R = {self getTensWord(Tens $)}
            else
               R = {self getTensWord(Tens $)} # "-" # {self getDigitWord(Ones $)}
            end
         end
      elseif N < 1000 then
         local Hundreds Rest in
            Hundreds = N div 100
            Rest = N mod 100
            if Rest == 0 then
               R = {self getDigitWord(Hundreds $)} # " hundred"
            else
               R = {self getDigitWord(Hundreds $)} # " hundred " # {self numberToWord(Rest $)}
            end
         end
      else
         R = {IntToString N}
      end
   end
   
   meth getDigitWord(N R)
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
   
   meth getTeenWord(N R)
      case N of 10 then R = "ten"
      [] 11 then R = "eleven"
      [] 12 then R = "twelve"
      [] 13 then R = "thirteen"
      [] 14 then R = "fourteen"
      [] 15 then R = "fifteen"
      [] 16 then R = "sixteen"
      [] 17 then R = "seventeen"
      [] 18 then R = "eighteen"
      [] 19 then R = "nineteen"
      else R = {IntToString N}
      end
   end
   
   meth getTensWord(N R)
      case N of 2 then R = "twenty"
      [] 3 then R = "thirty"
      [] 4 then R = "forty"
      [] 5 then R = "fifty"
      [] 6 then R = "sixty"
      [] 7 then R = "seventy"
      [] 8 then R = "eighty"
      [] 9 then R = "ninety"
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
      {@left print} {System.showInfo "mod"} {@right print}
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


% {System.showInfo "=== COMPREHENSIVE TEST SUITE ==="}

% {System.showInfo "\n=== TEST 1: Basic Num operations ==="}
% N1 = {New Num init(3)}
% N2 = {New Num init(4)}
% N3 = {New Num init(2)}
% N4 = {New Num init(7)}
% N5 = {New Num init(0)}
% N6 = {New Num init(1)}
% N7 = {New Num init(9)}
% N8 = {New Num init(10)}
% N9 = {New Num init(15)}
% N10 = {New Num init(~5)}

% {System.showInfo "Testing Num print:"}
% {N1 print}
% {System.showInfo "Testing Num eval:"}
% local Result in {N1 eval(Result)} {System.showInfo "Result: " # Result} end
% {System.showInfo "Testing Num toString:"}
% local Str in {N1 toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 2: Num numberToWord edge cases ==="}
% {System.showInfo "Testing 0:"}
% local Str in {N5 toString(Str)} {System.showInfo "0 -> " # Str} end
% {System.showInfo "Testing 1:"}
% local Str in {N6 toString(Str)} {System.showInfo "1 -> " # Str} end
% {System.showInfo "Testing 9:"}
% local Str in {N7 toString(Str)} {System.showInfo "9 -> " # Str} end
% {System.showInfo "Testing 10 (should use IntToString):"}
% local Str in {N8 toString(Str)} {System.showInfo "10 -> " # Str} end
% {System.showInfo "Testing 15 (should use IntToString):"}
% local Str in {N9 toString(Str)} {System.showInfo "15 -> " # Str} end
% {System.showInfo "Testing negative number:"}
% local Str in {N10 toString(Str)} {System.showInfo "-5 -> " # Str} end

% {System.showInfo "\n=== TEST 3: Basic operations ==="}
% S = {New Sum init(N1 N2)}
% D = {New Difference init(N4 N3)}
% M = {New Multiplication init(N1 N2)}
% Mod = {New Modulo init(N4 N3)}

% {System.showInfo "Sum: 3 + 4"}
% {S print}
% local Result in {S eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {S toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nDifference: 7 - 2"}
% {D print}
% local Result in {D eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {D toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nMultiplication: 3 * 4"}
% {M print}
% local Result in {M eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {M toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nModulo: 7 % 2"}
% {Mod print}
% local Result in {Mod eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Mod toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 4: Edge cases for operations ==="}

% {System.showInfo "Sum with zero: 3 + 0"}
% S_zero = {New Sum init(N1 N5)}
% {S_zero print}
% local Result in {S_zero eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {S_zero toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nMultiplication with zero: 3 * 0"}
% M_zero = {New Multiplication init(N1 N5)}
% {M_zero print}
% local Result in {M_zero eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {M_zero toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nSum with negative: 3 + (-5)"}
% S_neg = {New Sum init(N1 N10)}
% {S_neg print}
% local Result in {S_neg eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {S_neg toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nDifference with negative: 3 - (-5)"}
% D_neg = {New Difference init(N1 N10)}
% {D_neg print}
% local Result in {D_neg eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {D_neg toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nModulo with 1: 7 % 1"}
% Mod_one = {New Modulo init(N4 N6)}
% {Mod_one print}
% local Result in {Mod_one eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Mod_one toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\nModulo with same number: 7 % 7"}
% Mod_same = {New Modulo init(N4 N4)}
% {Mod_same print}
% local Result in {Mod_same eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Mod_same toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 5: Complex nested expressions ==="}

% Complex1 = {New Multiplication init(S N3)}
% {System.showInfo "Complex expression: (3 + 4) * 2"}
% {Complex1 print}
% local Result in {Complex1 eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Complex1 toString(Str)} {System.showInfo "ToString: " # Str} end

% Complex2 = {New Sum init(D M)}
% {System.showInfo "\nComplex expression: (7 - 2) + (3 * 4)"}
% {Complex2 print}
% local Result in {Complex2 eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Complex2 toString(Str)} {System.showInfo "ToString: " # Str} end

% Complex3 = {New Multiplication init(Mod N1)}
% {System.showInfo "\nComplex expression: (7 % 2) * 3"}
% {Complex3 print}
% local Result in {Complex3 eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Complex3 toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 6: Deep nesting ==="}

% Deep1 = {New Sum init(Complex1 N6)}
% {System.showInfo "Deep nesting: ((3 + 4) * 2) + 1"}
% {Deep1 print}
% local Result in {Deep1 eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {Deep1 toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 7: Large numbers ==="}
% N_large1 = {New Num init(100)}
% N_large2 = {New Num init(50)}
% S_large = {New Sum init(N_large1 N_large2)}
% {System.showInfo "Large numbers: 100 + 50"}
% {S_large print}
% local Result in {S_large eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {S_large toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 8: Base Expression class ==="}
% BaseExpr = {New Num init(5)}  %% O alguna otra clase derivada de Expression
% {System.showInfo "Base Expression print:"}
% {BaseExpr print}
% {System.showInfo "Base Expression toString:"}
% local Str in {BaseExpr toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== TEST 9: All operations with same operands (3, 3) ==="}
% N_same1 = {New Num init(3)}
% N_same2 = {New Num init(3)}

% S_same = {New Sum init(N_same1 N_same2)}
% {System.showInfo "3 + 3"}
% {S_same print}
% local Result in {S_same eval(Result)} {System.showInfo "Result: " # Result} end

% D_same = {New Difference init(N_same1 N_same2)}
% {System.showInfo "\n3 - 3"}
% {D_same print}
% local Result in {D_same eval(Result)} {System.showInfo "Result: " # Result} end

% M_same = {New Multiplication init(N_same1 N_same2)}
% {System.showInfo "\n3 * 3"}
% {M_same print}
% local Result in {M_same eval(Result)} {System.showInfo "Result: " # Result} end

% Mod_same2 = {New Modulo init(N_same1 N_same2)}
% {System.showInfo "\n3 % 3"}
% {Mod_same2 print}
% local Result in {Mod_same2 eval(Result)} {System.showInfo "Result: " # Result} end

% {System.showInfo "\n=== TEST 10: Larger numbers than 999 ==="}
% N_larger1 = {New Num init(1000)}
% N_larger2 = {New Num init(500)}
% S_larger = {New Sum init(N_larger1 N_larger2)}
% {System.showInfo "Larger numbers: 1000 + 500"}
% {S_larger print}
% local Result in {S_larger eval(Result)} {System.showInfo "Result: " # Result} end
% local Str in {S_larger toString(Str)} {System.showInfo "ToString: " # Str} end

% {System.showInfo "\n=== ALL TESTS COMPLETED ==="}