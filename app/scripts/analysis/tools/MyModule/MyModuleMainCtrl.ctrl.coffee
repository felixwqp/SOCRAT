'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
nn = require 'scripts/analysis/tools/MyModule/playground/nn.js'
heatmap_1 = require 'scripts/analysis/tools/MyModule/playground/heatmap.js'
state_1 = require 'scripts/analysis/tools/MyModule/playground/state.js'
dataset_1 = require 'scripts/analysis/tools/MyModule/playground/dataset.js'
linechart_1 = require 'scripts/analysis/tools/MyModule/playground/linechart.js'




state = state_1.State.deserializeState()

console.log state


RECT_SIZE = 30
BIAS_SIZE = 5
NUM_SAMPLES_CLASSIFY = 500
NUM_SAMPLES_REGRESS = 1200
DENSITY = 100
HoverType = undefined
((HoverType) ->
  HoverType[HoverType['BIAS'] = 0] = 'BIAS'
  HoverType[HoverType['WEIGHT'] = 1] = 'WEIGHT'
  return
) HoverType or (HoverType = {})


colorScale = d3.scale.linear().domain([-1, 0, 1]).range(["#FF5733", "#33FF4F", "#337EFF"]).clamp(true);

INPUTS = 
  'x':
    f: (x, y) ->
      x
    label: 'X_1'
  'y':
    f: (x, y) ->
      y
    label: 'X_2'
  'xSquared':
    f: (x, y) ->
      x * x
    label: 'X_1^2'
  'ySquared':
    f: (x, y) ->
      y * y
    label: 'X_2^2'
  'xTimesY':
    f: (x, y) ->
      x * y
    label: 'X_1X_2'
  'sinX':
    f: (x, y) ->
      Math.sin x
    label: 'sin(X_1)'
  'sinY':
    f: (x, y) ->
      Math.sin y
    label: 'sin(X_2)'

HIDABLE_CONTROLS = [
  [
    'Show test data'
    'showTestData'
  ]
  [
    'Discretize output'
    'discretize'
  ]
  [
    'Play button'
    'playButton'
  ]
  [
    'Step button'
    'stepButton'
  ]
  [
    'Reset button'
    'resetButton'
  ]
  [
    'Learning rate'
    'learningRate'
  ]
  [
    'Activation'
    'activation'
  ]
  [
    'Regularization'
    'regularization'
  ]
  [
    'Regularization rate'
    'regularizationRate'
  ]
  [
    'Problem type'
    'problem'
  ]
  [
    'Which dataset'
    'dataset'
  ]
  [
    'Ratio train data'
    'percTrainData'
  ]
  [
    'Noise level'
    'noise'
  ]
  [
    'Batch size'
    'batchSize'
  ]
  [
    '# of hidden layers'
    'numHiddenLayers'
  ]
]
Player = do ->
  `var Player`

  ###* Plays/pauses the player. ###

  Player = ->
    @timerIndex = 0
    @isPlaying = false
    @callback = null
    return

  Player::playOrPause = ->
    if @isPlaying
      @isPlaying = false
      @pause()
    else
      @isPlaying = true
      if iter == 0
        simulationStarted()
      @play()
    return

  Player::onPlayPause = (callback) ->
    @callback = callback
    return

  Player::play = ->
    @pause()
    console.log 'Start Play'
    @isPlaying = true
    if @callback
      @callback @isPlaying
    @start @timerIndex
    return

  Player::pause = ->
    @timerIndex++
    @isPlaying = false
    if @callback
      @callback @isPlaying
    return

  Player::start = (localTimerIndex) ->
    _this = this
    d3.timer (->
      if localTimerIndex < _this.timerIndex
        return true
        # Done.
      oneStep()
      false
      # Not done.
    ), 0
    return

  Player

state.getHiddenProps().forEach (prop) ->
  if prop of INPUTS
    delete INPUTS[prop]
  return

