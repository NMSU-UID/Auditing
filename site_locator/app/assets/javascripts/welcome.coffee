# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $("#blink_on").click -> $("#can_blink").addClass("blink")
  $("#blink_off").click -> $("#can_blink").removeClass("blink")






$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:unload',null)