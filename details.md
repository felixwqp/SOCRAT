1. jQuery post()


2. AugularJS, this.$q.defer()

```js
@dataService.getData().then (obj) =>
      console.log 'Cluster side bar get data'
      if obj.dataFrame and obj.dataFrame.dataType? and obj.dataFrame.dataType is @DATA_TYPES.FLAT
        if @dataType isnt obj.dataFrame.dataType
          # update local data type
          @dataType = obj.dataFrame.dataType
          # send update to main are actrl
          console.log "TYPE!!!!"
          console.log obj.dataFrame.dataType
          @msgService.broadcast 'cluster:updateDataType', obj.dataFrame.dataType
          // 什么玩意
        
        # make local copy of data
        @dataFrame = obj.dataFrame
        # parse dataFrame
        @parseData obj.dataFrame
        console.log 'CLUSTWER'
        console.log obj
      else
        # TODO: add processing for nested object
        console.log 'NESTED DATASET'
```