boundary = {}
selectedNodeId = null
# Plot the heatmap.
xDomain = [
  -6
  6
]
linkWidthScale = d3.scale.linear().domain([
  0
  5
]).range([
  1
  10
]).clamp(true)
colorScale = d3.scale.linear().domain([-1, 0, 1]).range(["#FF5733", "#33FF4F", "#337EFF"]).clamp(true);

iter = 0
# trainData = []
# testData = []
network = null
lossTrain = 0
lossTest = 0
player = new Player


constructInputIds = ->
  result = []
  for inputName of INPUTS
    if state[inputName]
      result.push inputName
  result

constructInput = (x, y) ->
  input = []
  for inputName of INPUTS
    if state[inputName]
      input.push INPUTS[inputName].f(x, y)
  input










module.exports = class MymoduleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService', '$timeout', '$scope'

  initialize: ->
    @DENSITY = 100;
    @xDomain = [-6,6];

    @dataService = @socrat_analysis_mymodule_dataService
    @DATA_TYPES = @dataService.getDataTypes()
    @dataPoints = null
    @means = null
    @assignments = null
    @$scope.$on 'mymodule:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      console.log 'Main Update Data'
      console.log data
      @dataPoints = data['dataPoints']
      generateData(@)
      drawDatasetThumbnails data.dataPoints
      reset(false, @)
      # generateData(@)
      # @$timeout => @updateChartData(data)
    @$scope.$on 'mymodule:updateDataType', (event, dataType) =>
      @dataType = dataType
    console.log 'main control mymodule'
    console.log @dataPoints
    console.log @means
    console.log @assignments
    # console.log state_1
    # @state_temp = state_1.State
    # console.log @state_temp
    # @state = @state_temp.deserializeState()
    # console.log @state
    @trainData = []
    @testData = []
    temp_heatmap = d3.select("#heatmap")
    @heatMap = new heatmap_1.HeatMap(300, @DENSITY, @xDomain, @xDomain, temp_heatmap, {showAxes: true});
    @iter = 0
    temp_linechart = d3.select('#linechart')
    console.log temp_linechart
    @lineChart = new (linechart_1.AppendingLineChart)(temp_linechart, [
      '#777'
      'black'
    ])
    console.log @lineChart


    # @state = state_1.State.deserializeState()
    # console.log @state


  generateData = (_this) =>
    console.log MymoduleMainCtrl
    console.log _this
    # console.log _this.state
    # if firstTime == undefined
      # firstTime = false
    # if !firstTime
      # Change the seed.
      # console.log(_this.state)
      # @state.seed = Math.random().toFixed(5)
      # _this.state.serialize()
      # userHasInteracted()
    # Math.seedrandom _this.state.seed
    # numSamples = if state.problem == state_1.Problem.REGRESSION then NUM_SAMPLES_REGRESS else NUM_SAMPLES_CLASSIFY
    # generator = if state.problem == state_1.Problem.CLASSIFICATION then state.dataset else state.regDataset
    # data = generator(numSamples, state.noise / 100)
    # Shuffle the data in-place.
    data = _this.dataPoints
    dataset_1.shuffle data
    console.log data
    # Split into train and test data.
    splitIndex = Math.floor(data.length * 20 / 100)
    # console.log _this.state.percTrainData
    console.log splitIndex
    _this.trainData = data.slice(0, splitIndex)
    _this.testData = data.slice(splitIndex)
    _this.heatMap.updatePoints _this.trainData
    # console.log _this.state.showTestData
    _this.heatMap.updateTestPoints _this.testData
    console.log _this.trainData
    console.log _this.heatMap
    console.log _this.testData
    return


  
  drawDatasetThumbnails = (data) ->
    
    renderThumbnail = (canvas, data) ->
      w = 50
      h = 50
      canvas.setAttribute 'width', w
      canvas.setAttribute 'height', h
      context = canvas.getContext('2d')
      
      data.forEach (d) ->
        context.fillStyle = colorScale(d[2])
        context.fillRect w * (d[0] + 3) / 12, h * (d[1] + 3) / 12, 1.5, 1.5 
      d3.select(canvas.parentNode).style 'display', null
      return

    # d3.selectAll('.dataset').style 'display', 'none'
    d3.selectAll('.dataset')
    
    canvas = document.querySelector('canvas[data-dataset=circle]')
    dataGenerator = 
    renderThumbnail canvas, data
    return


