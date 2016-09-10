#!/usr/bin/ruby

require 'csv'
require 'gv'

g = GV::Graph.open('G', :undirected)
g[:rankdir] = 'LR'
g[:outputorder] = 'edgesfirst'

class Party
  attr_reader :name
  attr_reader :answers
  attr_reader :node

  @@parties = []

  def initialize(g, name)
    @name = name
    @answers = []
    @node = g.node(name, shape: 'ellipse', margin: '.04', fontsize: '11', style: 'filled', fillcolor: '#ffffff', fontname: 'opensans')
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

  def self.create_edges(g)
    for i in 0...@@parties.size
      for j in (i+1)...@@parties.size
        p1 = @@parties[i]
        p2 = @@parties[j]
        distance = p1.similar(p2).to_f / 8
        g.edge('', p1.node, p2.node, arrowtype: 'none', color: '#aaaaaa', len: distance.to_s)
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
    row.each { |party_name| Party.new(g, party_name) }
  else
    Party.answer row
  end
end

Party.create_edges(g)

g.save('wahlomat-vis.png', 'png', 'neato')
