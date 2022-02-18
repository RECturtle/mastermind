# It's a bit of spaghetti code, but it works
# Future refactors would split the human and computer components apart
# and move the standard game logic on it's own
# Also, the computer always wins if that is selected, but was more interested
# in implementing the algo than a fair game :) 
class Mastermind
    OPTIONS = ["1", "2", "3", "4", "5", "6"]
    SIZE = 4
    POSSIBLE_PATTERNS = OPTIONS.product(*Array.new(SIZE - 1) { OPTIONS })

    def play
        @play_again = true
        @gametype = get_choice
        @gametype == 'computer' ? computer_game : player_game
    end

    def get_choice
        loop do
            puts "Make or break a code? p.s. the computer never loses ;)"
            res = gets.chomp.downcase
            if res == 'make' || res == 'break'
                return res == 'make' ? 'computer' : 'human'
            end
            puts ""
            puts "Enter make or break to proceed"
        end
    end
    
    def player_game
        while @play_again == true
            code = create_random_code
            last_guess = []
            guesses_left = 12
            matches = nil

            while guesses_left > 0 
                display_round(guesses_left, last_guess, matches)
                guess = get_pattern
                matches = clue_check(code, guess)
                break if matches[:exact_matches] == 4
                last_guess = guess.clone
                guesses_left -= 1
            end

            if guesses_left == 0
                display_loss
            else
                display_winner
            end
            play_again
        end
    end
    
    def create_random_code
        code = 4.times.map{ rand(1..6).to_s }
    end

    def get_pattern
        loop do
            guess = gets.chomp.split('')
            if guess.length != 4
                puts "Only enter 4 numbers, please."
            elsif !guess.join().match(/^[1-6]+$/)
                puts "Only enter numbers between 1-6"
            else
                return guess
            end
        end
    end

    def computer_game
        while @play_again == true
            unused_patterns = POSSIBLE_PATTERNS.clone
            potential_patterns = unused_patterns.clone
      
            last_guess = []
            guesses_left = 12
            matches = nil          
            guess = ["1", "1", "2", "2"]
            puts ""
            puts "Enter your code!"
            code = get_pattern

            while guesses_left > 0
                display_round(guesses_left, last_guess, matches)
                puts "Current Guess: #{guess.join('')}"
                last_guess = guess.clone
                matches = clue_check(code, guess)
      
                # win condition
                break if matches[:exact_matches] == 4
        
                # Get current guess out of potential patterns
                unused_patterns.reject! { |pattern| pattern == guess }
      
                # remove patterns that do not provide the same score
                # if the current guess were the code
                potential_patterns.reject! do |potential_pattern|
                    clue_check(guess, potential_pattern) != matches
                end
                
                # generate the next guess
                guess = generate_guess(unused_patterns, potential_patterns)
    
                guesses_left -= 1
            end
    
            if guesses_left == 0
                display_loss
            else
                display_winner
            end
            play_again
        end
    end

    # Learning how to identify the next best guess was difficult, but google was helpful :) 
    def generate_guess(unused_patterns, potential_patterns)
        possible_guesses = unused_patterns.map do |possible_guess|
            hits = potential_patterns.each_with_object(Hash.new(0)) do |potential_pattern, counts|
                counts[clue_check(potential_pattern, possible_guess)] += 1
            end
            max_hits = hits.values.max || 0

            # 0 will ensure we pull grab only a valid min guess
            valid = potential_patterns.include?(possible_guess) ? 0 : 1

            [max_hits, valid, possible_guess]
        end

        return possible_guesses.min.last        
    end

    def clue_check(pattern, guess)
        matches = {exact_matches: 0, wrong_location: 0}
        pattern_clone = pattern.clone
        guess_clone = guess.clone

        guess_clone.each_index do |index|
            if pattern_clone[index] == guess_clone[index]
                matches[:exact_matches] += 1
                guess_clone[index] = "x"
                pattern_clone[index] = "o"
            end
        end

        guess_clone.each_index do |index|        
            match_index = pattern_clone.index(guess_clone[index])
            if match_index
                matches[:wrong_location] += 1
                pattern_clone[match_index] = "o"
            end
        end

        matches
    end
        
    def play_again
        puts "Would you like to play again? Enter y to play again, anything else to stop."
        res = gets.chomp.downcase
        if res == 'y'
            play
        else
            @play_again = false
        end

    end

    def display_round(guesses_left, last_guess, clues)
        puts ""
        puts "==============================================="
        puts "Guesses Left #{guesses_left}"
        puts "==============================================="
        puts "Guess 4 digits (1-6) to try and break the code!" if @gametype == 'human'
        puts "Last Guess: #{last_guess.join('')}" if !last_guess.empty?
        puts "Clues: Matches: #{clues[:exact_matches]} - Close: #{clues[:wrong_location]}" if guesses_left < 12
        puts ""
    end

    def display_winner
        puts ""
        puts "==============================================="
        puts "#{@gametype == 'computer' ? 'Computer Overlords' : 'You'} Win!"
        puts "==============================================="
        puts ""
    end

    def display_loss
        puts ""
        puts "==============================================="
        puts "YOU LOSE lol"
        puts "==============================================="
        puts ""
    end
end

Mastermind.new.play