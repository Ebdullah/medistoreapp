class UserMailer < ApplicationMailer
  default from: 'no-reply@medistore.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://[::1]:3000/users/sign_up'

    mail(to: @user.email, subject: 'Welcome to MedistorPro')
  end
end
