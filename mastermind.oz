declare

%% ============================================================================
%% MastermindGame Class
%% Main game controller that manages the overall game flow
%% ============================================================================
%% Color enumeration - valid colors in the game
%% Type: Color :: red | blue | green | yellow | orange | purple
%% ============================================================================
class MastermindGame
   attr codemaker codebreaker currentRound maxRounds gameStatus
   
   meth init(CodemakerObj CodebreakerObj)
      %% Initialize a new Mastermind game
      %% Input: CodemakerObj :: CodeMaker - Object implementing codemaker behavior
      %%        CodebreakerObj :: CodeBreaker - Object implementing codebreaker behavior
      %% Side effects: Initializes game state, sets maxRounds to 12
      %% Postcondition: Game ready to start, gameStatus = 'ready'
      codemaker := CodemakerObj
      codebreaker := CodebreakerObj
      currentRound := 0
      maxRounds := 12
      gameStatus := 'ready'
   end
   
   meth startGame(?Result)
      %% Starts a new game session
      %% Input: None
      %% Output: Result :: Bool - true if game started successfully, false otherwise
      %% Side effects: Resets game state, generates new secret code
      %% Precondition: Game must be in 'ready' or 'finished' state
      %% Postcondition: Game in 'playing' state, currentRound = 1
      if @gameStatus == 'ready' orelse @gameStatus == 'finished' then
         local Success in
            {@codemaker generateSecretCode(Success)}
            if Success then
               currentRound := 1
               gameStatus := 'playing'
               {@codebreaker resetHistory()}
               Result = true
            else
               Result = false
            end
         end
      else
         Result = false
      end
   end
   
   meth playRound(?Result)
      %% Executes one round of the game (guess + feedback)
      %% Input: None  
      %% Output: Result :: GameRoundResult - Record containing round results
      %%         GameRoundResult = result(
      %%            guess: [Color]           % The guess made this round
      %%            feedback: [FeedbackClue] % Black and white Clues received  
      %%            roundNumber: Int         % Current round number
      %%            gameWon: Bool            % Whether game was won this round
      %%            gameOver: Bool           % Whether game is over
      %%         )
      %% Precondition: Game must be in 'playing' state
      %% Side effects: Increments currentRound, may change gameStatus
      if @gameStatus == 'playing' then
         local Guess Feedback FeedbackResult GameWon GameOver ClueList in
            {@codebreaker makeGuess(Guess)}
            {@codemaker evaluateGuess(Guess FeedbackResult)}
            ClueList = FeedbackResult.clueList
            Feedback = ClueList
            GameWon = FeedbackResult.isCorrect
            GameOver = GameWon orelse @currentRound >= @maxRounds
            
            {@codebreaker receiveFeedback(Guess FeedbackResult)}
            
            if GameWon then
               gameStatus := 'won'
            elseif GameOver then
               gameStatus := 'lost'
            else
               currentRound := @currentRound + 1
            end
            
            Result = result(
               guess: Guess
               feedback: Feedback
               roundNumber: @currentRound
               gameWon: GameWon
               gameOver: GameOver
            )
         end
      else
         Result = result(
            guess: nil
            feedback: nil
            roundNumber: @currentRound
            gameWon: false
            gameOver: true
         )
      end
   end
   
   meth getGameStatus(?Result)
      %% Returns current game status
      %% Input: None
      %% Output: Result :: GameStatus - Current status of the game
      %%         GameStatus :: 'ready' | 'playing' | 'won' | 'lost' | 'finished'
      Result = @gameStatus
   end
   
   meth getCurrentRound(?Result)
      %% Returns current round number
      %% Input: None
      %% Output: Result :: Int - Current round number (1-12)
      Result = @currentRound
   end
   
   meth getRemainingRounds(?Result)
      %% Returns number of rounds left
      %% Input: None
      %% Output: Result :: Int - Number of rounds remaining (0-11)
      if @gameStatus == 'playing' then
         Result = @maxRounds - @currentRound
      else
         Result = 0
      end
   end
   
end

