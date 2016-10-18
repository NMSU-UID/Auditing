# Auditing
Auditing is awesome. CS 515 User Interfaces Repo.

Here are the instructions for getting this Ruby on Rails project running. Alas, Rails projects are not really meant to be packaged up as an executable; there is a tool for that, but it's so out-of-date it won't work with newer versions of Ruby (Ruby is notoriously not backwards compatible). Ruby and Rails are very happy on Macs or Linux. If you're using Mac just make sure Homebrew is updated. For Windows I recommend using http://railsinstaller.org/ (the Ruby 2.2 version) as it has everything you'd need to run my project.

Assuming you're on Mac/Linux, first:

1. Install rvm (full instructions are here: https://rvm.io/rvm/install but `\curl -sSL https://get.rvm.io | bash -s stable` is the default command)
1. `rvm install 2.2.5` to install ruby 2.2.5

Then once you've got ruby installed one way or another:

1. `git clone https://github.com/NMSU-UID/Auditing.git` where ever you want to stick this project
1. `cd Auditing/site_locator`
1. `bundle` to install the necessary libraries, called gems, ha ha ha
1. `cp config/database.yml.example config/database.yml` because secrets don't go in public repos; right now I'm just using sqlite3, so you don't have to set anything else up
1. `rake db:migrate` to create the necessary database structures
1. `cp config/secrets.yml.example config/secrets.yml`
1. `rake secret` and copy the value it outputs into config/secrets.yml. It goes right after `secret_key_base:` in the development section.
1. `rails server` to run the server
1. Navigate to  0.0.0.0:3000 using your web browser of choice.