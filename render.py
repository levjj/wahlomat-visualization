#!/bin/env python3

import argparse
import json
import logging
import os
import subprocess
import tempfile
from typing import List
from urllib import request

REPO = 'https://raw.githubusercontent.com/gockelhahn/qual-o-mat-data'

class Party:

  def __init__(self, id: int, name: str):
    self.id = id
    self.name = name
    self.answers = dict()

  def answer(self, statement: int, answer: int):
    if answer == 0: # positive
      self.answers[statement] = 1.0
    elif answer == 1: # negative
      self.answers[statement] = 0.0
    else: # neutral
      self.answers[statement] = 0.5

  def answer_normalized(self, statement: int, answer: float):
    self.answers[statement] = answer * 20.0

  def similar(self, party) -> int:
    value = 0
    for index, answer in self.answers.items():
      value += abs(answer - party.answers[index])
    return value * 2.0

class Renderer:

  def __init__(self, data_key):
    self.data_key = data_key
    self.parties = dict()

  def open_data(self, path):
    if self.data_key[0] == ".":
      logging.info('Opening file ' + self.data_key + path)
      return open(self.data_key + path, "r")
    else:
      logging.info('Requesting ' + REPO + '/master/data/' + self.data_key + path)
      return request.urlopen(REPO + '/master/data/' + self.data_key + path)

  def get_parties(self):
    with self.open_data('/party.json') as response:
      logging.info('Parsing response')
      for party in json.load(response):
        self.parties[party['id']] = Party(party['id'], party['name'])

  def load_answers(self, normalized):
    with self.open_data('/opinion.json') as response:
      logging.info('Parsing response')
      for opinion in json.load(response):
        if normalized:
          self.parties[opinion['party']].answer_normalized(opinion['statement'], opinion['answer'])
        else:
          self.parties[opinion['party']].answer(opinion['statement'], opinion['answer'])

  def create_nodes(self, dotfile):
    for party in self.parties.values():
      dotfile.write('  "' + party.name + '"')
      dotfile.write('[fillcolor="#ffffff",fontname=opensans,fontsize=11,')
      dotfile.write('height=0.5,margin=.04,shape=ellipse,style=filled];\n')

  def create_edges(self, dotfile):
    for party1 in self.parties.values():
      for party2 in self.parties.values():
        if party1.id >= party2.id:
          continue
        distance = float(party1.similar(party2)) / 8.0
        dotfile.write('  "' + party1.name + '" -- "' + party2.name + '"')
        dotfile.write('[arrowtype=none,color="#aaaaaa",len=' + str(distance) + '];\n')

  def render(self, neato: str, output: str):
    fd, dotfilepath = tempfile.mkstemp(suffix='.dot', text=True)
    logging.info('Writing graph to ' + dotfilepath)
    dotfile = os.fdopen(fd, "w")
    dotfile.write('graph {\n')
    dotfile.write('  graph [outputorder=edgesfirst,rankdir=LR];\n')
    dotfile.write('  node [label="\\N"];\n')
    self.create_nodes(dotfile)
    self.create_edges(dotfile)
    dotfile.write('}\n')
    dotfile.close()
    args = [neato, dotfilepath, '-Tpng', '-o', output]
    logging.info('Running ' + ' '.join(args))
    subprocess.run(args, check=True)
    os.remove(dotfilepath)

def main():
  parser = argparse.ArgumentParser(description='Visualize wahl-o-mat data.')
  parser.add_argument('-n', '--neatopath', dest='neato', type=str, default='neato',
                      help='Path to neato executable (default: "neato")')
  parser.add_argument('-o', '--output', dest='output', type=str, default='wahlomat.png',
                      help='Destination for generated visualization (default: "wahlomat.png")')
  parser.add_argument('-v', '--verbose', dest='verbose', default=False, action="store_true",
                       help="Increase output verbosity")
  parser.add_argument('--normalized', dest='normalized', default=False, action='store_true',
                      help='Treat answers as normalized values between 0.0 and 1.0.' +
                           'By default answers are expected to be one of positive (1), neutral(0) or negative(-1).')
  parser.add_argument('data', type=str,
                      help='Path to data in github.com/gockelhahn/qual-o-mat-data repository (e.g. 2019/europa).' +
                           'If "data" starts with ".", it will treates as relative local path, e.g. "./lilliput".')
  args = parser.parse_args()
  if args.verbose:
    logging.basicConfig(level=logging.INFO)

  renderer = Renderer(args.data)
  renderer.get_parties()
  renderer.load_answers(args.normalized)
  renderer.render(args.neato, args.output)
  logging.info('Done')

if __name__ == '__main__':
    main()
