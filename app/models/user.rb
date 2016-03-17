class User < ActiveRecord::Base

  def send_welcome_message
    Message.send_to self.name
  end

end
