'use strict'

#import * as tf from '@tensorflow/tfjs';


BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'socrat_analysis_myModule_dataService', '$timeout', '$scope'

  initialize: ->
    @dataService = @socrat_analysis_myModule_dataService
    @DATA_TYPES = @dataService.getDataTypes()

    @title = 'myModule module'
    @dataType = ''
    @transforming = off
    @transformation = ''
    @transformations = []
    @affinityMatrix = null

    @showresults = off
    @avgAccuracy = ''
    @accs = {}

    @dataPoints = null
    @means = null
    @assignments = null


    @receivedData = ""


    @linearModel = tf.Sequential
    @prediction = null

    @$scope.$on 'myModule:updateDataPoints', (event, data) =>
#      @showresults = off if @showresults is on
      # safe enforce $scope.$digest to activate directive watchers
      @$timeout => @updateChartData(data)

    @$scope.$on 'myModule:updateDataType', (event, dataType) =>
      @dataType = dataType
      
    @$scope.$on 'myModule:updateData', (event, receivedData) =>
      console.log(receivedData)
      @receivedData = receivedData


  train: () ->




  prettifyArrayOutput: (arr) ->
    if arr?
      arr = arr.map (x) -> x.toFixed 3
      '[' + arr.toString().split(',').join('; ') + ']'

  showResults: (accuracy) ->
    if Object.keys(accuracy).length isnt 0
      @avgAccuracy = accuracy.average.toFixed(2)
      delete accuracy.average
      @accs = accuracy
      @showresults = on

  updateChartData: (data) ->
    if data.dataPoints?
      if data.trueLabels?
        @dataPoints = data.dataPoints.map((row, i) ->
          row.push(data.trueLabels[i])
          return row
        )
      else
        @dataPoints = data.dataPoints
    @means = data.means
    @assignments = data.labels

  finish: (results=null) ->
    @msgManager.broadcast 'myModule:done', results
    showResults results
