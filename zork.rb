require_relative 'text_adventure'

game = TextAdventure.new do
  # nodes

  west_of_house = Node.new
  west_of_house.name = 'West of House'
  west_of_house.description = 'This is an open field west of a white house, with a boarded front door.'

  # link nodes

  # link_bidrectional(wasteland, town, :east)

  # objects

  mailbox = GameObject.new
  mailbox.name = 'mailbox'
  mailbox.description = 'I see nothing special about the mailbox.'
  west_of_house.objects.push(mailbox)

  rubber_mat = GameObject.new
  rubber_mat.name = 'rubber mat'
  rubber_mat.description = 'Welcome to Zork!'
  west_of_house.objects.push(rubber_mat)

  # starting node

  self.current_node = west_of_house
end

game.start
