meanApp.controller 'UserController', ($scope, Global, $log, UserService) ->
  $scope.global = Global
  
  $scope.find = () ->
    UserService.query()
    .$promise.then ((payload) ->
      $scope.users = payload
      $scope.totalUser = $scope.users.length if $scope.users?
    )
 
