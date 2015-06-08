# Entry point of the application
if window? 
  require './Client'
else
  require './Server'
