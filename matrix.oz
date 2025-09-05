declare Matrix

%% Matrix Class Definition
%% Represents a square matrix with operations for rows, columns, and entire matrix
class Matrix
   attr data size
   
   meth init(Data) 
      %% Initialize matrix from list of lists
      %% Input: Data :: [[Int]] - List of lists representing matrix rows
      %%                            Each inner list represents a row of the matrix
      %%                            All rows must have equal length to form a square matrix
      %% Precondition: Data must represent a valid square matrix (N×N where N > 0)
      %% Side effects: Initializes @data and @size attributes
      if {IsList Data} andthen {Length Data} > 0 then
         % Validar que todas las filas tengan la misma longitud
         data := Data
         size := {Length Data}
      else
         {Exception.raiseError matrix(invalidData Data)}
      end
   end
   
   meth getSize(?Result)
      %% Returns the size N of the N×N matrix
      %% Input: None
      %% Output: Result :: Int - The dimension N of the N×N matrix
      Result = @size
   end
   
   meth getElement(Row Col ?Result)
      %% Returns element at position (Row, Col) using 1-indexed coordinates
      %% Input: Row :: Int - Row index (1 ≤ Row ≤ N)
      %%        Col :: Int - Column index (1 ≤ Col ≤ N)
      %% Output: Result :: Int - Element at position (Row, Col)
      %% Note: If Row and Col are not valide within the matrix size return 142857
      if Row >= 1 andthen Row =< @size andthen Col >= 1 andthen Col =< @size then
         local
            fun {GetNth List N}
               if N == 1 then List.1
               else {GetNth List.2 N-1}
               end
            end
            RowList = {GetNth @data Row}
         in
            Result = {GetNth RowList Col}
         end
      else
         Result = 142857
      end
   end
   
   meth getRow(RowIndex ?Result)
      %% Returns the complete row as a list
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: [Int] - List containing all elements of the specified row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if RowIndex >= 1 andthen RowIndex =< @size then
         local
            fun {GetNth List N}
               if N == 1 then List.1
               else {GetNth List.2 N-1}
               end
            end
         in
            Result = {GetNth @data RowIndex}
         end
      else
         Result = 142857
      end
   end
   
   meth getColumn(ColIndex ?Result)
      %% Returns the complete column as a list
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)  
      %% Output: Result :: [Int] - List containing all elements of the specified column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      if ColIndex >= 1 andthen ColIndex =< @size then
         local
            fun {GetNth List N}
               if N == 1 then List.1
               else {GetNth List.2 N-1}
               end
            end
            fun {ExtractColumn Matrix Col}
               case Matrix of nil then nil
               [] Row|Rest then
                  {GetNth Row Col} | {ExtractColumn Rest Col}
               end
            end
         in
            Result = {ExtractColumn @data ColIndex}
         end
      else
         Result = 142857
      end
   end
   
   meth sumRow(RowIndex ?Result)
      %% Returns sum of all elements in specified row
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the row
      %% Precondition: RowIndex is valid within the Matrix size
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if RowIndex >= 1 andthen RowIndex =< @size then
         local
            fun {SumList List}
               case List of nil then 0
               [] H|T then H + {SumList T}
               end
            end
            RowList
         in
            {self getRow(RowIndex RowList)}
            Result = {SumList RowList}
         end
      else
         Result = 142857
      end
   end
   
   meth productRow(RowIndex ?Result)
      %% Returns product of all elements in specified row
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if RowIndex >= 1 andthen RowIndex =< @size then
         local
            fun {ProductList List}
               case List of nil then 1
               [] H|T then H * {ProductList T}
               end
            end
            RowList
         in
            {self getRow(RowIndex RowList)}
            Result = {ProductList RowList}
         end
      else
         Result = 142857
      end
   end
   
   meth sumColumn(ColIndex ?Result)
      %% Returns sum of all elements in specified column
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      if ColIndex >= 1 andthen ColIndex =< @size then
         local
            fun {SumList List}
               case List of nil then 0
               [] H|T then H + {SumList T}
               end
            end
            ColList
         in
            {self getColumn(ColIndex ColList)}
            Result = {SumList ColList}
         end
      else
         Result = 142857
      end
   end
   
   meth productColumn(ColIndex ?Result)
      %% Returns product of all elements in specified column
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      if ColIndex >= 1 andthen ColIndex =< @size then
         local
            fun {ProductList List}
               case List of nil then 1
               [] H|T then H * {ProductList T}
               end
            end
            ColList
         in
            {self getColumn(ColIndex ColList)}
            Result = {ProductList ColList}
         end
      else
         Result = 142857
      end
   end
   
   meth sumAll(?Result)
      %% Returns sum of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic sum of all matrix elements
      %% Note: Returns 0 for empty matrix
      local
         fun {SumMatrix Matrix}
            case Matrix of nil then 0
            [] Row|Rest then
               local
                  fun {SumList List}
                     case List of nil then 0
                     [] H|T then H + {SumList T}
                     end
                  end
               in
                  {SumList Row} + {SumMatrix Rest}
               end
            end
         end
      in
         Result = {SumMatrix @data}
      end
   end
   
   meth productAll(?Result) 
      %% Returns product of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic product of all matrix elements
      %% Note: Returns 1 for empty matrix, returns 0 if any element is 0
      local
         fun {ProductMatrix Matrix}
            case Matrix of nil then 1
            [] Row|Rest then
               local
                  fun {ProductList List}
                     case List of nil then 1
                     [] H|T then H * {ProductList T}
                     end
                  end
               in
                  {ProductList Row} * {ProductMatrix Rest}
               end
            end
         end
      in
         Result = {ProductMatrix @data}
      end
   end
   
   %% Utility methods
   meth display()
      %% Prints matrix in readable format to standard output
      %%    Any format is valid, just must display all the matrix content
      %% Input: None
      %% Output: None (void)
      local
         fun {RowToString Row}
            case Row of nil then ""
            [] H|T then
               case T of nil then {IntToString H}
               else {IntToString H} # " " # {RowToString T}
               end
            end
         end
         proc {PrintMatrix Matrix}
            case Matrix of nil then skip
            [] Row|Rest then
               {System.showInfo {RowToString Row}}
               {PrintMatrix Rest}
            end
         end
      in
         {System.showInfo "Matrix (" # @size # "x" # @size # "):"}
         {PrintMatrix @data}
      end
   end
end


% {System.showInfo "\n=== MATRIX CLASS TEST SUITE ==="}

% {System.showInfo "\n=== TEST 1: Matrix Creation and Initialization ==="}

% M1 = {New Matrix init([[1 2] [3 4]])}  % 2x2 matrix
% M2 = {New Matrix init([[1 2 3] [4 5 6] [7 8 9]])}  % 3x3 matrix
% M3 = {New Matrix init([[5]])}  % 1x1 matrix

% local Size1 Size2 Size3 in
%    {M1 getSize(Size1)}
%    {M2 getSize(Size2)}
%    {M3 getSize(Size3)}
%    {System.showInfo "M1 size: " # Size1 # " (expected: 2)"}
%    {System.showInfo "M2 size: " # Size2 # " (expected: 3)"}
%    {System.showInfo "M3 size: " # Size3 # " (expected: 1)"}
% end

% {System.showInfo "\n=== TEST 2: getElement method ==="}

% local Elem1 Elem2 Elem3 Elem4 in
%    {M1 getElement(1 1 Elem1)}  % Should return 1
%    {M1 getElement(1 2 Elem2)}  % Should return 2
%    {M1 getElement(2 1 Elem3)}  % Should return 3
%    {M1 getElement(2 2 Elem4)}  % Should return 4
%    {System.showInfo "M1[1,1] = " # Elem1 # " (expected: 1)"}
%    {System.showInfo "M1[1,2] = " # Elem2 # " (expected: 2)"}
%    {System.showInfo "M1[2,1] = " # Elem3 # " (expected: 3)"}
%    {System.showInfo "M1[2,2] = " # Elem4 # " (expected: 4)"}
% end

% local Invalid1 Invalid2 Invalid3 in
%    {M1 getElement(0 1 Invalid1)}  % Invalid row
%    {M1 getElement(1 0 Invalid2)}  % Invalid column
%    {M1 getElement(3 1 Invalid3)}  % Row out of bounds
%    {System.showInfo "M1[0,1] = " # Invalid1 # " (expected: 142857)"}
%    {System.showInfo "M1[1,0] = " # Invalid2 # " (expected: 142857)"}
%    {System.showInfo "M1[3,1] = " # Invalid3 # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 3: getRow method ==="}

% local Row1 Row2 Row3 in
%    {M2 getRow(1 Row1)}  % Should return [1 2 3]
%    {M2 getRow(2 Row2)}  % Should return [4 5 6]
%    {M2 getRow(3 Row3)}  % Should return [7 8 9]
%    {System.showInfo "M2 Row 1: " # {Value.toVirtualString Row1 10 10}}
%    {System.showInfo "M2 Row 2: " # {Value.toVirtualString Row2 10 10}}
%    {System.showInfo "M2 Row 3: " # {Value.toVirtualString Row3 10 10}}
% end

% local InvalidRow in
%    {M2 getRow(4 InvalidRow)}  % Row out of bounds
%    {System.showInfo "M2 Row 4: " # InvalidRow # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 4: getColumn method ==="}

% local Col1 Col2 Col3 in
%    {M2 getColumn(1 Col1)}  % Should return [1 4 7]
%    {M2 getColumn(2 Col2)}  % Should return [2 5 8]
%    {M2 getColumn(3 Col3)}  % Should return [3 6 9]
%    {System.showInfo "M2 Col 1: " # {Value.toVirtualString Col1 10 10}}
%    {System.showInfo "M2 Col 2: " # {Value.toVirtualString Col2 10 10}}
%    {System.showInfo "M2 Col 3: " # {Value.toVirtualString Col3 10 10}}
% end

% local InvalidCol in
%    {M2 getColumn(4 InvalidCol)}  % Column out of bounds
%    {System.showInfo "M2 Col 4: " # InvalidCol # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 5: sumRow method ==="}

% local Sum1 Sum2 Sum3 in
%    {M1 sumRow(1 Sum1)}  % Should return 1+2 = 3
%    {M1 sumRow(2 Sum2)}  % Should return 3+4 = 7
%    {M2 sumRow(1 Sum3)}  % Should return 1+2+3 = 6
%    {System.showInfo "M1 Row 1 sum: " # Sum1 # " (expected: 3)"}
%    {System.showInfo "M1 Row 2 sum: " # Sum2 # " (expected: 7)"}
%    {System.showInfo "M2 Row 1 sum: " # Sum3 # " (expected: 6)"}
% end

% local InvalidSum in
%    {M1 sumRow(3 InvalidSum)}  % Row out of bounds
%    {System.showInfo "M1 Row 3 sum: " # InvalidSum # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 6: productRow method ==="}

% local Prod1 Prod2 Prod3 in
%    {M1 productRow(1 Prod1)}  % Should return 1*2 = 2
%    {M1 productRow(2 Prod2)}  % Should return 3*4 = 12
%    {M2 productRow(1 Prod3)}  % Should return 1*2*3 = 6
%    {System.showInfo "M1 Row 1 product: " # Prod1 # " (expected: 2)"}
%    {System.showInfo "M1 Row 2 product: " # Prod2 # " (expected: 12)"}
%    {System.showInfo "M2 Row 1 product: " # Prod3 # " (expected: 6)"}
% end

% local InvalidProd in
%    {M1 productRow(3 InvalidProd)}  % Row out of bounds
%    {System.showInfo "M1 Row 3 product: " # InvalidProd # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 7: sumColumn method ==="}

% local ColSum1 ColSum2 ColSum3 in
%    {M1 sumColumn(1 ColSum1)}  % Should return 1+3 = 4
%    {M1 sumColumn(2 ColSum2)}  % Should return 2+4 = 6
%    {M2 sumColumn(1 ColSum3)}  % Should return 1+4+7 = 12
%    {System.showInfo "M1 Col 1 sum: " # ColSum1 # " (expected: 4)"}
%    {System.showInfo "M1 Col 2 sum: " # ColSum2 # " (expected: 6)"}
%    {System.showInfo "M2 Col 1 sum: " # ColSum3 # " (expected: 12)"}
% end

% local InvalidColSum in
%    {M1 sumColumn(3 InvalidColSum)}  % Column out of bounds
%    {System.showInfo "M1 Col 3 sum: " # InvalidColSum # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 8: productColumn method ==="}

% local ColProd1 ColProd2 ColProd3 in
%    {M1 productColumn(1 ColProd1)}  % Should return 1*3 = 3
%    {M1 productColumn(2 ColProd2)}  % Should return 2*4 = 8
%    {M2 productColumn(1 ColProd3)}  % Should return 1*4*7 = 28
%    {System.showInfo "M1 Col 1 product: " # ColProd1 # " (expected: 3)"}
%    {System.showInfo "M1 Col 2 product: " # ColProd2 # " (expected: 8)"}
%    {System.showInfo "M2 Col 1 product: " # ColProd3 # " (expected: 28)"}
% end

% local InvalidColProd in
%    {M1 productColumn(3 InvalidColProd)}  % Column out of bounds
%    {System.showInfo "M1 Col 3 product: " # InvalidColProd # " (expected: 142857)"}
% end

% {System.showInfo "\n=== TEST 9: sumAll method ==="}

% local TotalSum1 TotalSum2 TotalSum3 in
%    {M1 sumAll(TotalSum1)}  % Should return 1+2+3+4 = 10
%    {M2 sumAll(TotalSum2)}  % Should return 1+2+3+4+5+6+7+8+9 = 45
%    {M3 sumAll(TotalSum3)}  % Should return 5
%    {System.showInfo "M1 total sum: " # TotalSum1 # " (expected: 10)"}
%    {System.showInfo "M2 total sum: " # TotalSum2 # " (expected: 45)"}
%    {System.showInfo "M3 total sum: " # TotalSum3 # " (expected: 5)"}
% end

% {System.showInfo "\n=== TEST 10: productAll method ==="}

% local TotalProd1 TotalProd2 TotalProd3 in
%    {M1 productAll(TotalProd1)}  % Should return 1*2*3*4 = 24
%    {M2 productAll(TotalProd2)}  % Should return 1*2*3*4*5*6*7*8*9 = 362880
%    {M3 productAll(TotalProd3)}  % Should return 5
%    {System.showInfo "M1 total product: " # TotalProd1 # " (expected: 24)"}
%    {System.showInfo "M2 total product: " # TotalProd2 # " (expected: 362880)"}
%    {System.showInfo "M3 total product: " # TotalProd3 # " (expected: 5)"}
% end

% {System.showInfo "\n=== TEST 11: display method ==="}

% {System.showInfo "Displaying M1:"}
% {M1 display()}

% {System.showInfo "\nDisplaying M2:"}
% {M2 display()}

% {System.showInfo "\nDisplaying M3:"}
% {M3 display()}

% {System.showInfo "\n=== TEST 12: Edge Cases and Error Handling ==="}

% M4 = {New Matrix init([[0 1] [2 0]])}
% local ZeroSum ZeroProd in
%    {M4 sumAll(ZeroSum)}  % Should return 0+1+2+0 = 3
%    {M4 productAll(ZeroProd)}  % Should return 0*1*2*0 = 0
%    {System.showInfo "M4 (with zeros) sum: " # ZeroSum # " (expected: 3)"}
%    {System.showInfo "M4 (with zeros) product: " # ZeroProd # " (expected: 0)"}
% end

% M5 = {New Matrix init([[~1 2] [~3 4]])}
% local NegSum NegProd in
%    {M5 sumAll(NegSum)}  % Should return -1+2-3+4 = 2
%    {M5 productAll(NegProd)}  % Should return -1*2*-3*4 = 24
%    {System.showInfo "M5 (with negatives) sum: " # NegSum # " (expected: 2)"}
%    {System.showInfo "M5 (with negatives) product: " # NegProd # " (expected: 24)"}
% end

% local Boundary1 Boundary2 Boundary3 in
%    {M2 getElement(1 1 Boundary1)}  % First element
%    {M2 getElement(3 3 Boundary2)}  % Last element
%    {M2 getElement(2 2 Boundary3)}  % Middle element
%    {System.showInfo "M2[1,1] (first): " # Boundary1 # " (expected: 1)"}
%    {System.showInfo "M2[3,3] (last): " # Boundary2 # " (expected: 9)"}
%    {System.showInfo "M2[2,2] (middle): " # Boundary3 # " (expected: 5)"}
% end

% {System.showInfo "\n=== TEST 13: Large Matrix Test ==="}

% M6 = {New Matrix init([[1 2 3 4] [5 6 7 8] [9 10 11 12] [13 14 15 16]])}
% local LargeSize LargeSum LargeProd in
%    {M6 getSize(LargeSize)}
%    {M6 sumAll(LargeSum)}
%    {M6 productAll(LargeProd)}
%    {System.showInfo "M6 size: " # LargeSize # " (expected: 4)"}
%    {System.showInfo "M6 total sum: " # LargeSum # " (expected: 136)"}
%    {System.showInfo "M6 total product: " # LargeProd # " (expected: 20922789888000)"}
% end

% {System.showInfo "\n=== ALL MATRIX TESTS COMPLETED ==="}