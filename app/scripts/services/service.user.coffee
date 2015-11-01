meanApp = angular.module('meanApp')
meanApp.service 'UserService', ($resource) ->
    console.log "User Service"
    return $resource '/api/users/:id', { id: '@id'}