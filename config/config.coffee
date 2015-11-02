base =
  ENV: process.env.NODE_ENV || 'development'
  PORT: process.env.PORT || 8081
  LOGPATH: "uinnova.coffee.log"
  COOKIE_SECRET: "thisisthesecretforthesession"
  DBURLTEST: "mongodb://localhost/uDCB"

dev =
  DBURL: "mongodb://localhost/uDCB"

prod =
  DBURL: "mongodb://localhost/uDCB"

mergeConfig = (config) ->
  for key, val of config
    base[key] = val
  base

module.exports = ( ->
  switch base.ENV
    when 'development' then return mergeConfig(dev)
    when 'production' then return mergeConfig(prod)
    else return mergeConfig(dev)
)()



