class EnvironmentMachineItem extends EnvironmentItem

  stateClasses = ""
  for state in Object.keys Machine.State
    stateClasses += "#{state.toLowerCase()} "

  constructor:(options={}, data)->

    options.cssClass           = 'machine'
    options.joints             = ['left']

    options.allowedConnections =
      EnvironmentDomainItem    : ['right']

    super options, data

  viewAppended: ->

    { label, provider, uid, status } = machine = @getData()
    { computeController } = KD.singletons

    @addSubView new KDCustomHTMLView
      partial : "<span class='toggle'></span>"

    @addSubView @title = new KDCustomHTMLView
      partial : "<h3>#{label or provider or uid}</h3>"

    @addSubView @ipAddress = new KDCustomHTMLView
      partial  : @getIpLink()

    @addSubView @state = new KDCustomHTMLView
      tagName  : "span"
      cssClass : "state"

    @addSubView @statusToggle = new KodingSwitch
      cssClass     : "tiny"
      defaultValue : status.state is Machine.State.Running
      callback     : (state)=>
        if state
          computeController.start machine
        else
          computeController.stop machine

    @addSubView @progress = new KDProgressBarView
      cssClass : "progress"

    @addSubView @terminalIcon = new KDCustomHTMLView
      tagName  : "span"
      cssClass : "terminal"
      click    : @bound "openTerminal"

    computeController.on "build-#{machine._id}",   @bound 'invalidateMachine'
    computeController.on "destroy-#{machine._id}", @bound 'invalidateMachine'

    computeController.on "public-#{machine._id}", (event)=>

      if event.percentage?

        @progress.updateBar event.percentage

        if event.percentage < 100 then @setClass 'loading busy'
        else return KD.utils.wait 1000, =>
          @unsetClass 'loading busy'
          @updateState event.status

      else

        @unsetClass 'loading busy'

      @updateState event.status

    computeController.info machine


  updateState:(status)->

    return unless status

    {Running, Starting} = Machine.State

    @unsetClass stateClasses
    @setClass status.toLowerCase()

    if status in [Running, Starting]
    then @statusToggle.setOn no
    else @statusToggle.setOff no

    @getData().setAt "status.state", status
    @state.updatePartial status


  invalidateMachine:(event)->

    if event.percentage is 100

      machine = @getData()
      KD.remote.api.JMachine.one machine._id, (err, newMachine)=>
        if err then warn ".>", err
        else
          @setData newMachine
          @ipAddress.updatePartial @getIpLink()


  contextMenuItems: ->

    machine = @getData()

    return  if machine.status.state is Machine.State.NotInitialized

    colorSelection = new ColorSelection selectedColor : @getOption 'colorTag'
    colorSelection.on "ColorChanged", @bound 'setColorTag'

    this_   = this

    vmAlwaysOnSwitch = new VMAlwaysOnToggleButtonView

    items =

      customView1         : vmAlwaysOnSwitch

      'Build Machine'     :
        callback          : ->
          {computeController} = KD.singletons
          computeController.build machine
          @destroy()

      'Re-initialize VM'  :
        disabled          : KD.isGuest()
        callback          : ->
          new KDNotificationView
            title : "Not implemented yet!"
          @destroy()

      'Open VM Terminal'  :

        callback          : ->
          this_.openTerminal()
          @destroy()

        separator         : yes

      'Update init script':
        separator         : yes
        callback          : @bound "showInitScriptEditor"

      'Delete'            :
        disabled          : KD.isGuest()
        separator         : yes
        action            : 'delete'

      customView2         : colorSelection

    return items


  openTerminal:->

    KD.getSingleton("router").handleRoute "/Terminal", replaceState: yes

  confirmDestroy:->

    {computeController} = KD.singletons
    computeController.destroy @getData()


  showInitScriptEditor: ->

    modal =  new EditorModal
      editor              :
        title             : "VM Init Script Editor <span>(experimental)</span>"
        content           : @data.meta?.initScript or ""
        saveMessage       : "VM init script saved"
        saveFailedMessage : "Couldn't save VM init script"
        saveCallback      : (script, modal) =>
          KD.remote.api.JVM.updateInitScript @data.hostnameAlias, script, (err, res) =>
            if err
              modal.emit "SaveFailed"
            else
              modal.emit "Saved"
              @data.meta or= {}
              @data.meta.initScript = Encoder.htmlEncode modal.editor.getValue()


  getIpLink:->

    { ipAddress, status:{state}  } = @getData()
    { Running, Rebooting } = Machine.State

    if ipAddress? and state in [ Running, Rebooting ]

      """
        <a href="http://#{ipAddress}" target="_blank" title="#{ipAddress}">
          <span class='url'>#{ipAddress}</span>
        </a>
      """

    else ""
