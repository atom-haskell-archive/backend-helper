{Disposable, CompositeDisposable} = require 'atom'

module.exports=
class BackendHelper
  constructor: (@packageName,@opts) ->
    @opts ?= {}
    @opts.useBackend ?= 'useBackend'
    @opts.backendInfo ?= 'backendInfo'
    @opts.backendVar ?= 'backend'
    @opts.backendName ?= 'haskell-*-backend'
    @opts.main = @opts.main

  init: =>
    @opts.main.config[@opts.useBackend].enum=['']
    bknd = atom.config.get("#{@packageName}.#{@opts.useBackend}")
    if !!bknd
      @opts.main.config[@opts.useBackend].enum.push bknd

    if atom.config.get("#{@packageName}.#{@opts.backendInfo}")
      setTimeout (=>
        unless @opts.main?[@opts.backendVar]?
          bn = atom.config.get("#{@packageName}.#{@opts.useBackend}")
          if !bn
            message = "
              #{@packageName}:
              #{@packageName} requires a package providing
              #{@opts.backendName} service.
              Consider installing haskell-ghc-mod or other package, which
              provides #{@opts.backendName}.
              You can disable this message in #{@packageName} settings.
              "
          else
            p=atom.packages.getActivePackage(bn)
            if p?
              message = "
                #{@packageName}:
                You have selected #{bn} as your backend provider, but it
                does not provide #{@opts.backendName} service.
                You may need to update #{bn}.
                You can disable this message in #{@packageName} settings.
                "
            else
              message = "
                #{@packageName}:
                You have selected #{bn} as your backend provider, but it
                failed to activate.
                Check your spelling and if #{bn} is installed and activated.
                You can disable this message in #{@packageName} settings.
                "
          atom.notifications.addWarning message, dismissable: true
          console.log message
        ), 5000

  consume: (service,opts) =>
    hasSn = service.name() in @opts.main.config[@opts.useBackend].enum
    @opts.main.config[@opts.useBackend].enum.push service.name() unless hasSn
    bn = atom.config.get("#{@packageName}.#{@opts.useBackend}")
    return if !!bn and service.name()!=bn
    if @opts.main?[@opts.backendVar]?
      bnold=@opts.main[@opts.backendVar].name()
      atom.notifications.addInfo "#{@packageName} is already using
        backend #{bnold}, and new backend #{service?.name?()}
        appeared. You can select one in #{@packageName} settings.
        Will keep using #{bnold} for now.", dismissable: true
      return
    @opts.main[@opts.backendVar] = service
    opts?.success? service
    new Disposable =>
      @opts.main[@opts.backendVar] = null
      opts?.dispose? service
