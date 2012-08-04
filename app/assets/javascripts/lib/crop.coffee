define [
  'module'
], (module, log)->

  toDigits = (num, n)->
    n10 = Math.pow(10, n)
    Math.round(num * n10)/n10



  cropTool =
    filterBase64Reg: /data:([^;]*)(;base64)?,([0-9A-Za-z+/]+)/
    acceptFileTypes : [
      'jpeg'
      'jpg'
      'png'
    ]
    acceptFileSize:
      min: 1024 #1K
      max: 1024*1024*10 #10M
    portraitThumb:
      width: 430
      height: 765
    landscapeThumb:
      width: 765
      height: 430

    mimeType: 'image/jpeg'
    compress: '0.8'
    getCanvas: (w, h)->
      canvas = document.createElement('canvas')
      canvas.width = w
      canvas.height = h
      canvas


    getBlobURL: do()->
      ##use do for checking once
      BlobBuilder = window.BlobBuilder or window.MozBlobBuilder or window.WebKitBlobBuilder or window.MSBlobBuilder
      #Blob = window.Blob
      URL = window.URL or window.webkitURL

      if BlobBuilder? and Uint8Array? and atob? and URL?
        (dataURL) ->
          parts = dataURL.match(@filterBase64Reg)
          #data to blob
          data = atob(parts[3])
          bb = new BlobBuilder()
          arr = new Uint8Array(data.length)
          i = 0
          l = data.length

          while i < l
            arr[i] = data.charCodeAt(i)
            i++
          bb.append arr.buffer
          blob = bb.getBlob()

          url = URL.createObjectURL(blob)
          url
      else
        (dataURL)->
          dataURL

    readFileFromElement: (target)->

      file = if target.files then target.files[0] else null
      @readFile(file)

    ###
    #file is from the file input
    ###
    readFile: (file)->
      _dfr = $.Deferred()
      if typeof FileReader isnt "undefined" and file?
        fileSize = file.size
        fileType = file.type

        type = fileType.split('/')[1]
        #TODO: file type
        if _.indexOf(@acceptFileTypes, type) < 0
          _dfr.reject(
            code: -2
            msg: 'Oops, the image you selected is not the right format (jpg, png) . Please try again.'
          )


        #TODO: file size
        else if (fileSize-@acceptFileSize.min)*(fileSize-@acceptFileSize.max) > 0
          _dfr.reject(
            code: -3
            msg: "file size is not in the range(#{@acceptFileSize.min}~#{@acceptFileSize.max})"
          )



        else
          log module.id, 'browser doesnt support URL, use FileReader instead'
          reader = new FileReader()

          reader.onload = (event)=>
            dataURL = reader.result
            dataURL = @getBlobURL(dataURL)
            _dfr.resolve(dataURL)

          reader.onerror= (error)=>
            _dfr.reject(
              code: -1
              msg: 'error from FileReader'
            )
          reader.readAsDataURL file

      else
        _dfr.reject(
          error: -1
          msg: "Your browser doesn't support FileReader"
        )

      _dfr


    resizeCanvas: (canvas, opts)->
      #max size is modalUI's limitation
      #for improving performance, resize the image to the proper size
      maxWidth = opts.maxWidth #646
      maxHeight = opts.maxHeight #520

      if canvas.width > canvas.height
        resizeWidth = maxWidth
        resizeHeight = canvas.height * resizeWidth/canvas.width
      else
        resizeHeight = maxHeight
        resizeWidth = canvas.width * resizeHeight/canvas.height


      cvs = @getCanvas(resizeWidth, resizeHeight)

      ctx = cvs.getContext('2d')
      ctx.drawImage(canvas, 0, 0, canvas.width, canvas.height, 0, 0, resizeWidth, resizeHeight)

      cvs


    resizeImg: ($srcImg, opts)->
      #max size is modalUI's limitation
      #for improving performance, resize the image to the proper size
      maxWidth = opts.maxWidth #646
      maxHeight = opts.maxHeight #520

      if $srcImg.prop('naturalWidth') > $srcImg.prop('naturalHeight')
        resizeWidth = maxWidth
        resizeHeight = $srcImg.prop('naturalHeight') * resizeWidth/$srcImg.prop('naturalWidth')

        if resizeHeight>maxHeight
          resizeHeight = maxHeight
          resizeWidth *= maxHeight/resizeHeight
      else
        resizeHeight = maxHeight
        resizeWidth = $srcImg.prop('naturalWidth') * resizeHeight/$srcImg.prop('naturalHeight')

        if resizeWidth>maxWidth
          resizeWidth= maxWidth
          resizeHeight *= maxWidth/resizeWidth


      canvas = @getCanvas(resizeWidth, resizeHeight)

      ctx = canvas.getContext('2d')
      ctx.drawImage($srcImg[0], 0, 0, $srcImg.prop('naturalWidth'), $srcImg.prop('naturalHeight'), 0, 0, resizeWidth, resizeHeight)

      ###
      dataURL = @getDataURL(canvas)

      if opts.toBlobURL
        dataURL = @getBlobURL(dataURL)

      dataURL
      ###
      #always return a canvas
      canvas



    crop: ($srcImg, cropInfo)->
      c = cropInfo
      $target = $srcImg
      ratio = $target.prop("naturalWidth") / $target.prop('width')
      console.log ratio
      sX = toDigits(c.x * ratio, 2)
      sY = toDigits(c.y * ratio, 2)
      sW = toDigits(c.w * ratio, 2)
      sH = toDigits(c.h * ratio, 2)
      canvas = @getCanvas(sW, sH)
      ctx = canvas.getContext('2d')
      ctx.drawImage $target[0], sX, sY, sW, sH, 0, 0, canvas.width, canvas.height

      canvas

    createPortraitByCanvas: (canvas)->
      _dfr = $.Deferred()
      #create portrait canvas
      portrait =
        x: canvas.width/4
        y: 0
        w: canvas.width/2
        h: canvas.height

      ctx = canvas.getContext('2d')

      #crop portrait size
      portraitImgData = ctx.getImageData(portrait.x, portrait.y, portrait.w, portrait.h)
      portraitCanvas = @getCanvas(portrait.w, portrait.h)
      portraitCtx = portraitCanvas.getContext('2d')
      portraitCtx.putImageData(portraitImgData, 0, 0)

      #set to thumb size
      canvas_thumb = @getCanvas(@portraitThumb.width, @portraitThumb.height)
      ctx_thumb = canvas_thumb.getContext('2d')

      ctx_thumb.drawImage(portraitCanvas, 0, 0, canvas_thumb.width, canvas_thumb.height)
      _dfr.resolve(
        canvas: portraitCanvas
        thumbCanvas: canvas_thumb
      )
      _dfr


    createLandscapeByCanvas: (canvas)->
      _dfr = $.Deferred()
      #create landscape canvas
      landscape =
        x: (canvas.width - canvas.height)/2
        y: (canvas.height - canvas.width/2)/2
        w: canvas.height
        h: canvas.width/2

      ctx = canvas.getContext('2d')

      landscapeImgData = ctx.getImageData(landscape.x, landscape.y, landscape.w, landscape.h)
      landscapeCanvas= @getCanvas(landscape.w, landscape.h)
      landscapeCtx= landscapeCanvas.getContext('2d')
      landscapeCtx.putImageData(landscapeImgData, 0, 0)
      ##resize to thumb size
      canvas_thumb = @getCanvas(@landscapeThumb.width, @landscapeThumb.height)
      ctx_thumb = canvas_thumb.getContext('2d')

      ctx_thumb.drawImage(landscapeCanvas, 0, 0, canvas_thumb.width, canvas_thumb.height)
      _dfr.resolve(
        canvas: landscapeCanvas
        thumbCanvas: canvas_thumb
      )
      _dfr

    getDataURL: (canvas, noMimeType)->
      dataURL = canvas.toDataURL(@mimeType, @compress)
      if noMimeType?
        parts = dataURL.match(@filterBase64Reg)
        dataURL = parts[3]
      dataURL



    rotateCanvas: (canvas, pos)->
      #pos is 'clockwise' or 'anticlockwise'
      pos = pos or 'clockwise'
      isClockwise = if pos is 'clockwise' then true else false

      deg = if isClockwise then 90 else -90
      if canvas.jquery?
        canvas = canvas[0]
      w = canvas.width
      h = canvas.height
      cvs = @getCanvas(h, w)
      ctx = cvs.getContext('2d')
      ctx.rotate(deg * Math.PI / 180)
      if(isClockwise)
        ctx.drawImage(canvas, 0, -h)
      else
        ctx.drawImage(canvas, -w, 0)

      cvs





