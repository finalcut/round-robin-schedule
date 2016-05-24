require './roundrobin.rb'

replaceByes = true
assignRefs = true


if(ARGV.length > 0 && ARGV[0] == 'usage')

  endLine =  "\n||\n"

  puts "======================================================================================="
  puts "\tUSAGE"
  puts "======================================================================================="
  puts "||\tTakes in up to two arguments; both true/false:" + endLine
  puts "||\t\t 1. replace byes with double header : default = true" + endLine
  puts "||\t\t 2. assign refs from teams : default = true" + endLine

  puts "||\tExample 1:" + endLine
  puts "||\t\t\truby kickball.rb false" + endLine
  puts "||\tWill generate the schedule, not replace byes, and will assign refs" + endLine

  puts "||\tExample 2:\n||\n"
  puts "||\t\t\truby kickball.rb true false" + endLine
  puts "||\tWill generate the schedule, will replace byes, and will NOT assign refs" + endLine

  puts "||\tAt the moment arguments are positional and can not be named at the command line." + endLine

  puts "||" + endLine

  puts "||\tARGUMENTS, other than 'usage' DONT WORK CURRENTLY, EDIT THIS FILE IF YOU REALLY WANT TO CHANGE THINGS" + endLine

  puts "======================================================================================="
  abort
end



teams = ['Pitches Be Crazy',
      'Balls Deep',
      'Bonecrushers',
      'Grapes of Wrath',
      'Ice Cream',
      'Wasted Potential',
      'Bag Tag',
      'White Moose Knuckle']

fields = ['Upper','Lower']

startTimes = ['2:00PM','3:30PM']

schedule = RoundRobin.new(teams,fields,startTimes,replaceByes,assignRefs)
schedule.to_s