makeGUI = ->
  d3.select('#reset-button').on 'click', ->
    reset()
    userHasInteracted()
    d3.select '#play-pause-button'
    return
  d3.select('#play-pause-button').on 'click', ->
    # Change the button's content.
    userHasInteracted()
    player.playOrPause()
    return
  player.onPlayPause (isPlaying) ->
    d3.select('#play-pause-button').classed 'playing', isPlaying
    return
  d3.select('#next-step-button').on 'click', ->
    player.pause()
    userHasInteracted()
    if iter == 0
      simulationStarted()
    oneStep()
    return
  d3.select('#data-regen-button').on 'click', ->
    generateData()
    parametersChanged = true
    return
  dataThumbnails = d3.selectAll('canvas[data-dataset]')
  dataThumbnails.on 'click', ->
    newDataset = state_1.datasets[@dataset.dataset]
    if newDataset == state.dataset
      return
      # No-op.
    state.dataset = newDataset
    dataThumbnails.classed 'selected', false
    d3.select(this).classed 'selected', true
    generateData()
    parametersChanged = true
    reset()
    return
  datasetKey = state_1.getKeyFromValue(state_1.datasets, state.dataset)
  # Select the dataset according to the current state.
  d3.select('canvas[data-dataset=' + datasetKey + ']').classed 'selected', true
  regDataThumbnails = d3.selectAll('canvas[data-regDataset]')
  regDataThumbnails.on 'click', ->
    newDataset = state_1.regDatasets[@dataset.regdataset]
    if newDataset == state.regDataset
      return
      # No-op.
    state.regDataset = newDataset
    regDataThumbnails.classed 'selected', false
    d3.select(this).classed 'selected', true
    generateData()
    parametersChanged = true
    reset()
    return
  regDatasetKey = state_1.getKeyFromValue(state_1.regDatasets, state.regDataset)
  # Select the dataset according to the current state.
  d3.select('canvas[data-regDataset=' + regDatasetKey + ']').classed 'selected', true
  d3.select('#add-layers').on 'click', ->
    if state.numHiddenLayers >= 6
      return
    state.networkShape[state.numHiddenLayers] = 2
    state.numHiddenLayers++
    parametersChanged = true
    reset()
    return
  d3.select('#remove-layers').on 'click', ->
    if state.numHiddenLayers <= 0
      return
    state.numHiddenLayers--
    state.networkShape.splice state.numHiddenLayers
    parametersChanged = true
    reset()
    return
  showTestData = d3.select('#show-test-data').on('change', ->
    state.showTestData = @checked
    state.serialize()
    userHasInteracted()
    heatMap.updateTestPoints if state.showTestData then testData else []
    return
  )
  # Check/uncheck the checkbox according to the current state.
  showTestData.property 'checked', state.showTestData
  discretize = d3.select('#discretize').on('change', ->
    state.discretize = @checked
    state.serialize()
    userHasInteracted()
    updateUI()
    return
  )
  # Check/uncheck the checbox according to the current state.
  discretize.property 'checked', state.discretize
  percTrain = d3.select('#percTrainData').on('input', ->
    state.percTrainData = @value
    d3.select('label[for=\'percTrainData\'] .value').text @value
    generateData()
    parametersChanged = true
    reset()
    return
  )
  percTrain.property 'value', state.percTrainData
  d3.select('label[for=\'percTrainData\'] .value').text state.percTrainData
  noise = d3.select('#noise').on('input', ->
    state.noise = @value
    d3.select('label[for=\'noise\'] .value').text @value
    generateData()
    parametersChanged = true
    reset()
    return
  )
  currentMax = parseInt(noise.property('max'))
  if state.noise > currentMax
    if state.noise <= 80
      noise.property 'max', state.noise
    else
      state.noise = 50
  else if state.noise < 0
    state.noise = 0
  noise.property 'value', state.noise
  d3.select('label[for=\'noise\'] .value').text state.noise
  batchSize = d3.select('#batchSize').on('input', ->
    state.batchSize = @value
    d3.select('label[for=\'batchSize\'] .value').text @value
    parametersChanged = true
    reset()
    return
  )
  batchSize.property 'value', state.batchSize
  d3.select('label[for=\'batchSize\'] .value').text state.batchSize
  activationDropdown = d3.select('#activations').on('change', ->
    state.activation = state_1.activations[@value]
    parametersChanged = true
    reset()
    return
  )
  activationDropdown.property 'value', state_1.getKeyFromValue(state_1.activations, state.activation)
  learningRate = d3.select('#learningRate').on('change', ->
    state.learningRate = +@value
    state.serialize()
    userHasInteracted()
    parametersChanged = true
    return
  )
  learningRate.property 'value', state.learningRate
  regularDropdown = d3.select('#regularizations').on('change', ->
    state.regularization = state_1.regularizations[@value]
    parametersChanged = true
    reset()
    return
  )
  regularDropdown.property 'value', state_1.getKeyFromValue(state_1.regularizations, state.regularization)
  regularRate = d3.select('#regularRate').on('change', ->
    state.regularizationRate = +@value
    parametersChanged = true
    reset()
    return
  )
  regularRate.property 'value', state.regularizationRate
  problem = d3.select('#problem').on('change', ->
    state.problem = state_1.problems[@value]
    generateData()
    drawDatasetThumbnails()
    parametersChanged = true
    reset()
    return
  )
  problem.property 'value', state_1.getKeyFromValue(state_1.problems, state.problem)
  # Add scale to the gradient color map.
  x = d3.scale.linear().domain([
    -1
    1
  ]).range([
    0
    144
  ])
  xAxis = d3.svg.axis().scale(x).orient('bottom').tickValues([
    -1
    0
    1
  ]).tickFormat(d3.format('d'))
  d3.select('#colormap g.core').append('g').attr('class', 'x axis').attr('transform', 'translate(0,10)').call xAxis
  # Listen for css-responsive changes and redraw the svg network.
  window.addEventListener 'resize', ->
    newWidth = document.querySelector('#main-part').getBoundingClientRect().width
    if newWidth != mainWidth
      mainWidth = newWidth
      drawNetwork network
      updateUI true
    return
  # Hide the text below the visualization depending on the URL.
  if state.hideText
    d3.select('#article-text').style 'display', 'none'
    d3.select('div.more').style 'display', 'none'
    d3.select('header').style 'display', 'none'
  return

