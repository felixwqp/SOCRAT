'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
nn = require 'scripts/analysis/tools/MyModule/playground/nn.js'
heatmap_1 = require 'scripts/analysis/tools/MyModule/playground/heatmap.js'
# state_1 = require 'scripts/analysis/tools/MyModule/playground/state.js'
dataset_1 = require 'scripts/analysis/tools/MyModule/playground/dataset.js'
linechart_1 = require 'scripts/analysis/tools/MyModule/playground/linechart.js'


colorScale = d3.scale.linear().domain([-1, 0, 1]).range(["#FF5733", "#33FF4F", "#337EFF"]).clamp(true);


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
        context.fillRect w * (d[0] + 3) / 12, h * (d[1] + 3) / 12, 4, 4 
      d3.select(canvas.parentNode).style 'display', null
      return

    d3.selectAll('.dataset').style 'display', 'none'
    
    canvas = document.querySelector('canvas[data-dataset=circle]')
    dataGenerator = 
    renderThumbnail canvas, data
    return




  updateChartData: (data) =>

    generateData(@)
    return

