#Setting up route
meanApp.config ['$routeProvider',
  ($routeProvider) ->
        $routeProvider
          .when '/users',
            templateUrl: 'views/users.html'
            controller: 'UserController'
          .when '/users/:id',
            templateUrl: 'views/scenes.html'
            controller: 'UserController'
          .when '/',
            templateUrl: 'views/main.html'
            controller: 'MainController'
          .when '/500',
              templateUrl: 'views/500.html'
          .when '/404',
              templateUrl: 'views/404.html'
          .otherwise
            redirectTo: '/404'
]