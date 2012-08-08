# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
require([
  'module'
  'view/main'
], (module, mainView)->


  new mainView( el: $('body'))

  ###
  checkStep = ()->
    if $('#background-image img').length
      $('.select-photo').hide()

    return false
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

  ###










  #$('#background-image').draggable()






  #checkStep()
)

