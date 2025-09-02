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
               case List of nil then nil
               [] H|T then
                  case {List.partition T fun {$ X} X == H end} of [Same Rest] then
                     (H|{Length Same + 1}) | {CountColors Rest}
                  end
               end
            end
            
            fun {CountWhite Secret Guess}
               local
                  SecretCounts = {CountColors @secretCode}
                  GuessCounts = {CountColors Guess}
                  
                  fun {CountCommon Counts1 Counts2}
                     case Counts1 of nil then 0
                     [] (Color|Count1)|Rest1 then
                        case {List.partition Counts2 fun {$ (C|_)} C == Color end} of [Found Rest2] then
                           case Found of nil then {CountCommon Rest1 Counts2}
                           [] (Color|Count2)|_ then
                              {Min Count1 Count2} + {CountCommon Rest1 Rest2}
                           end
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
      case @strategy of 'random' then
         local
            fun {RandomColor Colors}
               local Index in
                  Index = {OS.rand} mod {Length Colors}
                  {Nth Colors Index + 1}
               end
            end
            fun {GenerateRandomGuess Colors Count}
               if Count == 0 then nil
               else
                  {RandomColor Colors} | {GenerateRandomGuess Colors Count - 1}
               end
            end
         in
            Result = {GenerateRandomGuess @availableColors 4}
         end
      [] 'systematic' then
         local
            fun {GenerateSystematicGuess Round}
               local
                  Colors = @availableColors
                  NumColors = {Length Colors}
                  fun {GetColor Index}
                     {Nth Colors (Index mod NumColors) + 1}
                  end
               in
                  [{GetColor Round} {GetColor Round + 1} {GetColor Round + 2} {GetColor Round + 3}]
               end
            end
         in
            Result = {GenerateSystematicGuess {Length @guessHistory + 1}}
         end
      [] 'smart' then
         local
            fun {GenerateSmartGuess}
               case @guessHistory of nil then
                  [red red blue blue]
               [] H|T then
                  case H.feedback of nil then [red red blue blue]
                  else
                     local
                        fun {FindBestGuess}
                           case @availableColors of nil then [red red blue blue]
                           [] C|Rest then
                              [C C {Nth @availableColors 2} {Nth @availableColors 3}]
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
      guessHistory := record(guess: Result roundNumber: {Length @guessHistory + 1}) | @guessHistory
   end
   
   meth makeSpecificGuess(SuggestedGuess ?Result)
      %% Makes a specific guess (overrides strategy)
      %% Input: SuggestedGuess :: [Color] - Specific guess to make
      %% Output: Result :: Bool - true if guess was accepted and recorded
      %% Note: If SuggestedGuess is invalid, return false
      %% Side effects: Records guess in history
      if {self isValidGuess(SuggestedGuess $)} then
         guessHistory := record(guess: SuggestedGuess roundNumber: {Length @guessHistory + 1}) | @guessHistory
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
      feedbackHistory := record(guess: Guess feedback: Feedback roundNumber: {Length @feedbackHistory + 1}) | @feedbackHistory
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