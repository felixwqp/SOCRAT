'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
Playground = require 'scripts/analysis/tools/MyModule/playground/state.js'



module.exports = class MymoduleSidebarCtrl extends BaseCtrl
  @inject 'socrat_analysis_mymodule_dataService',
    'socrat_analysis_mymodule_msgService'
    '$scope'
    '$timeout'

  initialize: ->
    @dataService = @socrat_analysis_mymodule_dataService
    @msgService = @socrat_analysis_mymodule_msgService
    @DATA_TYPES = @dataService.getDataTypes()
    console.log 'init my side bar'
    # set up data and algorithm-agnostic controls
#     @useLabels = off
#     @reportAccuracy = on
#     @clusterRunning = off
    @ready = off
#     @running = 'hidden'
#     @uniqueLabels =
#       labelCol: null
#       num: null
#     @algParams = null
#     # TODO: allow user control of delay
#     @iterDelay = 750
    
    console.log Playground.activations
#     # dataset-specific
    @dataFrame = null
    @dataType = null
#     @cols = []
    @chosenCols = []
    @numericalCols = []
    @categoricalCols = []
    @xCol = null
    @yCol = null
    @labelCol = null
    @readylabelCol = null
    @predictLabel = null
    @distinctLabels = [] 

#     # choose first algorithm as default one
#     if @algorithms.length > 0
#       @selectedAlgorithm = @algorithms[0]
#       @updateAlgControls()

    @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
          # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          @msgService.broadcast 'mymodule:updateDataType', obj.dataFrame.dataType  
          # there should be @scope.on the handele this message; 
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        console.log @dataFrame
        console.log 'in my get data'
        console.log @numericalCols
    
        @parseData obj.dataFrame
        
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'

    @$timeout -> $('input[type=checkbox]').bootstrapSwitch()

#   updateAlgControls: () ->
#     @algParams = @algorithmsService.getParamsByName @selectedAlgorithm

  updateDataPoints: (data=null) ->
    if data
      trueLabels = null
      if @labelCol
        trueLabels = (row[data.header.indexOf(@labelCol)] for row in data.data)
        console.log @readylabelCol
        @readylabelCol = true
        console.log @distinctLabels
        @distinctLabels = Array.from(new Set(label for label in trueLabels))
        @distinctLabels.sort()
        console.log @distinctLabels
      
      xCol = data.header.indexOf @xCol unless !@xCol?
      yCol = data.header.indexOf @yCol unless !@yCol?
    #   console.log 'update internal'
    #   console.log xCol
    #   console.log yCol
    #   console.log dataFeatures
    # console.log 'update data points'
    # console.log data
    # console.log xCol
    # console.log yCol
    # console.log @ready
    if @xCol and @yCol and @labelCol and @predictLabel
      console.log 'READY!!!'
      console.log trueLabels
      # dataFeatures = ([row[xCol], row[yCol]] for row in data.data) unless @chosenCols.length < 2
      # trueLabels = [(if label > @predictLabel then 1 else (if label == @predictLabel then 0 else -1) ) for label in trueLabels]
      trueLabels = [ Math.ceil( @distinctLabels.indexOf(label) - @distinctLabels.length / 2  ) for label in trueLabels] 
      dataFeatures = []
      console.log data.data
      console.log trueLabels
      for i in [0..data.data.length-1] 
        console.log 'round'
        console.log data.data[i][xCol]
        console.log data.data[i][yCol] 
        console.log trueLabels[0][i]
        dataFeatures.push([ parseFloat(data.data[i][xCol]), parseFloat(data.data[i][yCol]), trueLabels[0][i] ])
      
      console.log dataFeatures
      
      @msgService.broadcast 'mymodule:updateDataPoints',
        dataPoints: dataFeatures

  # update data-driven sidebar controls
  updateSidebarControls: (data) ->
    @cols = data.header
    @numericalCols = (col for col, idx in @cols when data.types[idx] in ['integer', 'number'])
    @categoricalCols = (col for col, idx in @cols when data.types[idx] in ['string', 'integer'])
    # make sure number of unique labels is less than maximum number of clusters for visualization
    # @clusterRunning = off
    # if @labelCol
    #   @uniqueLabels =
    #     num: @uniqueVals (data.header.indexOf(@labelCol) for row in data.data)
    #     labelCol: @labelCol
    console.log 'update sidebar control'
    console.log @cols
    console.log @numericalCols
    console.log @categoricalCols
    @$timeout =>
      @updateDataPoints data

  updateChosenCols: () ->
    console.log 'update Chosen Cols triggered'
    console.log @chosenCols
    console.log @numericalCols
    axis = [@xCol, @yCol]
    presentCols = ([name, idx] for name, idx in @chosenCols when name in axis)
    # if current X and Y are not among selected anymore
    switch presentCols.length
      when 0
        @xCol = if @chosenCols.length > 0 then @chosenCols[0] else null
        @yCol = if @chosenCols.length > 1 then @chosenCols[1] else null
      when 1
        upd = if @chosenCols.length > 1 then @chosenCols.find (e, i) -> i isnt presentCols[0][1] else null
        [@xCol, @yCol] = axis.map (c) -> if c isnt presentCols[0][0] then upd else c
    console.log 'check in chosen cols'
    console.log @labelCol
    console.log @xCol
    console.log @yCol

    if @labelCol and @xCol and @yCol
      @ready = on
       
    @updateDataPoints @dataFrame

  updateLabelCol: () ->
    console.log 'update Label Col triggered'
    console.log @categoricalCols
    console.log 'check in label col'
    console.log @labelCol
    console.log @xCol
    console.log @yCol
    
    @updateDataPoints @dataFrame
  
  
  updateSelectLabel: () ->



