# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
$(window).load(->

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
    console.log('mousedown')
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
      $('#background-image').css(
        left: if deltaX>0 then '+='+deltaX else '-='+(-deltaX)
        top: if deltaY>0 then '+='+deltaY else '-='+(-deltaY)
      )
      $target
      .data('downX', currentX)
      .data('downY', currentY)



      return false
  ).on('mouseup', (event)->
    $target = $('#cover_image')
    console.log('mosueup')
    $target
    .removeData('down')
    .removeData('downX')
    .removeData('downY')
  )

  $('#uploadBtn').on('change', (event)->

    $target = event.target
    console.log($target.files)
    file = $target.files[0]
    if file?
      URL = window.URL or window.webkitURL
      localUrl = URL.createObjectURL(file)
      console.log localUrl
      $('#background-image img').attr('src', localUrl)



  )



  $('#background-image').draggable()



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

    $('#main').height($(document).height())

  ).trigger('resize')
)