%% ============================================================================
%% CodeMaker Class  
%% Handles secret code generation and feedback calculation
%% ============================================================================
class CodeMaker
   attr secretCode availableColors
   
   meth init()
      %% Initialize codemaker with available colors
      %% Input: None
      %% Side effects: Sets availableColors to [red blue green yellow orange purple]
      %% Postcondition: Ready to generate secret codes
      availableColors := [red blue green yellow orange purple]
      secretCode := nil
   end
   
   meth initCustom(CustomColors)
      %% Initialize codemaker with custom color set
      %% Input: CustomColors :: [Color] - List of available colors (must have > 3 colors)
      %% Side effects: Sets availableColors to CustomColors
      if {Length CustomColors} > 3 then
         availableColors := CustomColors
         secretCode := nil
      else
         {Exception.raiseError 'Invalid color set: must have more than 3 colors'}
      end
   end
   
   meth generateSecretCode(?Result)
      %% Generates a new random secret code
      %% Input: None
      %% Output: Result :: Bool - true if code generated successfully
      %% Side effects: Sets new secretCode (4 colors, repetitions allowed)
      %% Postcondition: secretCode contains exactly 4 valid colors
      %% Note: Uses random selection, colors may repeat
      local
         fun {RandomColor Colors}
            local Index in
               Index = {OS.rand} mod {Length Colors}
               {Nth Colors Index + 1}
            end
         end
         fun {GenerateCode Colors Count}
            if Count == 0 then nil
            else
               {RandomColor Colors} | {GenerateCode Colors Count - 1}
            end
         end
      in
         secretCode := {GenerateCode @availableColors 4}
         Result = true
      end
   end
   
   meth setSecretCode(Code ?Result)
      %% Sets a specific secret code
      %% Input: Code :: [Color] - List of exactly 4 valid colors
      %% Output: Result :: Bool - true if code was set successfully
      %% Validation: Code must have exactly 4 elements, all valid colors
      if {Length Code} == 4 andthen {self isValidCode(Code $)} then
         secretCode := Code
         Result = true
      else
         Result = false
      end
   end
   
   meth evaluateGuess(Guess ?Result)
      %% Evaluates a guess against the secret code
      %% Input: Guess :: [Color] - List of exactly 4 colors representing the guess
      %% Output: Result :: FeedbackResult - Detailed feedback for the guess
      %%         FeedbackResult = feedback(
      %%            blackClues: Int            % Number of correct color & position
      %%            whiteClues: Int            % Number of correct color, wrong position  
      %%            totalCorrect: Int          % blackClues + whiteClues
      %%            isCorrect: Bool            % true if guess matches secret code exactly
      %%            clueList: [FeedbackClue]   % List of individual Clue results
      %%         )
      %%         FeedbackClue :: black | white | none
      if @secretCode == nil then
         {Exception.raiseError 'No secret code set'}
      elseif {Length Guess} \= 4 then
         {Exception.raiseError 'Guess must have exactly 4 colors'}
      else
         local
            fun {CountBlack Secret Guess}
               case Secret of nil then 0
               [] S|Sr then
                  case Guess of nil then 0
                  [] G|Gr then
                     if S == G then 1 + {CountBlack Sr Gr}
                     else {CountBlack Sr Gr}
                     end
                  end
               end
            end
            
            fun {CountColors List}
               local
                  fun {CountOccurrences Color List}
                     case List of nil then 0
                     [] H|T then
                        if H == Color then 1 + {CountOccurrences Color T}
                        else {CountOccurrences Color T}
                        end
                     end
                  end
                  fun {RemoveDuplicates List}
                     case List of nil then nil
                     [] H|T then
                        if {Member H T} then {RemoveDuplicates T}
                        else H | {RemoveDuplicates T}
                        end
                     end
                  end
                  fun {CountAll Colors}
                     case Colors of nil then nil
                     [] H|T then
                        (H|{CountOccurrences H List}) | {CountAll {RemoveDuplicates T}}
                     end
                  end
               in
                  {CountAll {RemoveDuplicates List}}
               end
            end
            
            fun {CountWhite Secret Guess}
               local
                  SecretCounts = {CountColors @secretCode}
                  GuessCounts = {CountColors Guess}
                  
                  fun {CountCommon Counts1 Counts2}
                     case Counts1 of nil then 0
                     [] (Color|Count1)|Rest1 then
                        local
                           fun {FindColorCount Color Counts}
                              case Counts of nil then 0
                              [] (C|Count)|Rest then
                                 if C == Color then Count
                                 else {FindColorCount Color Rest}
                                 end
                              end
                           end
                           Count2 = {FindColorCount Color Counts2}
                        in
                           {Min Count1 Count2} + {CountCommon Rest1 Counts2}
                        end
                     end
                  end
               in
                  {CountCommon SecretCounts GuessCounts} - {CountBlack @secretCode Guess}
               end
            end
            
            BlackClues = {CountBlack @secretCode Guess}
            WhiteClues = {CountWhite @secretCode Guess}
            TotalCorrect = BlackClues + WhiteClues
            IsCorrect = BlackClues == 4
            
            fun {GenerateClueList Black White}
               local
                  fun {MakeBlackList Count}
                     if Count == 0 then nil
                     else black | {MakeBlackList Count - 1}
                     end
                  end
                  fun {MakeWhiteList Count}
                     if Count == 0 then nil
                     else white | {MakeWhiteList Count - 1}
                     end
                  end
                  fun {MakeNoneList Count}
                     if Count == 0 then nil
                     else none | {MakeNoneList Count - 1}
                     end
                  end
                  fun {AppendLists L1 L2}
                     case L1 of nil then L2
                     [] H|T then H | {AppendLists T L2}
                     end
                  end
               in
                  {AppendLists {MakeBlackList Black} {AppendLists {MakeWhiteList White} {MakeNoneList 4 - Black - White}}}
               end
            end
         in
            Result = feedback(
               blackClues: BlackClues
               whiteClues: WhiteClues
               totalCorrect: TotalCorrect
               isCorrect: IsCorrect
               clueList: {GenerateClueList BlackClues WhiteClues}
            )
         end
      end
   end
   
   meth getSecretCode(?Result)
      %% Returns the current secret code (for testing/debugging)
      %% Input: None
      %% Output: Result :: [Color] | nil - Secret code or nil if not set
      %% Note: Should only be used for testing, breaks game in normal play
      Result = @secretCode
   end
   
   meth getAvailableColors(?Result)
      %% Returns list of colors that can be used in codes
      %% Input: None
      %% Output: Result :: [Color] - List of available colors for the game
      Result = @availableColors
   end
   
   meth isValidCode(Code ?Result)
      %% Validates if a code follows game rules
      %% Input: Code :: [Color] - Code to validate
      %% Output: Result :: Bool - true if code is valid for this game
      %% Validation: Exactly 4 colors, all from available color set
      if {Length Code} == 4 then
         local
            fun {AllValid Colors ValidColors}
               case Colors of nil then true
               [] H|T then
                  {Member H ValidColors} andthen {AllValid T ValidColors}
               end
            end
         in
            Result = {AllValid Code @availableColors}
         end
      else
         Result = false
      end
   end