updateBiasesUI = (network) ->
  nn.forEachNode network, true, (node) ->
    d3.select('rect#bias-' + node.id).style 'fill', colorScale(node.bias)
    return
  return

updateWeightsUI = (network, container) ->
  layerIdx = 1
  while layerIdx < network.length
    currentLayer = network[layerIdx]
    # Update all the nodes in this layer.
    i = 0
    while i < currentLayer.length
      node = currentLayer[i]
      j = 0
      while j < node.inputLinks.length
        link = node.inputLinks[j]
        container.select('#link' + link.source.id + '-' + link.dest.id).style(
          'stroke-dashoffset': -iter / 3
          'stroke-width': linkWidthScale(Math.abs(link.weight))
          'stroke': colorScale(link.weight)).datum link
        j++
      i++
    layerIdx++
  return

drawNode = (cx, cy, nodeId, isInput, container, node, _this) ->
  x = cx - (RECT_SIZE / 2)
  y = cy - (RECT_SIZE / 2)
  nodeGroup = container.append('g').attr(
    'class': 'node'
    'id': 'node' + nodeId
    'transform': 'translate(' + x + ',' + y + ')')
  # Draw the main rectangle.
  nodeGroup.append('rect').attr
    x: 0
    y: 0
    width: RECT_SIZE
    height: RECT_SIZE
  activeOrNotClass = if state[nodeId] then 'active' else 'inactive'
  if isInput
    label = if INPUTS[nodeId].label != null then INPUTS[nodeId].label else nodeId
    # Draw the input label.
    text = nodeGroup.append('text').attr(
      'class': 'main-label'
      x: -10
      y: RECT_SIZE / 2
      'text-anchor': 'end')
    if /[_^]/.test(label)
      myRe = /(.*?)([_^])(.)/g
      myArray = undefined
      lastIndex = undefined
      while (myArray = myRe.exec(label)) != null
        lastIndex = myRe.lastIndex
        prefix = myArray[1]
        sep = myArray[2]
        suffix = myArray[3]
        if prefix
          text.append('tspan').text prefix
        text.append('tspan').attr('baseline-shift', if sep == '_' then 'sub' else 'super').style('font-size', '9px').text suffix
      if label.substring(lastIndex)
        text.append('tspan').text label.substring(lastIndex)
    else
      text.append('tspan').text label
    nodeGroup.classed activeOrNotClass, true
  if !isInput
    # Draw the node's bias.
    nodeGroup.append('rect').attr(
      id: 'bias-' + nodeId
      x: -BIAS_SIZE - 2
      y: RECT_SIZE - BIAS_SIZE + 3
      width: BIAS_SIZE
      height: BIAS_SIZE).on('mouseenter', ->
      updateHoverCard HoverType.BIAS, node, d3.mouse(container.node())
      return
    ).on 'mouseleave', ->
      updateHoverCard null
      return
  # Draw the node's canvas.
  div = d3.select('#network').insert('div', ':first-child').attr(
    'id': 'canvas-' + nodeId
    'class': 'canvas').style(
    position: 'absolute'
    left: x + 3 + 'px'
    top: y + 3 + 'px').on('mouseenter', ->
    selectedNodeId = nodeId
    div.classed 'hovered', true
    nodeGroup.classed 'hovered', true
    updateDecisionBoundary network, false
    _this.heatMap.updateBackground boundary[nodeId], state.discretize
    return
  ).on('mouseleave', ->
    selectedNodeId = null
    div.classed 'hovered', false
    nodeGroup.classed 'hovered', false
    updateDecisionBoundary network, false
    _this.heatMap.updateBackground boundary[nn.getOutputNode(network).id], state.discretize
    return
  )
  if isInput
    div.on 'click', ->
      state[nodeId] = !state[nodeId]
      parametersChanged = true
      reset()
      return
    div.style 'cursor', 'pointer'
  if isInput
    div.classed activeOrNotClass, true
  nodeHeatMap = new (heatmap_1.HeatMap)(RECT_SIZE, DENSITY / 10, xDomain, xDomain, div, noSvg: true)
  div.datum
    heatmap: nodeHeatMap
    id: nodeId
  return

