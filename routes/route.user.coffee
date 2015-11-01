logger = require '../config/logger'
auth = require '../config/auth'

user_service = require '../services/service.user'


module.exports = (app) ->

  app.get '/api/users', auth.none, (req, res) ->
    logger.info 'get all users'
    user_service.getUsers (err, users) ->
      res.send err, users

  app.get '/api/users/:id', auth.none, (req, res) ->
    id = req.params.id
    logger.info 'get user #{id}'
    user_service.getUser id, (err, user) ->
      res.send err, user

  app.post '/signin', auth.none, (req, res) ->

  app.post '/signup', auth.none, (req, res) ->

  app.get '/signout', auth.basic, (req, res) ->
    req.logout()
    res.redirect('/')
