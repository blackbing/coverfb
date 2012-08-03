# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
$(window).load(->

  $('#main').height($(document).height())
  $('#coverImage').on('mousewheel DOMMouseScroll', (event)->
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
    $target = $('#coverImage')
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



  ).on('mouseup', (event)->
    $target = $('#coverImage')
    console.log('mosueup')
    $target
    .removeData('down')
    .removeData('downX')
    .removeData('downY')
  )




  $('#background-image').draggable()


)

