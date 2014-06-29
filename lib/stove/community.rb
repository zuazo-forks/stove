require 'chef-api'

module Stove
  class Community
    include Mixin::Instanceable
    include Mixin::Optionable

    #
    # The default endpoint where the community site lives.
    #
    # @return [String]
    #
    DEFAULT_ENDPOINT = 'https://cookbooks.opscode.com/api/v1'

    #
    # Get and cache a community cookbook's JSON response from the given name
    # and version.
    #
    # @example Find a cookbook by name
    #   Community.cookbook('apache2') #=> {...}
    #
    # @example Find a cookbook by name and version
    #   Community.cookbook('apache2', '1.0.0') #=> {...}
    #
    # @example Find a non-existent cookbook
    #   Community.cookbook('not-real') #=> Community::BadResponse
    #
    # @raise [Community::BadResponse]
    #   if the given cookbook (or cookbook version) does not exist on the community site
    #
    # @param [String] name
    #   the name of the cookbook on the community site
    # @param [String] version (optional)
    #   the version of the cookbook to find
    #
    # @return [Hash]
    #   the hash of the cookbook
    #
    def cookbook(name, version = nil)
      if version.nil?
        connection.get("cookbooks/#{name}")
      else
        connection.get("cookbooks/#{name}/versions/#{Util.version_for_url(version)}")
      end
    end

    #
    # Upload a cookbook to the community site.
    #
    # @param [Cookbook] cookbook
    #   the cookbook to upload
    #
    def upload(cookbook)
      connection.post('cookbooks', {
        tarball:  Faraday::UploadIO.new(cookbook.tarball, 'application/x-tar'),
        cookbook: { category: cookbook.category }.to_json,
      })
    end

    private

    #
    # The Faraday connection object with lots of pretty middleware.
    #
    def connection
      @connection ||= ChefAPI::Connection.new(
        endpoint: ENV['STOVE_ENDPOINT'] || DEFAULT_ENDPOINT,
        client:   ENV['STOVE_CLIENT'],
        key:      ENV['STOVE_KEY'],
      )
    end
  end
end
