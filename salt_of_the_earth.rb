require_relative 'text_adventure'

game = TextAdventure.new do
  # nodes

  wasteland = Node.new
  wasteland.name = 'Wasteland'
  wasteland.description = 'and so it begins'
  
  town = Node.new
  town.name = 'Former Salt Lake City'
  town.description = 'A guard approaches: I used to be a text adventurer like you, but then I stumbled over my words in the knee.'
  
  jail_cell = Node.new
  jail_cell.name = 'Your Private Cell'
  jail_cell.description = 'A dark and dank (not like that you stoners) room that makes you seriously regret your situation.'

  # link nodes

  link_bidrectional(wasteland, town, :east)

  # objects

  statue = GameObject.new
  statue.name = 'statue'
  statue.overview = 'A ruined statue lays before you.'
  statue.description = %q=  Two vast and trunkless legs of stone
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

  wig = GameObject.new
  wig.active = false
  wig.scenery = false
  wig.can_take = true
  wig.name = 'wig'
  wig.description = 'a bloody wig'
  town.objects.push(wig)

  mayor = GameObject.new
  mayor.on_action(/(talk|speak|approach) (with|to)/i) {
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
  mayor.active = false
  mayor.name = 'mayor'
  mayor.overview = 'The mayor, Cameron the Salty, leads the mob.'
  mayor.description = 'The saltiest of the salties'
  town.objects.push(mayor)

  angry_mob_directions_left = [:east, :west, :north, :south]
  angry_mob = GameObject.new
  angry_mob.parser = InputParser.new do |input|
    add(/(go|move) (.*)/i) { |match|
     direction = match[2].downcase.to_sym
     angry_mob_directions_left.delete(direction)
     if angry_mob_directions_left.empty?
       puts "The mayor approaches"
       mayor.active = true
       puts current_node.overview
     else
       puts "The angry mob prevents you from leaving"
      end
    }
  end
  angry_mob.active = false
  angry_mob.name = 'angry mob'
  angry_mob.description = 'The angriest of mobs'
  town.objects.push(angry_mob)

  clown = GameObject.new
  clown_is_dead = false
  clown.on_action(/approach/i) {
    if clown_is_dead
      puts "The clown kinda smells."
    else
      ask_question('This crazy motherfucker named Connor the Clown tries to gut you. Stab that bitch in the face?') {
        add(/yes/i) {
          puts 'You kill him.'
          clown.overview = "The clown's corpse lays in the street."
          clown.description = 'You killed him. He has a bloody wig on.'
          clown_is_dead = true
          wig.active = true
          angry_mob.active = true
          puts current_node.overview
        }
        add(/no/i) {
          puts 'You are dead.'
          end_game
        }
      }
    end
  }
  clown.name = 'clown'
  clown.description = 'a crazy clown, maybe you should approach him'
  town.objects.push(clown)

  wig.on_action(/take/i) {
    clown.active = false
  }

  window = GameObject.new
  window.name = 'window'
  window.overview = 'There is a window to the north of the cell.'
  window.description = 'A small, cobwebbed opening protected by bars.'
  jail_cell.objects.push(window)

  bars = GameObject.new
  bars.scenery = false
  bars.name = 'bars'
  bars.description = 'Rusty old bars that look like they can be pushed.'
  jail_cell.objects.push(bars)

  bars.on_action(/push/i) {
    ask_question('Are you sure you want to do this?') {
      add(/yes/i) {
        puts 'You push the bars with all your strength. After a great deal of struggling, they come loose. Unfortunately, so does the top block of stone, crushing your hands and causing you to bleed out. You died.'
        end_game
      }
      add (/no/i) {
        puts 'Okay... Well I hope you are comfortable in your cell.'
      }
    }
  }

  door = GameObject.new
  door.name = 'door'
  door.overview = 'To the south is the door.' 
  door.description = 'A solid wood door with a small viewing slot. The lock looks like it can be picked with a stick.'
  jail_cell.objects.push(door)

  guard = GameObject.new
  guard.name = 'Guard'
  guard.overview = 'You can hear a guard murmuring to himself on the other side of the door.'
  guard.description = 'That guard assigned to you. He has a secret passion for dressing up in wigs.'
  jail_cell.objects.push(guard)

  # starting node

  self.current_node = wasteland
end

game.start