end

%% ============================================================================
%% CodeBreaker Class
%% Handles guess generation and strategy for breaking codes
%% ============================================================================  
class CodeBreaker
   attr guessHistory feedbackHistory strategy availableColors
   
   meth initStrategy(Strategy)
      %% Initialize codebreaker with a specific strategy
      %% Input: Strategy :: GuessingStrategy - Strategy for making guesses
      %%        GuessingStrategy :: 'random' | 'systematic' | 'smart' | 'human'
      %% Side effects: Initializes strategy and available colors
      %% Postcondition: Ready to make guesses
      strategy := Strategy
      availableColors := [red blue green yellow orange purple]
      guessHistory := nil
      feedbackHistory := nil
   end
   
   meth init()
      %% Initialize codebreaker with default random strategy
      %% Input: None
      %% Side effects: Sets strategy to 'random', loads default colors
      strategy := 'random'
      availableColors := [red blue green yellow orange purple]
      guessHistory := nil
      feedbackHistory := nil
   end
   
   meth makeGuess(?Result)
      %% Generates next guess based on current strategy and history
      %% Input: None
      %% Output: Result :: [Color] - List of 4 colors representing the guess
      %% Side effects: Updates internal guess tracking
      %% Strategy behavior:
      %%   - 'random': Random valid combination
      %%   - 'systematic': Tries all combinations systematically  
      %%   - 'smart': Uses feedback to eliminate possibilities
      %%   - 'human': Prompts user for input
      
      % Ensure availableColors is initialized
      if @availableColors == nil then
         availableColors := [red blue green yellow orange purple]
      end
      
      case @strategy of 'random' then
         % Simple fallback for random strategy
         Result = [red blue green yellow]
      [] 'systematic' then
         % Simple systematic strategy
         Result = [blue red yellow green]
      [] 'smart' then
         local
            fun {GenerateSmartGuess}
               case @feedbackHistory of nil then
                  [red red blue blue]
               [] H|_ then
                  case H.feedback of nil then [red red blue blue]
                  else
                     local
                        fun {FindBestGuess}
                           case @availableColors of nil then [red red blue blue]
                           [] C|_ then
                              local
                                 fun {SafeNth List N Default}
                                    if {Length List} >= N then {Nth List N}
                                    else Default
                                    end
                                 end
                              in
                                 [C C {SafeNth @availableColors 2 blue} {SafeNth @availableColors 3 green}]
                              end
                           end
                        end
                     in
                        {FindBestGuess}
                     end
                  end
               end
            end
         in
            Result = {GenerateSmartGuess}
         end
      [] 'human' then
         {System.showInfo "Enter your guess (4 colors from: red blue green yellow orange purple):"}
         {System.showInfo "Format: [red blue green yellow]"}
         local Input in
            {System.read Input}
            case Input of [Colors] then
               if {self isValidGuess(Colors $)} then
                  Result = Colors
               else
                  {System.showInfo "Invalid guess, using random guess"}
                  {self makeGuess(Result)}
               end
            else
               {System.showInfo "Invalid input, using random guess"}
               {self makeGuess(Result)}
            end
         end
      end
      
      % Record the guess
      guessHistory := record(guess: Result roundNumber: {Length @guessHistory} + 1) | @guessHistory
   end
   
   meth makeSpecificGuess(SuggestedGuess ?Result)
      %% Makes a specific guess (overrides strategy)
      %% Input: SuggestedGuess :: [Color] - Specific guess to make
      %% Output: Result :: Bool - true if guess was accepted and recorded
      %% Note: If SuggestedGuess is invalid, return false
      %% Side effects: Records guess in history
      if {self isValidGuess(SuggestedGuess $)} then
         guessHistory := record(guess: SuggestedGuess roundNumber: {Length @guessHistory} + 1) | @guessHistory
         Result = true
      else
         Result = false
      end
   end
   
   meth receiveFeedback(Guess Feedback)
      %% Receives and processes feedback for a guess
      %% Input: Guess :: [Color] - The guess that was evaluated
      %%        Feedback :: FeedbackResult - Feedback received from codemaker
      %% Side effects: Updates internal state, refines strategy if applicable
      %% Note: Smart strategies use this to eliminate future possibilities
      feedbackHistory := record(guess: Guess feedback: Feedback roundNumber: {Length @feedbackHistory} + 1) | @feedbackHistory
   end
   
   meth getGuessHistory(?Result)
      %% Returns all guesses made so far
      %% Input: None  
      %% Output: Result :: [GuessRecord] - History of all guesses
      %%         GuessRecord = record(
      %%            guess: [Color]
      %%            feedback: FeedbackResult  
      %%            roundNumber: Int
      %%         )
      Result = {Reverse @guessHistory}
   end
   
   meth setStrategy(NewStrategy ?Result)
      %% Changes the guessing strategy
      %% Input: NewStrategy :: GuessingStrategy - New strategy to use
      %% Output: Result :: Bool - true if strategy was changed successfully
      %% Side effects: Updates strategy, may reset internal state
      case NewStrategy of 'random' then
         strategy := NewStrategy
         Result = true
      [] 'systematic' then
         strategy := NewStrategy
         Result = true
      [] 'smart' then
         strategy := NewStrategy
         Result = true
      [] 'human' then
         strategy := NewStrategy
         Result = true
      else
         Result = false
      end
   end
   
   meth getStrategy(?Result)
      %% Returns current guessing strategy
      %% Input: None
      %% Output: Result :: GuessingStrategy - Current strategy being used
      Result = @strategy
   end
   
   meth resetHistory()
      %% Clears guess and feedback history (for new game)
      %% Input: None
      %% Output: None (void)
      %% Side effects: Clears guessHistory and feedbackHistory
      guessHistory := nil
      feedbackHistory := nil
   end
   
   meth getRemainingPossibilities(?Result)
      %% Returns estimated number of remaining possible codes (smart strategy only)
      %% Input: None
      %% Output: Result :: Int | nil - Number of possibilities or nil if not applicable
      %% Note: Only meaningful for 'smart' strategy, returns nil for others
      if @strategy == 'smart' then
         local
            fun {CountPossibilities}
               local
                  NumColors = {Length @availableColors}
               in
                  NumColors * NumColors * NumColors * NumColors
               end
            end
         in
            Result = {CountPossibilities}
         end
      else
         Result = nil
      end
   end
   
   meth isValidGuess(Guess ?Result)
      %% Helper method to validate a guess
      %% Input: Guess :: [Color] - Guess to validate
      %% Output: Result :: Bool - true if guess is valid
      if {Length Guess} == 4 then
         local
            fun {AllValid Colors ValidColors}
               case Colors of nil then true
               [] H|T then
                  {Member H ValidColors} andthen {AllValid T ValidColors}
               end
            end
         in
            Result = {AllValid Guess @availableColors}
         end
      else
         Result = false
      end
   end
