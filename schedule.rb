

class RoundRobin
  @@refKey = "THRESHOLD"
  @@byeMarker = "BYE"
  @replaceByesWithDoubleHeader
  @assignRefs
  @teams = []

  @dh = [] #track double headers
  @refCount = {} #track number of times a team refs

  @schedule = []

  def initialize(teams, replaceByesWithDoubleHeader=true, assignRefs=true)
    @teams = teams
    @replaceByesWithDoubleHeader = replaceByesWithDoubleHeader
    @assignRefs = assignRefs

    @refCount = {}
    @dh = []
    @schedule = []


    # initialize refcounts to 0 for each team


    @teams.each do |team|
      @refCount[@@refKey] = 1
      @refCount[team] = 0
    end

    if(@teams.length % 2)
      @teams << @@byeMarker
    end

    build_schedule

  end

  def build_schedule
    build_round_robin
    build_double_headers
    build_ref_schedule
  end


  def assign_refs(game,immuneTeam)
    @teams.each do |team|
      if team != immuneTeam && team != @@byeMarker
        if (not game.include?(team)) && (@refCount[team] < @refCount[@@refKey])
          game[2] = team
          @refCount[team] += 1
          break
        end
      end
    end
    return game
  end


  def build_round_robin
    # create a round robin schedule - taken from http://stackoverflow.com/a/1916548/7329
    @schedule = (1...@teams.size).map do |r|
      t=@teams.dup
      (0...(@teams.size/2)).map do |_|
        [t.shift, t.delete_at(-(r % t.size + (r >= t.size * 2 ? 1 : 0)))]
      end
    end
  end

  # get rid of byes and give each team a double-header instead
  def build_double_headers
    if @replaceByesWithDoubleHeader
      @schedule.length.times do |i|
        week = @schedule[i]
        week.length.times do |x|
          game = week[x]
          if(game[1]==@@byeMarker)
              home = game[0]
              @teams.each do |team|
                if(team != home && team != @@byeMarker && !@dh.include?(team))
                  game[1] = team
                  @dh << team
                  break
                end
              end
              week[x] = game
          end
        end
        @schedule[i] = week
      end
    end
  end

  def build_ref_schedule
    if @assignRefs
      # figure out who is reffing what game.  Double header team and byeMarker can't ref
      @schedule.length.times do |i|
        week = @schedule[i]

        # team that can't be scheduled
        immuneTeam = (@dh.count >= i) ? @dh[i] : @@byeMarker

        #looping over each game
        week.length.times do |x|

          game = week[x]

          # determine if every team is at the threshold, if so, increment threshold
           incrementThreshold = true
           @refCount.each do |key, value|
              if key != @@refKey
                if(value < @refCount[@@refKey])
                  incrementThreshold = false
                  break
                end
              end
           end
           if incrementThreshold
             @refCount[@@refKey] += 1
           end

          if game.include? @@byeMarker
            # skip this game; no ref needed
          else
            game = assign_refs(game,immuneTeam)
            if(game.length == 2) then
              # we dont have a ref and need to bump threshold and try again
              @refCount[@@refKey] += 1
              game = assign_refs(game,immuneTeam)
            end


          end
          week[x] = game
        end
        @schedule[i] = week
      end
    end
  end

  def to_s
    # print out the schedule
    @schedule.length.times do |i|
      puts "======================================================================"
      puts "Week " + (i+1).to_s
      puts "======================================================================"
      week = @schedule[i]
      week.length.times do |x|
        game = week[x]
        puts "\t" + "Game " + (x+1).to_s + ": " + game[0] + " -vs- " + game[1]
        if @assignRefs
          if(game.include?(@@byeMarker))
             puts "\n\t\t\t" + "Referee: NONE - " + @@byeMarker
          else
            puts  "\n\t\t\t" + "Referee: " + game[2]
          end
          puts "\n"
        end
      end
      if(@dh.length > i)
        puts "\t" + "Double Header : " + @dh[i]
      end
    end
  end


end


teams = ['White Moose Knuckles','Waka Shame','Bone Crushers','Wasted Potential','Grapes of Wrath','Silly Nannies','Team Bagtag','Ice Cream Team','Ultimately Intoxicated']

schedule = RoundRobin.new(teams,false,true)
schedule.to_s
