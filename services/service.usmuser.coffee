logger = require '../config/logger'
_ = require 'lodash'

mongoose = require 'mongoose'
USMUser = mongoose.model 'USMUser'
USM = mongoose.model 'USM'


module.exports =
  getUsers: (cb) ->
    USMUser.find {}, (err, users) -> 
      #console.log user
      cb err, users
      
  getUser: (id, cb) ->
    USMUser.findOne {uid: id}, (err, user) ->
      userinfo = {}
      userinfo.detail = user
      query = USM.find({userid: id}).select({"_id": 0, "resource": 0})
      query.exec (err, scenes) ->
        images = []
        for item in scenes
          images.push item
        userinfo['images'] = images
        cb err, userinfo

