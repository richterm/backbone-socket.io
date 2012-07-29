originalSync = Backbone.sync

Backbone.sync = (method, model, options) ->
  socket = model.socket or model.collection?.socket
  
  # Apply original sync if no valid socket defined
  originalSync.apply(this, arguments) unless socket

  # Strip callbacks
  success = options.success
  delete options.success
  
  error = options.error
  delete options.error

  socket.emit "sync",
    url: model.url()
    method: method
    model: JSON.stringify(model.toJSON())
    options: options
    (err, response) ->
      if err
        error.call(this, err)
      else
        success.apply(this, response)
      return
  
  return
  

@SocketIOModel = Backbone.Model.extend
  constructor: (attributes, options) ->
    @socket = attributes?.socket
    delete attributes.socket
    Backbone.Model.prototype.constructor.apply(this, arguments)
    return


@SocketIOCollection = Backbone.Collection.extend
  constructor: (attributes, options) ->
    @socket = attributes?.socket
    delete attributes.socket
    Backbone.Collection.prototype.constructor.apply(this, arguments)
    return
