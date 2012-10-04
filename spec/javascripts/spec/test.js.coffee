define (require, exports, module)->
  cropTool = require 'lib/crop'

  describe module.id, ->
    describe "htc-crop test1", ->
      it 'compress rate sould < 1', ->
        expect cropTool.compress<1

    describe "htc-crop test2", ->
      it 'compress rate sould < 1', ->
        expect cropTool.compress<1

    describe "htc-crop test3", ->
      it 'compress rate sould < 1', ->
        expect cropTool.compress<1
