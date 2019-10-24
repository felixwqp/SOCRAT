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
heatMap = new (heatmap_1.HeatMap)(300, DENSITY, xDomain, xDomain, d3.select('#heatmap'), showAxes: true)
linkWidthScale = d3.scale.linear().domain([
  0
  5
]).range([
  1
  10
]).clamp(true)
colorScale = d3.scale.linear().domain([-1, 0, 1]).range(["#FF5733", "#33FF4F", "#337EFF"]).clamp(true);

iter = 0
trainData = []
testData = []
network = null
lossTrain = 0
lossTest = 0
player = new Player
# lineChart = new (linechart_1.AppendingLineChart)(d3.select('#linechart'), [
#   '#777'
#   'black'
# ])


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
      @dataPoints = data
      drawDatasetThumbnails data.dataPoints
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
    @heatMap = new heatmap_1.HeatMap(300, @DENSITY, @xDomain, @xDomain, d3.select("#heatmap"), {showAxes: true});
    @iter = 0
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




  # updateChartData: (data) =>

  #   generateData(@)
  #   return
  reset = (_this) =>
    _this.iter = 0
    # change dynamic in future.
    numInputs = 2
    shape = [2,4,2,1]
    outputActivation = nn.Activations.LINEAR 
    network = nn.buildNetwork(shape, )

