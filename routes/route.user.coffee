logger = require '../config/logger'
auth = require '../config/auth'

user_service = require '../services/service.usmuser'

module.exports = (app) ->

  app.get '/api/users', auth.none, (req, res) ->
    logger.info 'get all users'
    user_service.getUsers (err, users) ->
      if err
        logger.error err
        res.status(500).json err
      else
        res.status(200).json users

  app.get '/api/users/:id', auth.none, (req, res) ->
    id = req.params.id
    logger.info "get user #{id}"
    user_service.getUser id, (err, user) ->
      if err
        logger.error err
        res.status(500).json err
      else
        res.status(200).json user

  app.post '/signin', auth.none, (req, res) ->

  app.post '/signup', auth.none, (req, res) ->

  app.get '/signout', auth.basic, (req, res) ->
    req.logout()
    res.redirect('/')
