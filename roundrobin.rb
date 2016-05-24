class RoundRobin
  @@REFKEY = "THRESHOLD"
  @@BYEMARKER = "BYE"
  @replaceByesWithDoubleHeader
  @assignRefs
  @maxWeeks
  @teams = []
  @fields = []
  @startTimes = []

  @dh = [] #track double headers
  @refCount = {} #track number of times a team refs

  @schedule = []

  def initialize(teams, fields, startTimes, replaceByesWithDoubleHeader=true, assignRefs=true, maxWeeks=0)
    @teams = teams
    @fields = fields
    @startTimes = startTimes
    @replaceByesWithDoubleHeader = replaceByesWithDoubleHeader
    @assignRefs = assignRefs
    @maxWeeks = maxWeeks

    @refCount = {}
    @dh = []
    @schedule = []


    # initialize refcounts to 0 for each team


    @teams.each do |team|
      @refCount[@@REFKEY] = 1
      @refCount[team] = 0
    end

    if(@teams.length % 2 != 0)
      @teams << @@BYEMARKER
    end

    build_schedule


  end

  def to_s
    # print out the schedule
    @schedule.length.times do |i|
      puts "======================================================================"
      if(@dh.length > i)
        puts "Week " + (i+1).to_s + "\t\t\t[Double Header : " + @dh[i] + "]"
      else
        puts "Week " + (i+1).to_s
      end
      puts "======================================================================"
      week = @schedule[i]
      week.length.times do |x|
        game = week[x]
        puts "Field: " + game[3] + " Start Time: " + game[4]
        puts "\n"
        puts "\t" + "Game " + (x+1).to_s + ": " + game[0] + " -vs- " + game[1]
        if @assignRefs
          if(game.include?(@@BYEMARKER))
             puts "\n\t\t\t" + "Referee: NONE - " + @@BYEMARKER
          else
            puts  "\n\t\t\t" + "Referee: " + game[2]
          end
          puts "\n"
        end
      end
    end
  end

  private # all methods that follow will be made private: not accessible to outside objects

  def build_schedule
    build_round_robin
    build_double_headers
    build_ref_schedule
    organize_schedule
  end


  def assign_refs(game,immuneTeam)
    @teams.each do |team|
      if team != immuneTeam && team != @@BYEMARKER
        if (not game.include?(team)) && (@refCount[team] < @refCount[@@REFKEY])
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
          if(game[1]==@@BYEMARKER)
              home = game[0]
              @teams.each do |team|
                if(team != home && team != @@BYEMARKER && !@dh.include?(team))
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
      # figure out who is reffing what game.  Double header team and BYEMARKER can't ref
      @schedule.length.times do |i|
        week = @schedule[i]

        # team that can't be scheduled
        immuneTeam = (@dh.count >= i) ? @dh[i] : @@BYEMARKER

        #looping over each game
        week.length.times do |x|

          game = week[x]

          # determine if every team is at the threshold, if so, increment threshold
           incrementThreshold = true
           @refCount.each do |key, value|
              if key != @@REFKEY
                if(value < @refCount[@@REFKEY])
                  incrementThreshold = false
                  break
                end
              end
           end
           if incrementThreshold
             @refCount[@@REFKEY] += 1
           end

          if game.include? @@BYEMARKER
            # skip this game; no ref needed
          else
            game = assign_refs(game,immuneTeam)
            if(game.length == 2) then
              # we dont have a ref and need to bump threshold and try again
              @refCount[@@REFKEY] += 1
              game = assign_refs(game,immuneTeam)
            end


          end
          week[x] = game
        end
        @schedule[i] = week
      end
    end
  end

  def organize_schedule
    fieldIdx = 0;
    startTimeIdx = 0;

    @schedule.length.times do |i|
      week = @schedule[i]
      fieldIdx = 0;
      startTimeIdx = 0;

      week.length.times do |x|
        game = week[x]

        field = @fields[fieldIdx]
        startTime = @startTimes[startTimeIdx]

        game[3] = field
        game[4] = startTime

        fieldIdx = fieldIdx + 1
        if(fieldIdx >= @fields.length)
          fieldIdx = 0
        end

        if(fieldIdx == 0)
          startTimeIdx = startTimeIdx+1
        end
        if(startTimeIdx >= @startTimes.length)
          startTimeIdx = 0
        end


      end
    end
  end
end
