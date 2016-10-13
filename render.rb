#!/usr/bin/ruby

require 'csv'
require 'gv'

class Party
  attr_reader :name
  attr_reader :answers
  attr_reader :node

  @@parties = []

  def initialize(name)
    @name = name
    @answers = []
    @@parties << self
  end

  def answer(str)
    @answers << str.to_i
  end

  def similar(party)
    value = 0
    @answers.each_with_index do |answer,index|
      value += (answer - party.answers[index]).abs
    end
    return value
  end

  def self.create_nodes(g)
    @@parties.each do |p|
      g.puts '  "' + p.name + '" [fillcolor="#ffffff",fontname=opensans,fontsize=11,height=0.5,margin=.04,shape=ellipse,style=filled];'
    end
  end

  def self.create_edges(g)
    for i in 0...@@parties.size
      for j in (i+1)...@@parties.size
        p1 = @@parties[i]
        p2 = @@parties[j]
        distance = p1.similar(p2).to_f / 8
        g.puts '  "' + p1.name + '" -- "' + p2.name + '" [arrowtype=none,color="#aaaaaa",len=' + distance.to_s + '];'
      end
    end
  end

  def self.answer row
    row.each_with_index do |answer,index|
      @@parties[index].answer answer
    end
  end
end

first = true
CSV.foreach(ARGV[0]) do |row|
  if first then
    first = false
    row.each { |party_name| Party.new(party_name) }
  else
    Party.answer row
  end
end

dotname = File.basename(ARGV[0], ".csv") + ".dot"
pngname = File.basename(ARGV[0], ".csv") + ".png"

g = open(dotname, "w")
g.puts 'graph {'
g.puts '  graph [outputorder=edgesfirst,rankdir=LR];'
g.puts '  node [label="\\N"];'
Party.create_nodes(g)
Party.create_edges(g)
g.puts '}'
g.close

if (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/) then
  `"C:\\Program Files\\Graphviz2.38\\bin\\neato.exe" #{dotname} -Tpng -o #{pngname}`
else
  `neato #{dotname} -Tpng -o #{pngname}`
end