# Draw network

drawNetwork = (network, _this) ->
  `var i`
  `var link`
  svg = d3.select('#svg')
  # Remove all svg elements.
  svg.select('g.core').remove()
  # Remove all div elements.
  d3.select('#network').selectAll('div.canvas').remove()
  d3.select('#network').selectAll('div.plus-minus-neurons').remove()
  # Get the width of the svg container.
  padding = 3
  co = d3.select('.column.output').node()
  cf = d3.select('.column.features').node()
  width = co.offsetLeft - (cf.offsetLeft)
  svg.attr 'width', width
  # Map of all node coordinates.
  node2coord = {}
  container = svg.append('g').classed('core', true).attr('transform', 'translate(' + padding + ',' + padding + ')')
  # Draw the network layer by layer.
  numLayers = network.length
  featureWidth = 118
  layerScale = d3.scale.ordinal().domain(d3.range(1, numLayers - 1)).rangePoints([
    featureWidth
    width - RECT_SIZE
  ], 0.7)

  nodeIndexScale = (nodeIndex) ->
    nodeIndex * (RECT_SIZE + 25)

  calloutThumb = d3.select('.callout.thumbnail').style('display', 'none')
  calloutWeights = d3.select('.callout.weights').style('display', 'none')
  idWithCallout = null
  targetIdWithCallout = null
  # Draw the input layer separately.
  cx = RECT_SIZE / 2 + 50
  nodeIds = Object.keys(INPUTS)
  maxY = nodeIndexScale(nodeIds.length)
  nodeIds.forEach (nodeId, i) ->
    cy = nodeIndexScale(i) + RECT_SIZE / 2
    node2coord[nodeId] =
      cx: cx
      cy: cy
    drawNode cx, cy, nodeId, true, container, _this
    return
  # Draw the intermediate layers.
  layerIdx = 1
  while layerIdx < numLayers - 1
    numNodes = network[layerIdx].length
    cx_1 = layerScale(layerIdx) + RECT_SIZE / 2
    maxY = Math.max(maxY, nodeIndexScale(numNodes))
    addPlusMinusControl layerScale(layerIdx), layerIdx
    i = 0
    while i < numNodes
      node_1 = network[layerIdx][i]
      cy_1 = nodeIndexScale(i) + RECT_SIZE / 2
      node2coord[node_1.id] =
        cx: cx_1
        cy: cy_1
      drawNode cx_1, cy_1, node_1.id, false, container, node_1, _this
      # Show callout to thumbnails.
      numNodes_1 = network[layerIdx].length
      nextNumNodes = network[layerIdx + 1].length
      if idWithCallout == null and i == numNodes_1 - 1 and nextNumNodes <= numNodes_1
        calloutThumb.style
          display: null
          top: 20 + 3 + cy_1 + 'px'
          left: cx_1 + 'px'
        idWithCallout = node_1.id
      # Draw links.
      j = 0
      while j < node_1.inputLinks.length
        link = node_1.inputLinks[j]
        path = drawLink(link, node2coord, network, container, j == 0, j, node_1.inputLinks.length).node()
        # Show callout to weights.
        prevLayer = network[layerIdx - 1]
        lastNodePrevLayer = prevLayer[prevLayer.length - 1]
        if targetIdWithCallout == null and i == numNodes_1 - 1 and link.source.id == lastNodePrevLayer.id and (link.source.id != idWithCallout or numLayers <= 5) and link.dest.id != idWithCallout and prevLayer.length >= numNodes_1
          midPoint = path.getPointAtLength(path.getTotalLength() * 0.7)
          calloutWeights.style
            display: null
            top: midPoint.y + 5 + 'px'
            left: midPoint.x + 3 + 'px'
          targetIdWithCallout = link.dest.id
        j++
      i++
    layerIdx++
  # Draw the output node separately.
  cx = width + RECT_SIZE / 2
  node = network[numLayers - 1][0]
  cy = nodeIndexScale(0) + RECT_SIZE / 2
  node2coord[node.id] =
    cx: cx
    cy: cy
  # Draw links.
  i = 0
  while i < node.inputLinks.length
    link = node.inputLinks[i]
    drawLink link, node2coord, network, container, i == 0, i, node.inputLinks.length
    i++
  # Adjust the height of the svg.
  svg.attr 'height', maxY
  # Adjust the height of the features column.
  height = Math.max(getRelativeHeight(calloutThumb), getRelativeHeight(calloutWeights), getRelativeHeight(d3.select('#network')))
  d3.select('.column.features').style 'height', height + 'px'
  return