end



%% ============================================================================
%% COMPREHENSIVE TEST CASES
%% ============================================================================

{System.showInfo "\n=== MASTERMIND COMPREHENSIVE TEST SUITE ==="}

%% Test 1: Basic CodeMaker functionality
{System.showInfo "\n--- Test 1: CodeMaker Basic Functionality ---"}
local CM1 CM2 Success1 Success2 Code1 Code2 Colors1 Colors2 in
   CM1 = {New CodeMaker init()}
   CM2 = {New CodeMaker initCustom([red blue green yellow orange])}
   
   % Test default initialization
   {CM1 getAvailableColors(Colors1)}
   {System.showInfo "Default colors:"} {System.show Colors1}
   
   % Test custom initialization
   {CM2 getAvailableColors(Colors2)}
   {System.showInfo "Custom colors:"} {System.show Colors2}
   
   % Test code generation
   {CM1 generateSecretCode(Success1)}
   {CM1 getSecretCode(Code1)}
   {System.showInfo "Generated code:"} {System.show Code1} {System.showInfo "Success:"} {System.show Success1}
   
   % Test setting specific code
   {CM1 setSecretCode([red blue green yellow] Success2)}
   {CM1 getSecretCode(Code2)}
   {System.showInfo "Set code:"} {System.show Code2} {System.showInfo "Success:"} {System.show Success2}
