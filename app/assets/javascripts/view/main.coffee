define [
  'module'
  'lib/crop'
], (module, CropTool)->

  mainView = Backbone.View.extend(
    initialize: ->

      mainWidth = 1263
      $(window).resize(->
        winW = $(window).width()
        winH = $(window).height()
        sideW = (winW - mainWidth)/2
        $('.leftSide').add('.rightSide').width(sideW)

        if not $('#profile_pic_education').data('o_left')
          o_left = parseInt($('#profile_pic_education').css('left'), 10)
          $('#profile_pic_education').data('o_left', o_left)
        else
          o_left = $('#profile_pic_education').data('o_left')
        $('#profile_pic_education').css('left', o_left+sideW)

        if not $('#cover_image').data('o_left')
          o_left = parseInt($('#cover_image').css('left'), 10)
          $('#cover_image').data('o_left', o_left)
        else
          o_left = $('#cover_image').data('o_left')
        $('#cover_image').css('left', o_left+sideW)

        $('#main').height($(document).height())

      ).trigger('resize')

      $('body').on('mousemove', (event)->
        $target = $('#cover_image')
        isMouseDown = $target.data('down')
        if(isMouseDown)



          currentX = event.clientX
          currentY = event.clientY
          deltaX = currentX - $target.data('downX')
          deltaY = currentY - $target.data('downY')

          bgOffset = $('#background-image').offset()
          coverOffset = $('#cover_image').offset()
          limitBound =
            minX: (coverOffset.left) - ($('#background-image').width() - $('#cover_image').width())
            maxX: coverOffset.left
            minY: (coverOffset.top) - ($('#background-image').height() - $('#cover_image').height())
            maxY: coverOffset.top


          outBoundX = false
          outBoundY = false
          paddingX = -4
          paddingY = 0
          if (bgOffset.left + deltaX + paddingX - limitBound.minX)*(bgOffset.left + deltaX + paddingX- limitBound.maxX) >= 0
            outBoundX = true
          if (bgOffset.top + deltaY + paddingY - limitBound.minY)*(bgOffset.top + deltaY + paddingY - limitBound.maxY) >= 0
            outBoundY = true

          #FIXME: revise outBound
          outBoundX = false
          outBoundY = false

          if not outBoundX
            $('#background-image').css(
              left: if deltaX>0 then '+='+deltaX else '-='+(-deltaX)
            )
            $target.data('downX', currentX)
          if not outBoundY
            $('#background-image').css(
              top: if deltaY>0 then '+='+deltaY else '-='+(-deltaY)
            )
            $target.data('downY', currentY)

          return false
      ).on('mouseup', (event)->
        $target = $('#cover_image')
        $target
        .removeData('down')
        .removeData('downX')
        .removeData('downY')
      )

      $( "#slider-vertical" ).slider(
        orientation: "vertical"
        range: "min"
        min: 0
        max: 100
        value: 0
        slide: @slideHandler
      )

    events:
      'click .controller-group .icon-remove': 'removeImage'
      'mousewheel #cover_image': 'wheelHandler'
      'DOMMouseScroll #cover_image': 'wheelHandler'
      'mousedown': 'downCover'
      'click i.icon-upload,#select_photo': 'selectPhoto'
      'change #uploadBtn': 'changeUploadBtn'
      'click #cropBtnProfile': 'cropBtnProfile'
      'click #cropBtnCover': 'cropBtnCover'

    cropBtnCover: ()->
      $('#camera')[0].play()
      coverSize =
        w: 851
        h: 315
      delta =
        x: parseInt($('#cover_image').css('left'), 10)
        y: parseInt($('#cover_image').css('top'), 10)
      $coverElement = @cropIt(coverSize, delta, 'cover')

      $coverElement.appendTo('#cover_image')
      $coverElement.find('img').load(->
        #checkStep()
      )

    cropBtnProfile: ()->
      $('#camera')[0].play()
      coverSize =
        w: 180
        h: 180
      delta =
        x: parseInt( $('#profile_pic_education').css('left'), 10)
        y: parseInt( $('#profile_pic_education').css('top'), 10)
      $coverElement = @cropIt(coverSize, delta, 'profile')

      $coverElement.appendTo('#profile_pic_education')


    selectPhoto: (event)->
      if $(event.target).closest('#profile_pic_education').length
        $('#background-image').css(
          left: $('#profile_pic_education').css('left')
          top: $('#profile_pic_education').css('top')
          width: $('#profile_pic_education').width()
        )

      else
        $('#background-image').css(
          left: $('#cover_image').css('left')
          top: $('#cover_image').css('top')
          width: $('#cover_image').width()
        )

      $('#uploadBtn').trigger('click')

    changeUploadBtn: (event)->

      $target = event.target

      file = $target.files[0]
      if file?
        URL = window.URL or window.webkitURL
        localUrl = URL.createObjectURL(file)
        $('#background-image img').remove()
        $('<img>').load(->
          #URL.revokeObjectURL(localUrl)
          if($(@).prop('naturalWidth') < $('#cover_image').width())
            alert('This photo width lower then 815, plase change a better one.')
          else
            $(@).appendTo('#background-image')
            $('.select-photo').hide()


            ###
            naturalWidth = $(@).prop('naturalWidth')
            minWidth = $('#cover_image').width()
            sliderValue = Math.round(minWidth/naturalWidth * 100)
            $('#slider-vertical').slider( "option", "value", sliderValue)
            ###

        ).attr('src', localUrl)




    downCover: (event)->
      $target = $(event.target)
      $target
      .data('down', true)
      .data('downX', event.clientX)
      .data('downY', event.clientY)

    slideHandler: (event, ui)->

      naturalWidth = $('#background-image img').prop('naturalWidth')
      minWidth = $('#cover_image').width()

      w = (naturalWidth - minWidth) * ui.value/100
      $('#background-image').css(
        'width': minWidth + w
      )

    wheelHandler: (event)->
      originalEvent = event.originalEvent
      wheelDelta = originalEvent.wheelDelta
      wheelDeltaX = originalEvent.wheelDeltaX
      wheelDeltaY = originalEvent.wheelDeltaY

      if wheelDeltaY > 0
        $('#background-image').css(
          width:'+=5'
        )
      else
        $('#background-image').css(
          width:'-=5'
        )

      return false


    removeImage: (event)->
      $target = $(event.target)
      $imgLink = $target.closest('.controller-group').parent().find('a[download]')
      if $imgLink.length
        $imgLink.remove()

    cropIt: (coverSize, offsetDelta, name)->
      ###
      ###
      offset =
        left: parseInt($("#background-image").css("left"), 10)
        top: parseInt($("#background-image").css("top"), 10)
      cropInfo =
        x: -(offset.left) + offsetDelta.x
        y: -(offset.top) + offsetDelta.y
        w: coverSize.w
        h: coverSize.h

      canvas = CropTool.crop($("#background-image img"), cropInfo)
      resized = CropTool.resizeCanvas(canvas,
        maxWidth: coverSize.w
        maxHeight: coverSize.h
      )
      dataURL = CropTool.getDataURL(resized)
      blobURL = CropTool.getBlobURL(dataURL)

      $('<a/>', {
        href: blobURL
        download: "#{name}.jpg"
      }).append('<img src="'+blobURL+'" >')


  )
  mainView
