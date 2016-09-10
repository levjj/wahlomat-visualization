#!/usr/bin/ruby

fname = "berlin2016.pdf"

parties = [
  "SPD",
  "CDU",
  "GRÜNE",
  "DIE LINKE",
  "PIRATEN",
  "NPD",
  "FDP",
  "Tierschutzpartei",
  "pro Deutschland",
  "Die PARTEI",
  "DKP",
  "ÖDP",
  "PSG",
  "BüSo",
  "Bergpartei",
  "ALFA",
  "AfD",
  "DIE VIOLETTEN",
  "Graue Panther",
  "MENSCHLICHE WELT",
  "Gesundheitsforschung"]

#               1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38]
lines_per_q = [ 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 1, 1]

parties_per_page = 4


# Implementation below

require 'gv'

gv = GV::Graph.open 'g'
class Party
  attr_reader :name
  attr_reader :answers
  attr_reader :node


  def initialize(gv, name)
    @name = name
    @answers = []
    @node = gv.node(name)
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

  def print
    puts @answers.join ' '
  end
end

parties = parties.map { |p| Party.new(gv, p) }

`mkdir ./tmp`
`pdfseparate #{fname} ./tmp/wahlomat-%d.pdf`

Dir["./tmp/wahlomat-*.pdf"].each do |file|
  `convert #{file} #{file}.png`
end

# negative = 233
# positive = >237
# neutral = >243
#
#
# 1 line = 17
# 2 line = 28

parties.each_slice(parties_per_page).each_with_index do |slice,idx|
  page = "./tmp/wahlomat-#{idx+1}.pdf.png"
  slice.each_with_index do |party,pidx|
    x = 427 + (pidx * (460 - 425))
    y = 86 - 11.75 - lines_per_q[0] * 5
    lines_per_q.each_with_index do |lines, qidx|
      y += 11.75 + lines * 5
      `convert #{page}[#{(454 - 427)}x#{(98 - 86)}+#{x}+#{y.round}] -monochrome -white-threshold 50% ./tmp/answer-#{pidx+(idx * parties_per_page)}-#{qidx}.png`
      val = `convert ./tmp/answer-#{pidx+(idx * parties_per_page)}-#{qidx}.png -format "%[fx:255*mean]" info:`
      ocr = `tesseract -c tessedit_char_whitelist=x -psm 10 ./tmp/answer-#{pidx+(idx * parties_per_page)}-#{qidx}.png stdout`.strip
      if ocr == "x"
        party.answer "1"
      elsif val.to_f >= 242
        party.answer "2"
      else
        party.answer "3"
      end
      y += (lines - 1) * 5
    end
    party.print
  end
end
# `rm -rf ./tmp`

exit 0

G = gv.graph("G")
N = gv.protonode(G)
E = gv.protoedge(G)

gv.setv(G, 'rankdir', 'LR')
gv.setv(G, 'outputorder', 'edgesfirst')
gv.setv(N, 'shape', 'ellipse')
gv.setv(N, 'margin', '.04')
gv.setv(N, 'fontsize', '11')
gv.setv(N, 'style', 'filled')
gv.setv(N, 'fillcolor', '#ffffff')
gv.setv(N, 'fontname', 'helvetica')
gv.setv(E, 'arrowtype', 'none')
gv.setv(E, 'color', '#aaaaaa')

parties.each do |p1|
  parties.each do |p2|
    if p1 != p2 then
      distance = p1.similar(p2).to_f / 8
      gv.edge(p1.node, p2.node, len: distance.to_s)
    end
  end
end

gv.layout('neato')
gv.render('png', 'wahlomat-vis.png')
gv.render('svg', 'wahlomat-vis.svg')
