require_relative 'text_adventure'

game = TextAdventure.new do
  # nodes

  wasteland = Node.new
  wasteland.name = 'wasteland'
  wasteland.description = 'and so it begins'
  
  town = Node.new
  town.name = 'Former Salt Lake City'
  town.description = 'A guard approaches: I used to be a text adventurer like you, but then I stumbled over my words in the knee.'
  
  jail_cell = Node.new
  jail_cell.name = 'Your Private Cell'

  # link nodes

  link_bidrectional(wasteland, town, :east)

  # objects

  statue = GameObject.new
  statue.name = 'statue'
  statue.description = %q=Two vast and trunkless legs of stone
  Stand in the desert. Near them, on the sand,
  Half sunk, a shattered visage lies, whose frown,
  And wrinkled lip, and sneer of cold command,
  Tell that its sculptor well those passions read
  Which yet survive, stamped on these lifeless things,
  The hand that mocked them and the heart that fed:
  And on the pedestal these words appear:
  'My name is Ozymandias, king of kings:
  Look on my works, ye Mighty, and despair!'
  Nothing beside remains. Round the decay
  Of that colossal wreck, boundless and bare
  The lone and level sands stretch far away.=
  wasteland.objects.push(statue)

  dead_clown = GameObject.new do |input|
    add(/take wig/i) {
      puts 'You take the wig.'
      town.objects.delete(dead_clown)
      inventory.push('clown wig')
    }
  end
  dead_clown.name = 'dead clown'
  dead_clown.description = 'You killed him. He has a bloody wig on'

  mayor = GameObject.new do |input|
    add (/(talk|speak) (mayor|Cameron the Salty)/i) {
      ask_question('''Alas, my brother is dead. A new grain of salt has been added to the pile.
      You, foreigner, are responsible and must pay the price. Submit?''') {
        add(/yes/) {
          puts 'You are taken to jail'
          move_to jail_cell
        }
        add(/no/) {
          puts 'The mob guts you like the beast you are.'
          end_game
        }
      }
    }
  end
  mayor.name = 'Cameron the Salty'
  mayor.description = 'The saltiest of the salties'

  angry_mob_directions_left = [:east, :west, :north, :south]
  angry_mob = GameObject.new do |input|
    add (/(go|move) (.*)/i) { |match|
     direction = match[2].downcase.to_sym
     angry_mob_directions_left.delete(direction)
     if angry_mob_directions_left.empty?
       puts "The mayor approaches"
       town.objects.push(mayor)
     else
       puts "The angry mob prevents you from leaving"
      end
    }
  end
  angry_mob.name = 'angry mob'
  angry_mob.description = 'The angriest of mobs'

  clown = GameObject.new do |input|
    add (/approach/i) {
      ask_question('This crazy motherfucker named Connor the Clown tries to gut you. Stab that bitch in the face?') {
        add(/yes/i) {
          puts 'You kill him.'
          town.objects.delete(clown)
          town.objects.push(dead_clown)
          town.objects.push(angry_mob)
        }
        add(/no/i) {
          puts 'You are dead.'
          end_game
        }
      }
    }
  end

  clown.name = 'clown'
  clown.description = 'a crazy clown, maybe you should approach him'
  town.objects.push(clown)

  # starting node

  self.current_node = wasteland
end

game.start
