class Import

  require "mechanize"
  CREDENTIALS = [
    {username: "", password: ""}
  ]


  def self.run max_pages = 1
    a = Import.new
    users = []
    a.get_online_users(max_pages).each do |name|
      user = User.create name: name unless User.find_by_name name
      if user
        user.send_welcome_message
        users << user
      end
    end
    
    return users.size

  end

  def initialize      
    @agent = Mechanize.new
    login!

  end

  def browse(page=1)
    url = "https://www.thaifriendly.com/browse.php?c=s&gender=f&agefrom=0&ageto=0&weightfrom=0&weightto=0&heightfrom=0&heightto=0&country=TH&city=Bangkok&area=0&distance=30&education=ALL&ch=ALL&orderby=lastactive&online=on&agerange=agerangeoff&photo=on&page=#{page}"
    
    p "import: #{url}"
    p "--------------------"

    @agent.post("#{url}&#{Time.now.to_i}#{rand(10**3)}", {}, {'ajaxy' => true}).body
  end

  def get_online_users(max_pages)
    users = []
    (1..max_pages).to_a.each do |i|

      page = browse(i)

      data = Regexp.new(/(?<data>thumbdata = {.+?};)/m).match(page)[:data]
      cxt = V8::Context.new
      cxt.eval data
      profiles = cxt[:thumbdata]

      usernames = profiles.thumbs.collect{|x| x.username rescue nil} 

      p "found usernames: #{usernames.join(", ")}"
      users.concat usernames.compact
    end
    users
  end

  def login!
    credentials = CREDENTIALS.sample
    page = @agent.get 'http://www.thaifriendly.com'
    login_form = page.forms.first
    login_form['username'] = credentials[:username]
    login_form['password'] = credentials[:password]
    @agent.submit login_form
  end

end




  #   profile_field = {}
  #   profile_data.profilefield.each do |entry|
  #     h = {}
  #     h[entry.k.downcase] = entry.v
  #     profile_field.merge!(h)
  #   end

  #   profile = {}
  #   [:city, :country, :headline, :description, :income, :occupation].each do |key|
  #       #get from profile_data if possible, else profile_field or nil
  #       profile[key] = (profile_data[key] ? profile_data[key] : profile_field[key.to_s]) rescue next
  #     end

  #     profile[:education] = education_parser(profile_field["education"])
  #     profile[:has_children] = has_children_parser(profile_field["has children"])
  #     profile[:wants_children] = wants_children_parser(profile_field["want children"])
  #     profile[:age_min] = profile_field['min. age'].to_i rescue nil
  #     profile[:age_max] = profile_field['max. age'].to_i rescue nil
  #     profile[:age] = profile_data[:age] rescue nil
  #     profile[:height] = profile_field['height'].match(/\d+/)[0] rescue nil
  #     profile[:weight] = profile_field['weight'].match(/\d+/)[0] rescue nil     

  #     # dafür sorgen dass "any".to_i => 0 entsprechend für uns arbietet
  #     profile[:age_min] = 18 if profile[:age_min] < 18
  #     profile[:age_max] = 80 if profile[:age_max] == 0

  #     profile
  #   end


  #   def get_picture_urls username
  #     pictures = []
  #     page = get_html(username)
  #     #erst das profilfoto
  #     path = page.scan(/\\\/p\\\/\d{4}-\d{2}\\\/#{username}\\\/[\w\d]{32}-medium\.jpg/i).first
  #     unless path
  #       raise Importer::WrongProfile
  #     end
  #     pictures << path.gsub('\\', '')
  #     #dann alle anderen fotos      
  #     page.scan(/\/p\/\d{4}-\d{2}\/#{username}\/[\w\d]{32}-thumb.jpg/i).each do |path|
  #     pictures << path
  #   end
  #     #und uniquen
  #     pictures.collect{|x| "http://www.thaifriendly.com#{x.gsub(/medium|thumb/, "big")}"}.uniq
  #   end


