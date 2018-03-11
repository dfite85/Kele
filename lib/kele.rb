require "httparty"

class Kele
  include HTTParty

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
  
  def get_roadmap(roadmap_id)
    response = self.class.get(api_url("roadmaps/#{roadmap_id}"), headers: { "authorization" => @auth_token })
    @roadmap = JSON.parse(response.body)
  end

  def get_checkpoint(checkpoint_id)
    response = self.class.get(api_url("checkpoints/#{checkpoint_id}"), headers: { "authorization" => @auth_token })
    @checkpoint = JSON.parse(response.body)
  end

  private

  def base_api_endpoint(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end
end