getRelativeHeight = (selection) ->
  node = selection.node()
  node.offsetHeight + node.offsetTop

addPlusMinusControl = (x, layerIdx) ->
  div = d3.select('#network').append('div').classed('plus-minus-neurons', true).style('left', x - 10 + 'px')
  i = layerIdx - 1
  firstRow = div.append('div').attr('class', 'ui-numNodes' + layerIdx)
  firstRow.append('button').attr('class', 'mdl-button mdl-js-button mdl-button--icon').on('click', ->
    numNeurons = state.networkShape[i]
    if numNeurons >= 8
      return
    state.networkShape[i]++
    parametersChanged = true
    reset()
    return
  ).append('i').attr('class', 'material-icons').text 'add'
  firstRow.append('button').attr('class', 'mdl-button mdl-js-button mdl-button--icon').on('click', ->
    numNeurons = state.networkShape[i]
    if numNeurons <= 1
      return
    state.networkShape[i]--
    parametersChanged = true
    reset()
    return
  ).append('i').attr('class', 'material-icons').text 'remove'
  suffix = if state.networkShape[i] > 1 then 's' else ''
  div.append('div').text state.networkShape[i] + ' neuron' + suffix
  return

updateHoverCard = (type, nodeOrLink, coordinates) ->
  hovercard = d3.select('#hovercard')
  if type == null
    hovercard.style 'display', 'none'
    d3.select('#svg').on 'click', null
    return
  d3.select('#svg').on 'click', ->
    hovercard.select('.value').style 'display', 'none'
    input = hovercard.select('input')
    input.style 'display', null
    input.on 'input', ->
      if @value != null and @value != ''
        if type == HoverType.WEIGHT
          nodeOrLink.weight = +@value
        else
          nodeOrLink.bias = +@value
        updateUI()
      return
    input.on 'keypress', ->
      if d3.event.keyCode == 13
        updateHoverCard type, nodeOrLink, coordinates
      return
    input.node().focus()
    return
  value = if type == HoverType.WEIGHT then nodeOrLink.weight else nodeOrLink.bias
  name = if type == HoverType.WEIGHT then 'Weight' else 'Bias'
  hovercard.style
    'left': coordinates[0] + 20 + 'px'
    'top': coordinates[1] + 'px'
    'display': 'block'
  hovercard.select('.type').text name
  hovercard.select('.value').style('display', null).text value.toPrecision(2)
  hovercard.select('input').property('value', value.toPrecision(2)).style 'display', 'none'
  return

