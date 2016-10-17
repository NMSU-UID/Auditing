require "action_mailer"

yaml_config = File.read("config/email.yml")
email_config = YAML.load(yaml_config)
ActionMailer::Base.delivery_method = email_config['delivery_method']
ActionMailer::Base.smtp_settings = {
    address: email_config['smtp_settings']['address'],
    port: email_config['smtp_settings']['port'],
    notify_emails: email_config['notify_emails']
}
ActionMailer::Base.view_paths = File.dirname(__FILE__)
set :default_from, email_config['default_from']
set :notify_emails, email_config['notify_emails']

class CapMailer < ActionMailer::Base
  default from: "App Deployment <#{fetch(:default_from)}>"

  def deploy_notification(cap_vars)
    @now = Time.now

    set :body, ENV['comment']

    mail(to: fetch(:notify_emails),
         subject: "#{fetch(:human_readable_application_name)} - Changes to application on #{fetch(:stage)} server at #{fetch(:host)}"
    )
  end

  def test_email
    @now = Time.now

    mail(to: fetch(:notify_emails),
         subject: "#{fetch(:human_readable_application_name)} - Capistrano test email #{@now.strftime("on %m/%d/%Y at %I:%M %p")}"
    )

  end

end