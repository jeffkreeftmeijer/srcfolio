module Fetcher
  class User
    include HTTParty
    base_uri 'http://github.com/api/v2/json/user/show/'
    format :json

    class << self
      def fetch(github_username)
        response = get("/#{github_username}")
        raise(NotFound, "No Github user was found named \"#{github_username}\"") if response.code == 404

        contributor = Contributor.find_or_create_by_login(response['user']['login'])
        contributor.update_attributes!(
          :name =>      response['user']['name'],
          :company =>   response['user']['company'],
          :location =>  response['user']['location'],
          :website =>   response['user']['blog'],
          :email =>     response['user']['email'],
          :visible =>   true
        )

        Fetcher::Repository.send_later(:fetch_all, github_username)
      end
    end
  end
end