drawLink = (input, node2coord, network, container, isFirst, index, length) ->
  line = container.insert('path', ':first-child')
  source = node2coord[input.source.id]
  dest = node2coord[input.dest.id]
  datum = 
    source:
      y: source.cx + RECT_SIZE / 2 + 2
      x: source.cy
    target:
      y: dest.cx - (RECT_SIZE / 2)
      x: dest.cy + (index - ((length - 1) / 2)) / length * 12
  diagonal = d3.svg.diagonal().projection((d) ->
    [
      d.y
      d.x
    ]
  )
  line.attr
    'marker-start': 'url(#markerArrow)'
    'class': 'link'
    id: 'link' + input.source.id + '-' + input.dest.id
    d: diagonal(datum, 0)
  # Add an invisible thick link that will be used for
  # showing the weight value on hover.
  container.append('path').attr('d', diagonal(datum, 0)).attr('class', 'link-hover').on('mouseenter', ->
    updateHoverCard HoverType.WEIGHT, input, d3.mouse(this)
    return
  ).on 'mouseleave', ->
    updateHoverCard null
    return
  line

###*
# Given a neural network, it asks the network for the output (prediction)
# of every node in the network using inputs sampled on a square grid.
# It returns a map where each key is the node ID and the value is a square
# matrix of the outputs of the network for each input in the grid respectively.
###

updateDecisionBoundary = (network, firstTime) ->
  `var nodeId`
  `var nodeId`
  if firstTime
    boundary = {}
    nn.forEachNode network, true, (node) ->
      boundary[node.id] = new Array(DENSITY)
      return
    # Go through all predefined inputs.
    for nodeId of INPUTS
      boundary[nodeId] = new Array(DENSITY)
  xScale = d3.scale.linear().domain([
    0
    DENSITY - 1
  ]).range(xDomain)
  yScale = d3.scale.linear().domain([
    DENSITY - 1
    0
  ]).range(xDomain)
  i = 0
  j = 0
  i = 0
  while i < DENSITY
    if firstTime
      nn.forEachNode network, true, (node) ->
        boundary[node.id][i] = new Array(DENSITY)
        return
      # Go through all predefined inputs.
      for nodeId of INPUTS
        boundary[nodeId][i] = new Array(DENSITY)
    j = 0
    while j < DENSITY
      # 1 for points inside the circle, and 0 for points outside the circle.
      x = xScale(i)
      y = yScale(j)
      input = constructInput(x, y)
      nn.forwardProp network, input
      nn.forEachNode network, true, (node) ->
        boundary[node.id][i][j] = node.output
        return
      if firstTime
        # Go through all predefined inputs.
        for nodeId of INPUTS
          boundary[nodeId][i][j] = INPUTS[nodeId].f(x, y)
      j++
    i++
  return

