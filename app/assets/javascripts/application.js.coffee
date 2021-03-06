# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#= require jquery
#= require jquery_ujs
#= require vendor/jquery-ui-1.10.4.custom.min
#= require bootstrap-sprockets
#= require leaflet
#= require leaflet.markercluster
#= require hamlcoffee
#= require backbone-rails
#= require backbone-relational
#= require backbone.marionette
#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers
#= require_tree ./modules
#= require_tree ./controllers

# Define namespaces for the app
window.Shothere =
  Models: {}
  Collections: {}
  Controllers: {}
  Routers: {}
  Views: {}

# Create the single page application
Shothere.App = new Backbone.Marionette.Application();

# Prevent default clicks on links for a pushState ready app
Shothere.App.addInitializer () ->
  $(document).on 'click', '.sidebarLink', (evt) ->
    div = $(@).attr('data')
    $(@).parent().toggleClass("active")
    $(@).toggleClass("active")
    $(div).parent().toggleClass("active")
    $(div).toggleClass("active")
  $(document).on 'click', 'a:not([data-bypass])', (evt) ->
    href = $(@).attr('href')
    protocol = @.protocol + '//'
    if (href && href.slice(protocol.length) != protocol)
      evt.preventDefault()
      Backbone.history.navigate(href, true)
  $("#toggleSidebar").on 'click', '.btn', () ->
    $(@).find('.fa-toggle-right, .fa-toggle-left').toggleClass("fa-toggle-right fa-toggle-left")

# Create main router and start history
Shothere.App.addInitializer (options) ->
  moviesController = new Shothere.Controllers.MoviesController options
  new Shothere.Routers.MainRouter {controller: moviesController}
  Backbone.history.start {pushState: true}
  $("#overlay").fadeOut(1000)
  loadMovies = (progress) ->
    progress = 1 unless progress
    $.ajax
      url: "/movies.json?page=#{progress}&only=locations"
      complete: (jqXHR) =>
        resp = $.parseJSON(jqXHR.responseText)
        moviesController.load resp
        if _.isEmpty(resp)
          $("#loading").hide()
        else
          loadMovies(progress+1)
  setTimeout loadMovies, 0