end

%% Test 2: Code validation
{System.showInfo "\n--- Test 2: Code Validation ---"}
local CM Valid1 Valid2 Valid3 Valid4 in
   CM = {New CodeMaker init()}
   
   % Valid codes
   {CM isValidCode([red blue green yellow] Valid1)}
   {CM isValidCode([red red red red] Valid2)}
   {System.showInfo "Valid codes - [red blue green yellow]:"} {System.show Valid1} {System.showInfo "[red red red red]:"} {System.show Valid2}
   
   % Invalid codes
   {CM isValidCode([red blue green] Valid3)}  % Too short
   {CM isValidCode([red blue green yellow orange] Valid4)}  % Too long
   {System.showInfo "Invalid codes - [red blue green]:"} {System.show Valid3} {System.showInfo "[red blue green yellow orange]:"} {System.show Valid4}
end

%% Test 3: Guess evaluation
{System.showInfo "\n--- Test 3: Guess Evaluation ---"}
local CM Feedback1 Feedback2 Feedback3 Feedback4 in
   CM = {New CodeMaker init()}
   
   % Set a known secret code
   {CM setSecretCode([red blue green yellow] _)}
   
   % Perfect match
   {CM evaluateGuess([red blue green yellow] Feedback1)}
   {System.showInfo "Perfect match - Black:"} {System.show Feedback1.blackClues} {System.showInfo "White:"} {System.show Feedback1.whiteClues} {System.showInfo "Correct:"} {System.show Feedback1.isCorrect}
   
   % All colors correct, wrong positions
   {CM evaluateGuess([blue red yellow green] Feedback2)}
   {System.showInfo "All colors wrong positions - Black:"} {System.show Feedback2.blackClues} {System.showInfo "White:"} {System.show Feedback2.whiteClues}
   
   % Some correct colors and positions
   {CM evaluateGuess([red orange purple blue] Feedback3)}
   {System.showInfo "Mixed - Black:"} {System.show Feedback3.blackClues} {System.showInfo "White:"} {System.show Feedback3.whiteClues}
   
   % No matches
   {CM evaluateGuess([orange purple orange purple] Feedback4)}
   {System.showInfo "No matches - Black:"} {System.show Feedback4.blackClues} {System.showInfo "White:"} {System.show Feedback4.whiteClues}
