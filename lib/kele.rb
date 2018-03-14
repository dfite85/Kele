require "httparty"
require './lib/roadmap.rb'

class Kele
  include HTTParty
  include Roadmap

  def initialize(email, password)
    response = self.class.post(base_api_endpoint("sessions"), body: { email: email, password: password })
    raise "Invalid email or password" if response.code == 404
    @auth_token = response["auth_token"]
  end
  
  def get_me
    response = self.class.get(base_api_endpoint("users/me"), headers: { "authorization" => @auth_token })
    @user_data = JSON.parse(response.body)
    @user_data.keys.each do |key|
      self.class.send(:define_method, key.to_sym) do
        @user_data[key]
      end
    end
  end
  
  def get_mentor_availability(mentor_id)
    response = self.class.get(base_api_endpoint("mentors/#{mentor_id}/student_availability"), headers: { "authorization" => @auth_token })
    @mentor_availability = JSON.parse(response.body)
  end
  
  def get_messages(page = nil)
    if page != nil
      response = self.class.get("https://www.bloc.io/api/v1/message_threads", headers: { "authorization": @auth_token }, body: { "page": page })
    else
      response = self.class.get("https://www.bloc.io/api/v1/message_threads", headers: { "authorization": @auth_token })
    end
    JSON.parse(response.body)
  end

  def create_message(sender, recipient_id, subject, stripped_text)
    response = self.class.post(base_api_endpoint("messages"), headers: { "authorization" => @auth_token },
      body: {
        "sender": sender,
        "recipient_id": recipient_id,
        "subject": subject,
        "stripped_text": stripped_text
      })
      puts response
  end
  
  def create_submissions(checkpoint_id, assignment_branch, assignment_commit_link, comment, enrollment_id)
    response = self.class.post(base_api_endpoint("checkpoint_submissions"), headers: { "authorization" => @auth_token },
     body: { 
       "checkpoint_id": checkpoint_id, 
       "assignment_branch": assignment_branch, 
       "assignment_commit_link": assignment_commit_link, 
       "comment": comment, 
       "enrollment_id": enrollment_id
       })
      puts response
  end

  private

  def base_api_endpoint(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end
end