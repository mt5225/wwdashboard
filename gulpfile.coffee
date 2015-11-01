gulp = require 'gulp'
gutil = require 'gulp-util'
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
watch = require 'gulp-watch'
concat = require 'gulp-concat'
imagemin = require 'gulp-imagemin'
rimraf = require 'gulp-rimraf'
flatten = require 'gulp-flatten'
minifycss = require 'gulp-minify-css'
size = require 'gulp-size'


path =
  scripts: 'app/scripts/**/*.coffee'
  styles: 'app/styles/**/*.css'
  bower: 'app/components'
  html: 'app/html/**/*.html'
  assets: 'app/assets/*'


gulp.task 'scripts', () ->
  gulp.src(path.scripts)
    .pipe(coffee({bare: true}).on 'error', gutil.log)
    .pipe(concat 'app.min.js')
    .pipe(size())
    .pipe(gulp.dest '_public/js')

gulp.task 'uglyscripts', () ->
  gulp.src(path.scripts)
    .pipe(coffee({bare: true}).on 'error', gutil.log)
    .pipe(concat 'app.min.js')
    .pipe(uglify())
    .pipe(size())
    .pipe(gulp.dest '_public/js')

gulp.task 'styles', () ->
  gulp.src(path.styles)
    .pipe(concat 'app.min.css')
    .pipe(minifycss())
    .pipe(size())
    .pipe(gulp.dest '_public/css')

gulp.task 'font', () ->
  gulp.src('app/components/materialize/font/**/*')
    .pipe(size())
    .pipe(gulp.dest('_public/font'))

gulp.task 'jquery', () ->
  gulp.src(['app/externaljs/jquery/dist/jquery.min.js', 'app/externaljs/jquery-ui/jquery-ui.min.js'])
    .pipe(size())
    .pipe(gulp.dest('_public/js'))

gulp.task 'bowerjs', () ->
  gulp.src('app/components/**/*.min.js')
    .pipe(flatten())
    .pipe(concat 'vendor.min.js')
    .pipe(size())
    .pipe(gulp.dest('_public/js'))

gulp.task 'bowercss', () ->
  gulp.src('app/components/**/*.min.css')
    .pipe(flatten())
    .pipe(concat 'vendor.min.css')
    .pipe(size())
    .pipe(gulp.dest('_public/css'))

gulp.task 'html', () ->
  gulp.src(path.html)
    .pipe(size())
    .pipe(gulp.dest '_public')

gulp.task 'assets', () ->
  gulp.src(path.assets)
    .pipe(imagemin({optimizationLevel: 5}))
    .pipe(size())
    .pipe(gulp.dest '_public/assets')

gulp.task 'watch', () ->
  gulp.watch path.scripts, ['scripts']
  gulp.watch path.styles, ['styles']
  gulp.watch path.bower, ['bowerjs']
  gulp.watch path.html, ['html']
  gulp.watch path.assets, ['assets']

gulp.task 'clean', () ->
  gulp.src('_public', { read: false })
    .pipe(rimraf())


gulp.task 'default', ['styles', 'html', 'font', 'jquery', 'bowerjs', 'bowercss', 'assets']

gulp.task 'dev', ['default', 'scripts', 'watch']

gulp.task 'build', ['clean', 'default', 'uglyscripts']
