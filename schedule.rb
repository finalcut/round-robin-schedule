teams = ['White Moose Knuckles','Waka Shame','Bone Crushers','Wasted Potential','Grapes of Wrath','Silly Nannies','Team Bagtag','Ice Cream Team','Ultimately Intoxicated']
replaceByesWithDoubleHeader = false


byeMarker = 'BYE'
if(teams.length % 2)
  teams << byeMarker
end
dh = []

# create a round robin schedule - taken from http://stackoverflow.com/a/1916548/7329
schedule = (1...teams.size).map do |r|
  t=teams.dup
  (0...(teams.size/2)).map do |_|
    [t.shift, t.delete_at(-(r % t.size + (r >= t.size * 2 ? 1 : 0)))]
  end
end

# get rid of byes and give each team a double-header instead
if(replaceByesWithDoubleHeader)
  schedule.length.times do |i|
    week = schedule[i]
    week.length.times do |x|
      game = week[x]
      if(game[1]==byeMarker)
          home = game[0]
          teams.each do |team|
            if(team != home && team != byeMarker && !dh.include?(team))
              game[1] = team
              dh << team
              break
            end
          end
          week[x] = game
      end
    end
    schedule[i] = week
  end
end

# print out the schedule
schedule.length.times do |i|
  puts "Week " + (i+1).to_s
  week = schedule[i]
  week.length.times do |x|
    game = week[x]
    puts "\t" + "Game " + (x+1).to_s + " " + game[0] + " -vs- " + game[1]
  end
  if(dh.length > i)
    puts "\t" + "Double Header : " + dh[i]
  end
end
