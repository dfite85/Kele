require "httparty"

class Kele
  include HTTParty

  def initialize(email, password)
    response = self.class.post(base_api_endpoint("sessions"), body: { email: email, password: password })
    
    raise "Invalid email or password" if response.code == 404
    @auth_token = response["auth_token"]
  end

  private

  def base_api_endpoint(end_point)
    "https://www.bloc.io/api/v1/#{end_point}"
  end
end