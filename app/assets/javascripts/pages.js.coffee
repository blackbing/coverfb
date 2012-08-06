# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
require([
  'module'
  'lib/crop'
], (module, CropTool)->

  checkStep = ()->
    step = 0
    if $('#cover_image img').length
      step = 3
      $('#profile_pic_education a').tooltip(
        title: 'Congratulations! Just click it to download your profile image'
        placement: 'bottom'
      ).tooltip('show')
      $('#cover_image a').tooltip(
        title: 'Congratulations! Just click it to download your cover image'
        placement: 'bottom'
      ).tooltip('show')
    else if $('#profile_pic_education img').length
      $('#cropBtnCover').addClass('step').show().tooltip(
        title: '3. Drag and wheel photo then click to capture cover image'
        placement: 'right'
      ).tooltip('show')
      step = 2
    else if $('#background-image img').length
      $('.select-photo').fadeOut()
      $('#cropBtnProfile').addClass('step').show().tooltip(
        title: '2. Drag and wheel photo then click to capture profile image'
        placement: 'right'
      ).tooltip('show')

      step = 1

    if not step
      $('.select-photo').fadeIn().tooltip(
        title: '1. click to choose a photo'
        placement: 'bottom'
      ).tooltip('show')





  $('#cover_image').on('mousewheel DOMMouseScroll', (event)->
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
  ).on('mousedown', (event)->
    $target = $(event.target)
    $target
    .data('down', true)
    .data('downX', event.clientX)
    .data('downY', event.clientY)


  )

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

  $('#select_photo').on('click', ()->
    $('#uploadBtn').trigger('click')
  )

  $('#uploadBtn').on('change', (event)->

    $target = event.target
    file = $target.files[0]
    if file?
      URL = window.URL or window.webkitURL
      localUrl = URL.createObjectURL(file)
      $('#background-image img').remove()
      $('<img>').load(->
        #URL.revokeObjectURL(localUrl)
      ).attr('src', localUrl)
      .appendTo('#background-image')

    checkStep()


  )



  $('#background-image').draggable()

  cropIt = (coverSize, offsetDelta, name)->
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


  $('#cropBtnProfile').on('click', ()->
    $('#camera')[0].play()
    coverSize =
      w: 180
      h: 180
    delta =
      x: parseInt( $('#profile_pic_education').css('left'), 10)
      y: parseInt( $('#profile_pic_education').css('top'), 10)
    $coverElement = cropIt(coverSize, delta, 'profile')

    $coverElement.appendTo('#profile_pic_education')
    checkStep()
  )

  $('#cropBtnCover').on('click', ()->
    $('#camera')[0].play()
    coverSize =
      w: 851
      h: 315
    delta =
      x: parseInt($('#cover_image').css('left'), 10)
      y: parseInt($('#cover_image').css('top'), 10)
    $coverElement = cropIt(coverSize, delta, 'cover')

    $coverElement.appendTo('#cover_image')
    $coverElement.find('img').load(->
      checkStep()
    )
  )



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

  checkStep()
)

