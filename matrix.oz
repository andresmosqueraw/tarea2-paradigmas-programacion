declare

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
      data := Data
      size := {Length Data}
   end
   
   meth initSizeValue(Size Value) 
      %% Initialize N×N matrix with same value in all positions
      %% Input: Size :: Int - Integer N for creating an N×N matrix (must be > 0)
      %%        Value :: Int - Value to fill all matrix positions
      %% Side effects: Initializes @data and @size attributes
      local
         fun {CreateRow N Val}
            if N == 0 then nil
            else Val | {CreateRow N-1 Val}
            end
         end
         fun {CreateMatrix N Val}
            if N == 0 then nil
            else {CreateRow Size Val} | {CreateMatrix N-1 Val}
            end
         end
      in
         size := Size
         data := {CreateMatrix Size Value}
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
         proc {PrintRow Row}
            case Row of nil then {System.showInfo ""}
            [] H|T then
               {System.print H # " "}
               {PrintRow T}
            end
         end
         proc {PrintMatrix Matrix}
            case Matrix of nil then skip
            [] Row|Rest then
               {PrintRow Row}
               {PrintMatrix Rest}
            end
         end
      in
         {System.showInfo "Matrix (" # @size # "x" # @size # "):"}
         {PrintMatrix @data}
      end
   end
end

%% -------- Tests --------
local M1 M2 Sz E R Row Col SR PR SC PC SA PA in
   %% Instantiate from data
   M1 = {New Matrix init([[1 2 3] [4 5 6] [7 8 9]])}
   %% Instantiate NxN filled value
   M2 = {New Matrix initSizeValue(3 5)}

   {System.show '--- M1 ---'}
   {M1 display()}
   {M1 getSize(Sz)}
   {System.showInfo "size_M1:"} {System.show Sz}
   {M1 getElement(2 2 E)}
   {System.showInfo "elem_2_2:"} {System.show E}
   {M1 getRow(1 Row)}
   {System.showInfo "row1:"} {System.show Row}
   {M1 getColumn(3 Col)}
   {System.showInfo "col3:"} {System.show Col}
   {M1 sumRow(1 SR)}
   {System.showInfo "sumRow1:"} {System.show SR}
   {M1 productRow(2 PR)}
   {System.showInfo "prodRow2:"} {System.show PR}
   {M1 sumColumn(3 SC)}
   {System.showInfo "sumCol3:"} {System.show SC}
   {M1 productColumn(1 PC)}
   {System.showInfo "prodCol1:"} {System.show PC}
   {M1 sumAll(SA)}
   {System.showInfo "sumAll:"} {System.show SA}
   {M1 productAll(PA)}
   {System.showInfo "prodAll:"} {System.show PA}

   {System.show '--- M2 ---'}
   {M2 display()}
   {M2 getSize(Sz)}
   {System.showInfo "size_M2:"} {System.show Sz}
   {M2 getElement(3 2 E)}
   {System.showInfo "elem_3_2:"} {System.show E}
end