getLoss = (network, dataPoints) ->
  loss = 0
  i = 0
  while i < dataPoints.length
    dataPoint = dataPoints[i]
    input = constructInput(dataPoint[0], dataPoint[1])
    output = nn.forwardProp(network, input)
    loss += nn.Errors.SQUARE.error(output, dataPoint[2])
    i++
  loss / dataPoints.length

updateUI = (firstStep, _this) ->

  zeroPad = (n) ->
    pad = '000000'
    (pad + n).slice -pad.length

  addCommas = (s) ->
    s.replace /\B(?=(\d{3})+(?!\d))/g, ','

  humanReadable = (n) ->
    n.toFixed 3

  if firstStep == undefined
    firstStep = false
  # Update the links visually.
  updateWeightsUI network, d3.select('g.core')
  # Update the bias values visually.
  updateBiasesUI network
  # Get the decision boundary of the network.
  updateDecisionBoundary network, firstStep
  selectedId = if selectedNodeId != null then selectedNodeId else nn.getOutputNode(network).id
  _this.heatMap.updateBackground boundary[selectedId], state.discretize
  # Update all decision boundaries.
  d3.select('#network').selectAll('div.canvas').each (data) ->
    data.heatmap.updateBackground heatmap_1.reduceMatrix(boundary[data.id], 10), state.discretize
    return
  # Update loss and iteration number.
  d3.select('#loss-train').text humanReadable(lossTrain)
  d3.select('#loss-test').text humanReadable(lossTest)
  d3.select('#iter-number').text addCommas(zeroPad(iter))
  _this.lineChart.addDataPoint [
    lossTrain
    lossTest
  ]
  return

oneStep = ->
  iter++
  trainData.forEach (point, i) ->
    input = constructInput(point.x, point.y)
    nn.forwardProp network, input
    nn.backProp network, point.label, nn.Errors.SQUARE
    if (i + 1) % state.batchSize == 0
      nn.updateWeights network, state.learningRate, state.regularizationRate
    return
  # Compute the loss.
  lossTrain = getLoss(network, trainData)
  lossTest = getLoss(network, testData)
  updateUI()
  return

getOutputWeights = (network) ->
  weights = []
  layerIdx = 0
  while layerIdx < network.length - 1
    currentLayer = network[layerIdx]
    i = 0
    while i < currentLayer.length
      node = currentLayer[i]
      j = 0
      while j < node.outputs.length
        output = node.outputs[j]
        weights.push output.weight
        j++
      i++
    layerIdx++
  weights




  # updateChartData: (data) =>

  #   generateData(@)
  #   return
  # makeGUI = ->
  

reset = (onStartup, _this) ->
  if onStartup == undefined
    onStartup = false
  console.log _this.lineChart
  _this.lineChart.reset()
  # if !onStartup
  #   userHasInteracted()
  player.pause()
  suffix = if state.numHiddenLayers != 1 then 's' else ''
  d3.select('#layers-label').text 'Hidden layer' + suffix
  d3.select('#num-layers').text state.numHiddenLayers
  # Make a simple network.
  iter = 0
  numInputs = constructInput(0, 0).length
  shape = [ numInputs ].concat(state.networkShape).concat([ 1 ])
  outputActivation = if state.problem == state_1.Problem.REGRESSION then nn.Activations.LINEAR else nn.Activations.TANH
  console.log shape
  console.log state.activation 
  console.log outputActivation 
  console.log state.regularization 
  console.log constructInputIds()
  console.log state.initZero
  network = nn.buildNetwork(shape, state.activation, outputActivation, state.regularization, constructInputIds(), state.initZero)
  console.log network
  lossTrain = getLoss(network, _this.trainData)
  lossTest = getLoss(network, _this.testData)
  drawNetwork network, _this
  updateUI true, _this
  return