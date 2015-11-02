meanApp.controller 'UserController', ($scope, Global, $log, $routeParams, UserService) ->
  $scope.global = Global
  
  timeConverter = (UNIX_timestamp) ->
    a = new Date(UNIX_timestamp)
    months = ['Jan', 'Feb', 'Mar','Apr','May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    year = a.getFullYear()
    month = months[a.getMonth()]
    date = a.getDate()
    hour = a.getHours()
    min = a.getMinutes()
    sec = a.getSeconds()
    time = date + ' ' + month + ' ' + year + ' ' + hour + ':' + min + ':' + sec
    time

  $scope.find = () ->
    UserService.query()
    .$promise.then ((payload) ->
      #console.log payload
      users = []
      for it in payload
        it.joindate = timeConverter parseInt(it.joindate)
        it.lastonline = timeConverter parseInt(it.lastonline)
        users.push it
      $scope.users = users
      $scope.totalUser = $scope.users.length if $scope.users?
    )
  
  $scope.sort = (item) ->
    switch $scope.orderProp
      when 'lastonline' then new Date(item.lastonline)
      when 'number of scenes' then item.scenes
      else 1000 - parseInt(item.uid)

  $scope.changeSort = (item) ->
    $scope.orderProp = item

  $scope.findOne = () ->
    UserService.get({id: $routeParams.id})
    .$promise.then ((payload) ->
      $scope.user = payload.detail
      $scope.images = payload.images
    )