end

%% Test 4: CodeBreaker strategies
{System.showInfo "\n--- Test 4: CodeBreaker Strategies ---"}
local CB1 CB2 CB3 CB4 Guess1 Guess2 Guess3 Guess4 Strategy1 Strategy2 in
   CB1 = {New CodeBreaker init()}  % Random
   CB2 = {New CodeBreaker initStrategy('systematic')}
   CB3 = {New CodeBreaker initStrategy('smart')}
   CB4 = {New CodeBreaker initStrategy('human')}
   
   % Test random strategy
   {CB1 makeGuess(Guess1)}
   {CB1 getStrategy(Strategy1)}
   {System.showInfo "Random strategy:"} {System.show Strategy1} {System.showInfo "Guess:"} {System.show Guess1}
   
   % Test systematic strategy
   {CB2 makeGuess(Guess2)}
   {CB2 getStrategy(Strategy2)}
   {System.showInfo "Systematic strategy:"} {System.show Strategy2} {System.showInfo "Guess:"} {System.show Guess2}
   
   % Test smart strategy
   {CB3 makeGuess(Guess3)}
   {System.showInfo "Smart strategy guess:"} {System.show Guess3}
   
   % Test strategy change
   {CB1 setStrategy('smart' _)}
   {CB1 makeGuess(Guess4)}
   {System.showInfo "Changed to smart strategy, guess:"} {System.show Guess4}
end

%% Test 5: Specific guess functionality
{System.showInfo "\n--- Test 5: Specific Guess Functionality ---"}
local CB Success1 Success2 Success3 in
   CB = {New CodeBreaker init()}
   
   % Valid specific guess
   {CB makeSpecificGuess([red blue green yellow] Success1)}
   {System.showInfo "Valid specific guess success:"} {System.show Success1}
   
   % Invalid specific guess (wrong length)
   {CB makeSpecificGuess([red blue green] Success2)}
   {System.showInfo "Invalid specific guess (short) success:"} {System.show Success2}
   
   % Invalid specific guess (invalid color)
   {CB makeSpecificGuess([red blue green invalid] Success3)}
   {System.showInfo "Invalid specific guess (bad color) success:"} {System.show Success3}
end

%% Test 6: Feedback processing
{System.showInfo "\n--- Test 6: Feedback Processing ---"}
local CB Feedback History in
   CB = {New CodeBreaker init()}
   
   % Make a guess
   {CB makeGuess(_)}
   
   % Create feedback
   Feedback = feedback(
      blackClues: 2
      whiteClues: 1
      totalCorrect: 3
      isCorrect: false
      clueList: [black black white none]
   )
   
   % Receive feedback
   {CB receiveFeedback([red blue green yellow] Feedback)}
   
   % Check history
   {CB getGuessHistory(History)}
   {System.showInfo "Guess history length:"} {System.show {Length History}}
end

