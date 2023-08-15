require 'colorize'
require 'rainbow'

# I've implemented the colorize and rainbow gems to add a little life to this simple hangman script.
# Although rainbow isn't ideal, i did however find it rather cool as I haven't tinkered with that gem before.

CHAMPIONS = %w[Aatrox Ahri Akali Alistar Amumu Anivia Annie Ashe AurelionSol Azir] # - Update champions here, remember to update hints if adding more.

class Hangman
  attr_accessor :word, :guessed_letters, :incorrect_guesses, :hint_used

  def initialize(word) # This is o
    @word = word
    @guessed_letters = []
    @incorrect_guesses = 0
    @hint_used = false
    @hint_prompted = false
  end


  # We can edit our hints below here or add more(if added more champs)
  def give_hint
    return if @hint_used

    case @word
    when 'Ahri'
      puts "Hint: my charm is irresistible..".colorize(:yellow)
    when 'Amumu'
      puts "I'm drowning in my tears..".colorize(:yellow)
    when 'Akali'
      puts "Hint: I'm the only assassin who can only succeed.".colorize(:yellow)
    when 'Alistar'
      puts "Moooo support".colorize(:yellow)
    when 'Anvia'
      puts "Ice is the power I needed in order to conqueror this land."
    when 'AurelionSol'
      puts "Big ass flying dragon!"
    when 'Azir'
      puts "Shurima calls me."
    when 'Annie'
      puts "Tibbers doesn't wanna come out and play :("
    when 'Ashe'
      puts "My arrow WILL stop the frejlord."
    else
      puts "No hint available for this Champion I'm afraid.".colorize(:red)
    end

    @hint_used = true # Set hint_used to true after providing a hint
  end


  def display_word
    displayed_word = @word.chars.map do |letter|
      if @guessed_letters.include?(letter.downcase)
        letter.colorize(:green)
      else
        '_'.colorize(:red)
      end
    end
    puts displayed_word.join(" ")
  end

  def make_guess(letter)
    @guessed_letters << letter.downcase

    unless @word.downcase.include?(letter.downcase)
      @incorrect_guesses += 1

      unless @hint_prompted
        puts "Would you like a hint? Type 'hint' to get a hint ot get one or press Enter to continue."
        hint_input = gets.chomp.downcase
        give_hint if hint_input == 'hint'
        @hint_prompted = true
      end
    end
  end


  # Saving the game - We'll serialize the game using Ruby's built in Marshal module and save it to a file.
  def save_game
    serialized_game = Marshal.dump(self)
    File.open('saved_game', 'w') { |file| file.puts(serialized_game) }
    puts "Game saved!"
  end

  # For loading the game we need a class method.(Since we are actually loading an instance of the actual game here.)
  # We will deserialize the saved file back into a Hangman object.

  def self.load_game
    if File.exist?('saved_game')
      saved_game = File.read('saved_game')
      game = Marshal.load(saved_game)
      puts "Game loaded!"
      game
    else
      puts "No saved game found!"
      nil
    end
  end

  # This is us creating our method to the state of the game.
  def game_over?
    won? || lost?
  end

  def won?
    @word.chars.all? { |letter| @guessed_letters.include?(letter.downcase) }
  end

  def lost?
    @incorrect_guesses >= 6
  end

    # This is our method to check if the player has won, lost, or if the game is still on-going.
    def display_outcome
      if won?
        puts "Victory! You've guessed the champion! The champion was: #{@word}".colorize(:green)
        post_game_menu
      elsif lost?
        puts "Defeat! The champion was: #{@word}".colorize(:red)
        post_game_menu
      else
        puts "Game is ongoing..."
      end
    end
end

# In this method we try to keep the player around and implement an exit feature.
def post_game_menu
  puts "Would you like to play a (N)ew game, or (E)xit?".colorize(:orange)
  choice = gets.chomp.downcase

  case choice
  when 'n'
    start_game
  when 'e'
    puts "Sayonara Summoner!".colorize(:pink)
    exit
  else
    puts "Invalid choice. Try again."
    post_game_menu
  end
end


# ------------------------------------- starting the game.

def flashing_rainbow_text(text, duration = 0.7)
  colors = [:red, :orange, :yellow, :green, :blue, :indigo, :violet]
  start_time = Time.now

  while Time.now - start_time < duration
    colors.each do |color|
      system("clear")
      puts text.colorize(color)
      sleep(0.5)
    end
  end
end

def start_game
  flashing_rainbow_text("Welcome to League of Legends Hangman!")

  puts "Would you like to (N)ew game, (L)oad game or (E)xit?".colorize(:cyan)
  choice = gets.chomp.downcase

  case choice
  when 'n'
    # Pick a random champion name and initialize a new game.
    word = CHAMPIONS.select { |champion| champion.length.between?(5, 12) }.sample
    game = Hangman.new(word)
  when 'l'
    game = Hangman.load_game
    return unless game # exit if no saved game was found
  when 'e'
    puts "Goodbye!"
    exit
  else
    puts "Invalid choice. Try again."
    start_game
    return
  end

  # Main game loop
  until game.game_over?

    # Display the current state of the word
    game.display_word

    # Ask the player for their guess.
    puts "Guess a letter or type 'save' to save the game:".colorize(:pink)
    input = gets.chomp.downcase

    if input == 'save'
      game.save_game
      puts "Game saved! Exiting..."
      exit
    elsif input == 'hint'
      game.give_hint
    else
      game.make_guess(input)
    end
  end

  # Once the game is over, we can display the outcome.
  game.display_outcome
end

# Start the game by invoking start_game.
start_game