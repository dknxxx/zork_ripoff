# http://www.lafn.org/webconnect/mentor/zork/zorkText.htm

require_relative 'text_adventure'

game = TextAdventure.new do
  # nodes

  west_of_house = Node.new
  west_of_house.name = 'West of House'
  west_of_house.description = 'This is an open field west of a white house, with a boarded front door.'

  south_of_house = Node.new
  south_of_house.name = 'South of House'
  south_of_house.description = '...'

  # link nodes

  west_of_house.link(south_of_house, :south)
  west_of_house.link(south_of_house, :southeast)

  south_of_house.link(west_of_house, :west)
  south_of_house.link(west_of_house, :northwest)

  # objects

  mailbox = GameObject.new
  mailbox.name = 'mailbox'
  mailbox.overview = 'There is a small mailbox here.'
  mailbox.description = 'I see nothing special about the mailbox.'
  west_of_house.objects.push(mailbox)

  rubber_mat = GameObject.new
  rubber_mat.name = 'rubber mat'
  rubber_mat.overview = "A rubber mat saying 'Welcome to Zork!' lies by the door."
  rubber_mat.description = 'Welcome to Zork!'
  west_of_house.objects.push(rubber_mat)

  # starting node

  self.current_node = west_of_house
end

game.start
