fs = require 'fs'
path = require 'path'
_ = require 'lodash'
inspect = require('eyes').inspector
  maxLength: 99999


makeTree = (maxNodes) ->

  totalNodes = 0
  nodes = []
  firstRow = prevRow = [
    name: _.uniqueId()
    deps: []
  ]

  while totalNodes < maxNodes

    currentRow = []

    for mod in prevRow
      depsToAdd = Math.floor(Math.random() * 8) + 1
      for i in [0..depsToAdd]
        newMod =
          name: _.uniqueId()
          deps: []
        nodes.push newMod
        currentRow.push newMod
        mod.deps.push newMod
        totalNodes += 1

    prevRow = currentRow
  
  nodes


makeModule = (deps) ->
  contents = ''
  for dep in deps
    contents += "require('#{dep}');\n"
  contents


nodes = makeTree(10000)