#   uniqueVals: (arr) -> arr.filter (x, i, a) -> i is a.indexOf x

#   detectK: () ->
#     detectedK = @detectKValue()
#     @setDetectedKValue detectedK

#   setDetectedKValue: (detectedK) ->
#     if detectedK.num <= 10
#       @uniqueLabels = detectedK
#       @k = detectedK.num
#       # TODO: add success messages
#     else
#       # TODO: create popup with warning message
#       console.log 'KMEANS: k is more than 10'

#   detectKValue: () ->
#     # extra check that labels are on
#     if @dataFrame and @labelCol
#       labelCol = @dataFrame.header.indexOf @labelCol
#       labels = (row[labelCol] for row in @dataFrame.data)
#       uniqueLabels = @uniqueVals labels
#       uniqueLabels =
#         labelCol: @labelCol
#         num: uniqueLabels.length

#   ## Data preparation methods

#   # get requested columns from data
#   prepareData: () ->
#     data = @dataFrame

#     if @chosenCols.length > 1

#       # get indices of feats to visualize in array of chosen
#       xCol = @chosenCols.indexOf @xCol
#       yCol = @chosenCols.indexOf @yCol
#       chosenIdxs = @chosenCols.map (x) -> data.header.indexOf x

#       # if usage of labels is on
#       if @labelCol
#         labelColIdx = data.header.indexOf @labelCol
#         labels = (row[labelColIdx] for row in data.data)
#       else
#         labels = null

#       data = (row.filter((el, idx) -> idx in chosenIdxs) for row in data.data)

#       # re-check if possible to compute accuracy
#       if @k is @uniqueLabels.num and @accuracyon
#         acc = on

#       obj =
#         data: data
#         labels: labels
#         xCol: xCol
#         yCol: yCol
#         acc: acc

#     else false

  parseData: (data) ->
    @dataService.inferDataTypes data, (resp) =>
      if resp? and resp.dataFrame? and resp.dataFrame.data?
        df = @dataFrame
        # update data types with inferred
        for type, idx in df.types
         df.types[idx] = resp.dataFrame.data[idx]
        @updateSidebarControls(df)
        @updateDataPoints(df)
        # @ready = on

#   ## Interface method to run clustering

#   runClustering: ->
#     clustData = @prepareData()
#     @kmeanson = on
#     @running = 'spinning'
#     res = @algorithmsService.cluster @selectedAlgorithm, clustData, @k, @initMethod, @distance, @iterDelay, (res) =>
#       xyMeans = ([row.val[clustData.xCol], row.val[clustData.yCol]] for row in res.centroids)
#       @updateDataPoints null, xyMeans, res.labels
#       @$timeout =>
#         @kmeanson = off
#         @running = 'hidden'

#   stepClustering: ->
#     clustData = @prepareData()
#     @kmeanson = on
#     @running = 'spinning'
#     res = @algorithmsService.clusterStep @selectedAlgorithm, clustData, @k, @initMethod, @distance
#     xyMeans = ([row.val[clustData.xCol], row.val[clustData.yCol]] for row in res.centroids)
#     @updateDataPoints null, xyMeans, res.labels
#     @$timeout =>
#       @kmeanson = off
#       @running = 'hidden'

#   reset: ->
#     @algorithmsService.reset @selectedAlgorithm
#     @updateDataPoints(@dataFrame, null, null)
