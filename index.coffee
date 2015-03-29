config =
  token: '07dc1dd22949e996bb2aca176418de213de9cca3'
  room: process.argv[2] && process.argv[2] || 'racc-oo-n/uwc_gitter-bot'


class Bot
  constructor: (config) ->
    gitter = new Gitter(config.token)
    msgCtrl = new MessagesController

    gitter.joinRoom(config.room)
      .then (room) ->
        console.log 'Join room:', room.name
        gitter
          .setRoom(room)
          .sendMessage(msgCtrl.sayHello())
          .addListener()
            .on 'message', (message) ->
              txt = message.text
              if msgCtrl.validate('calc', txt)
                gitter.sendMessage(msgCtrl.calc(message.text))
              else if msgCtrl.validate('bye', txt)
                gitter.sendMessage(msgCtrl.sayBye())
              else if msgCtrl.validate('hello', txt)
                gitter.sendMessage(msgCtrl.sayHello())
      .fail (err) ->
        console.log "Can't join room #{config.room}:", err


class MessagesController
  messages =
    'success': ":heavy_check_mark: "
    'error': ':x: I can\'t solve it'
    'invalid': ':interrobang: I understand only: 0-9 + - * / ( )'
    'hello': 'Hello :earth_africa: !   I\'m Bot :space_invader:.   And I can solve some mathematical expressions for you. I accept expression like "calc ..." and understand operations: (), *, /, +, -    :sparkles::sparkles::sparkles:'
    'bye': ':door: Bye!'
  validation =
    'calc': /^calc/i
    'disallow': /[^\d\+\-\*\/\(\)]+/
    'bye': /leave/ig
    'hello': /hi/ig
  replace =
    'calc': /^calc/i
    'space': /\s/g

  sayHello: -> return messages['hello']
  sayBye: -> return messages['bye']
  validate: (type, message) -> return validation[type].test(message)
  clear: (type, message) -> return message.replace(replace[type], '')
  calc: (message) ->
    expression = @clear('calc', message).trim()
    exp = @clear('space', expression)

    if !@validate('disallow', exp)
      try result = messages['success'] + expression + ' = ' + eval(exp)
      catch e then result = messages['error']
    else
      result = messages['invalid']
    return result


class Gitter
  constructor: (token) ->
    @gitter = new (require('node-gitter'))(token)
    return @

  joinRoom: (name) -> @gitter.rooms.join(name)
  addListener: -> @room?.listen()
  setRoom: (room) ->
    @room = room
    return @
  sendMessage: (message) ->
    @room?.send(message)
    return @



myBot = new Bot(config)
