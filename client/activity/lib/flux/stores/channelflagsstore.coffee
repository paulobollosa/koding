KodingFluxStore = require 'app/flux/store'
actions         = require '../actions/actiontypes'
toImmutable     = require 'app/util/toImmutable'
immutable       = require 'immutable'

module.exports = class ChannelFlagsStore extends KodingFluxStore

  @getterPath = 'ChannelFlagsStore'


  getInitialState: -> immutable.Map()


  initialize: ->

    @on actions.LOAD_MESSAGES_BEGIN, @handleLoadMessagesBegin
    @on actions.LOAD_MESSAGES_SUCCESS, @handleLoadMessagesSuccess
    @on actions.CREATE_MESSAGE_BEGIN, @handleCreateMessageBegin
    @on actions.CREATE_MESSAGE_SUCCESS, @handleCreateMessageEnd
    @on actions.CREATE_MESSAGE_FAIL, @handleCreateMessageEnd
    @on actions.SET_ALL_MESSAGES_LOADED, @handleSetAllMessagesLoaded
    @on actions.UNSET_ALL_MESSAGES_LOADED, @handleUnsetAllMessagesLoaded
    @on actions.SET_LOADED_WITH_SCROLL, @handleSetLoadedWithScroll
    @on actions.UNSET_LOADED_WITH_SCROLL, @handleUnsetLoadedWithScroll

  handleLoadMessagesBegin: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'isMessagesLoading'], yes


  handleLoadMessagesSuccess: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'isMessagesLoading'], no


  handleCreateMessageBegin: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'isMessageBeingSubmitted'], yes


  handleCreateMessageEnd: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'isMessageBeingSubmitted'], no


  handleSetAllMessagesLoaded: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'reachedFirstMessage'], yes


  handleUnsetAllMessagesLoaded: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'reachedFirstMessage'], no


  handleSetLoadedWithScroll: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'loadedWithScroll'], yes


  handleUnsetLoadedWithScroll: (channelFlags, { channelId }) ->

    channelFlags = helper.ensureChannelMap channelFlags, channelId
    return channelFlags.setIn [channelId, 'loadedWithScroll'], no


helper =

  ensureChannelMap: (channelFlags, channelId) ->

    unless channelFlags.has channelId
      return channelFlags.set channelId, immutable.Map()

    return channelFlags

