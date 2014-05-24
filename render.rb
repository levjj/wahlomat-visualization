#!/usr/bin/ruby

require 'csv'
require 'gv'

G = Gv.graph("G")
N = Gv.protonode(G)
E = Gv.protoedge(G)

Gv.setv(G, 'rankdir', 'LR')
Gv.setv(G, 'outputorder', 'edgesfirst')
Gv.setv(N, 'shape', 'ellipse')
Gv.setv(N, 'margin', '.04')
Gv.setv(N, 'fontsize', '11')
Gv.setv(N, 'style', 'filled')
Gv.setv(N, 'fillcolor', '#ffffff')
Gv.setv(N, 'fontname', 'helvetica')
Gv.setv(E, 'arrowtype', 'none')
Gv.setv(E, 'color', '#aaaaaa')

class Party
  attr_reader :name
  attr_reader :answers
  attr_reader :node

  @@parties = []

  def initialize(name)
    @name = name
    @answers = []
    @node = Gv.node(G, name)
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

  def create_edges
    @@parties.each do |party|
      return if party == self
      edge = Gv.edge(@node, party.node)
      distance = similar(party).to_f / 8
      Gv.setv(edge, "len", distance.to_s)
    end
  end

  def self.create_edges
    @@parties.each { |party| party.create_edges }
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
    row.each { |party_name| Party.new party_name }
  else
    Party.answer row
  end
end

Party.create_edges

Gv.layout(G, 'neato')
Gv.render(G, 'png', 'wahlomat-vis.png')
Gv.render(G, 'svg', 'wahlomat-vis.svg')
