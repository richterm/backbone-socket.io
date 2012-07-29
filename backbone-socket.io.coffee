originalSync = Backbone.sync
originalModel = Backbone.Model.prototype.constructor
originalCollection = Backbone.Model.prototype.constructor

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
  

Backbone.Model = Backbone.Model.extend
  constructor: (attributes, options) ->
    @socket = attributes?.socket
    delete attributes.socket
    originalModel.apply(this, arguments)
    return


Backbone.Collection = Backbone.Collection.extend
  constructor: (attributes, options) ->
    @socket = attributes?.socket
    delete attributes.socket
    originalCollection.apply(this, arguments)
    return
