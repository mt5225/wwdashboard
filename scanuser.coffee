Q = require 'q'
_ = require 'lodash'
redis = require 'redis'
MongoClient = require('mongodb').MongoClient 
url = 'mongodb://localhost:27017/uDCB'

client = redis.createClient()

client.on 'error', (err) ->
  console.log 'Error ' + err
  return

scenes = []

#drop users collection
dropUsersCollection = (db)->
  deferred = Q.defer()
  db.collection('usmusers').drop (err, result) ->
    console.log "1. drop users collection"
    deferred.resolve()
    return
  deferred.promise

#group the scenes
calcScenes = (db)->
  deferred = Q.defer()
  db.collection('usms').aggregate([ { $group: '_id': '$userid', 'count': $sum: 1 } ]).toArray (err, result) ->
    console.log "2. aggregate scene record"
    scenes = result
    #console.log scenes
    deferred.resolve()
    return
  deferred.promise

#query database
queryUserData = (db)->
  deferred = Q.defer()
  Q.ninvoke(client, "ZRANGE", 'userslug:uid',0, 9999).done (users) ->
    console.log "3. create user info"
    promises = _.map [1...users.length], (id) ->
      deferred2 = Q.defer()
      Q.ninvoke(client, "HSCAN", "user:#{id}",  0, "COUNT", 10000).done (replies) ->
        userinfo = {}
        #make key and value
        replies = replies[1]
        len = replies.length / 2
        for i in [0...len]
          userinfo[replies[i*2]] = replies[i*2 + 1]
        userinfo.scenes = 0
        for it in scenes
          if it['_id'] is userinfo.uid
            userinfo.scenes = it['count']
            break
        db.collection('usmusers').insertOne userinfo, (err, result) ->
          deferred2.resolve()
      deferred2.promise
    Q.allSettled(promises)
    .then ->     
      deferred.resolve()
      return
  deferred.promise

closeConnection = (db) ->
  db.close()
  client.quit()
  process.exit()

MongoClient.connect url, (err, db) ->
  Q.all [dropUsersCollection(db), calcScenes(db), queryUserData(db)]
  .done ->
    console.log "we done, clean up"
    db.close()
    client.quit()
    process.exit()
