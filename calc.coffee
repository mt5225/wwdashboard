Q = require 'q'
_ = require 'lodash'
redis = require 'redis'
logger = require './config/logger'
MongoClient = require('mongodb').MongoClient 
url = 'mongodb://localhost:27017/uDCB'

Date::getWeekNumber = ->
  d = new Date(+this)
  d.setHours 0, 0, 0
  d.setDate d.getDate() + 4 - (d.getDay() or 7)
  Math.ceil ((d - (new Date(d.getFullYear(), 0, 1))) / 8.64e7 + 1) / 7

Date::yyyymmdd = ->
  yyyy = @getFullYear().toString()
  mm = (@getMonth() + 1).toString()
  # getMonth() is zero-based
  dd = @getDate().toString()
  yyyy + "-" + (if mm[1] then mm else '0' + mm[0]) + "-" +(if dd[1] then dd else '0' + dd[0])

getDateOfWeek = (w, y) ->
  d = 3 + (w - 1) * 7
  new Date(y, 0, d)

writeToFile = (filename, strArray) ->
  fs = require('fs')
  fd = fs.openSync filename, 'w'
  for it in strArray
    fs.writeSync fd, "#{it}\n"
  fs.closeSync(fd)

topTenUserbyScene = (db) ->
  deferred = Q.defer()
  logger.info "1. top 10 user by scenes"
  db.collection('usmusers').find({}, { username: 1, scenes: 1 }).limit( 20 ).sort( { scenes: -1 } ).toArray (err, result) ->
    strArray = []
    for it in result
      strArray.push "#{it.username}, #{it.scenes}"
    writeToFile './data/top10_user.csv', strArray
    deferred.resolve()
  deferred.promise

usersByWeekYear = (db) ->
  deferred = Q.defer()
  logger.info "2. number of users by week year"
  db.collection('usmusers').find({}, { joindate :1}).toArray (err, result) ->
    weekCount = _.countBy result, (it) ->
      dateObject = new Date(1970,0,1)
      dateObject.setSeconds(parseInt(it.joindate) / 1000)
      return dateObject.getFullYear() + "_" + dateObject.getWeekNumber()
    strArray = []
    for it of weekCount
        p = it.split("_")
        d = getDateOfWeek(p[1], p[0]).yyyymmdd()
        strArray.push "#{d}, #{weekCount[it]}"
    writeToFile './data/user_weekcount.csv', strArray
    deferred.resolve()
  deferred.promise    

sceneByWeekYear = (db) ->
  deferred = Q.defer()
  logger.info "3. number of scenes by week year"
  db.collection('usms').find({}, { create :1} ).sort( { create: 1 } ).toArray (err, result) ->
    weekCount = _.countBy result, (it) ->
      dateString = it.create.split("_")[0]
      reggie = /(\d{4})-(\d{2})-(\d{2})/
      dateArray = reggie.exec(dateString)
      dateObject = new Date((+dateArray[1]), (+dateArray[2])-1,(+dateArray[3]))
      return dateObject.getFullYear() + "_" + dateObject.getWeekNumber()
    strArray = []
    for it of weekCount
        p = it.split("_")
        d = getDateOfWeek(p[1], p[0]).yyyymmdd()
        strArray.push "#{d}, #{weekCount[it]}"
    writeToFile './data/scene_weekcount.csv', strArray
    deferred.resolve()
  deferred.promise 

summaryCount = (db) ->
  deferred = Q.defer()
  logger.info "4. get summary"
  promises = []
  promises.push Q.ninvoke(db.collection('usmusers'), 'count', {})
  promises.push Q.ninvoke(db.collection('usms'), 'count', {})
  promises.push Q.ninvoke(db.collection('usmusers'), 'count', {scenes: { $ne: 0 }})
  promises.push Q.ninvoke(db.collection('usmusers'), 'count', {scenes: { $gt: 1 }})
  Q.all(promises).then (result) ->
    strArray = []
    strArray.push "total_user, #{result[0]}"
    strArray.push "total_scenes, #{result[1]}"
    strArray.push "total_user_has_drawing, #{result[2]}"
    strArray.push "total_user_has_drawing_gt_1, #{result[3]}"
    writeToFile './data/summary.csv', strArray
    deferred.resolve()
  deferred.promise   


MongoClient.connect url, (err, db) ->
  Q.all [topTenUserbyScene(db), usersByWeekYear(db), sceneByWeekYear(db), summaryCount(db)]
  .done ->
    logger.info "we done, clean up"
    db.close()
    process.exit() 
