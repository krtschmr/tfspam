class Message

  require "mechanize"
  CREDENTIALS = [
    {username: "", password: ""}
  ]

  def self.send_to username
    a = Message.new
    a.send_message_to username
    return true
  end

  def initialize      
    @agent = Mechanize.new
    login!
  end

  def send_message_to username
#    @agent.post("https://www.thaifriendly.com/#{username}?=#{Time.now.to_i}#{rand(10**3)}", {}, {'ajaxy' => true}).body


    message = "hi"
    @agent.post("https://www.thaifriendly.com/nt/messenger.php", {'to' => username, 'type'=> "message", "msg" => message} )


    message = "just answer me, if you want to meet. right now or tonight. my room, ratchada soi 3."
    @agent.post("https://www.thaifriendly.com/nt/messenger.php", {'to' => username, 'type'=> "message", "msg" => message} )

    # message = "i would love to meet you - u like to meet me too?"
    # @agent.post("https://www.thaifriendly.com/nt/messenger.php", {'to' => username, 'type'=> "message", "msg" => message} )
  end

  private

  def login!
    credentials = CREDENTIALS.sample
    page = @agent.get 'http://www.thaifriendly.com'
    login_form = page.forms.first
    login_form['username'] = credentials[:username]
    login_form['password'] = credentials[:password]
    @agent.submit login_form
  end

end