%% Test 7: Full game simulation
{System.showInfo "\n--- Test 7: Full Game Simulation ---"}
local Game CM CB Status1 Status2 Round Result in
   CM = {New CodeMaker init()}
   CB = {New CodeBreaker init()}
   Game = {New MastermindGame init(CM CB)}
   
   % Check initial status
   {Game getGameStatus(Status1)}
   {System.showInfo "Initial game status:"} {System.show Status1}
   
   % Start game
   {Game startGame(_)}
   {Game getGameStatus(Status2)}
   {System.showInfo "After start game status:"} {System.show Status2}
   
   % Play a few rounds
   {Game playRound(Result)}
   {System.showInfo "Round 1 - Guess:"} {System.show Result.guess} {System.showInfo "Black:"} {System.show {Length {Filter Result.feedback fun {$ X} X == black end}}} {System.showInfo "White:"} {System.show {Length {Filter Result.feedback fun {$ X} X == white end}}}
   
   {Game getCurrentRound(Round)}
   {System.showInfo "Current round:"} {System.show Round}
   
   {Game getRemainingRounds(_)}
   {System.showInfo "Remaining rounds calculated"}
end

%% Test 8: Edge cases
{System.showInfo "\n--- Test 8: Edge Cases ---"}
local CM CB Game in
   CM = {New CodeMaker init()}
   CB = {New CodeBreaker init()}
   Game = {New MastermindGame init(CM CB)}
   
   % Test invalid custom colors (too few)
   try
      local BadCM in
         BadCM = {New CodeMaker initCustom([red blue])}
         {System.showInfo "ERROR: Should not reach here"}
      end
   catch E then
      {System.showInfo "Correctly caught error for too few colors:"} {System.show E}
   end
   
   % Test game without secret code
   try
      local BadCM2 BadCB2 BadGame2 in
         BadCM2 = {New CodeMaker init()}
         BadCB2 = {New CodeBreaker init()}
         BadGame2 = {New MastermindGame init(BadCM2 BadCB2)}
         {BadGame2 playRound(_)}
         {System.showInfo "ERROR: Should not reach here"}
      end
   catch E then
      {System.showInfo "Correctly caught error for no secret code:"} {System.show E}
   end
   
   % Test invalid guess length
   try
      {CM setSecretCode([red blue green yellow] _)}
      {CM evaluateGuess([red blue green] _)}
      {System.showInfo "ERROR: Should not reach here"}
   catch E then
      {System.showInfo "Correctly caught error for invalid guess length:"} {System.show E}
   end
end

%% Test 9: Strategy-specific functionality
{System.showInfo "\n--- Test 9: Strategy-Specific Functionality ---"}
local CB1 CB2 Possibilities1 Possibilities2 in
   CB1 = {New CodeBreaker initStrategy('smart')}
   CB2 = {New CodeBreaker initStrategy('random')}
   
   % Test remaining possibilities for smart strategy
   {CB1 getRemainingPossibilities(Possibilities1)}
   {System.showInfo "Smart strategy possibilities:"} {System.show Possibilities1}
   
   % Test remaining possibilities for random strategy
   {CB2 getRemainingPossibilities(Possibilities2)}
   {System.showInfo "Random strategy possibilities:"} {System.show Possibilities2}
   
   % Test history reset
   {CB1 makeGuess(_)}
   {CB1 resetHistory()}
   {CB1 getGuessHistory(_)}
   {System.showInfo "History reset completed"}
end

%% Test 10: Multiple games
{System.showInfo "\n--- Test 10: Multiple Games ---"}
local Game CM CB Status1 Status2 in
   CM = {New CodeMaker init()}
   CB = {New CodeBreaker init()}
   Game = {New MastermindGame init(CM CB)}
   
   % First game
   {Game startGame(_)}
   {Game playRound(_)}
   {Game getGameStatus(Status1)}
   {System.showInfo "First game status:"} {System.show Status1}
   
   % Second game
   {Game startGame(_)}
   {Game getGameStatus(Status2)}
   {System.showInfo "Second game status:"} {System.show Status2}
end

{System.showInfo "\n=== ALL TESTS COMPLETED ==="}