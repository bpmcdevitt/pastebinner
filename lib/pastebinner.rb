#!/usr/bin/env ruby
# author: brendan mcdevitt
# a ruby wrapper around all of the methods pastebin provides with its api
# official docs from pastebin on their api can be found at https://pastebin.com/api
require 'rest-client'
module PasteBin
  class PasteBinner

    # PasteBinner.new(api_dev_key)
    def initialize(api_dev_key)
      @api_dev_key = api_dev_key
      @base_api_url = 'https://pastebin.com/api'
      @scraping_api_url = 'https://scrape.pastebin.com'
    end

    # this should be a hash of { endpoint_name: '/url_endpoint.php'}
    ENDPOINTS = { :login => '/api_login.php',
                  :post => '/api_post.php',
                  :raw => '/api_raw.php',
                  :scraping => '/api_scraping.php',
                  :scrape_item => '/api_scrape_item.php',
                  :srape_item_meta => '/api_scrape_item_meta.php' }

    # basic example hash for creating a paste:
    # params = { 'api_dev_key': @api_dev_key, 'api_option': 'paste'. 'api_paste_code': paste_data}

    # required params:
    # api_dev_key - your unique developer api key
    # api_option - set as paste, this will indicate you want to create a new paste
    # api_paste_code - this is the text that will be written inside of your paste

    # optional params:
    # api_user_key - this parameter is part of the login system, which is explained further down the page
    # api_paste_name - this will be the name / title of your paste
    # api_paste_format - this will be the syntax highlighting value, which is explained in detail further down the page
    # api_paste_private - this makes a paste public, unlisted, or private, public = 0, unlisted = 1, private = 2
    # api_paste_expire_date - this sets the expiration date of your paste, the values are explained further down the page

    def create_paste(params)
      response = RestClient::Request.execute(
        method: :post,
        url: @base_api_url + ENDPOINTS[:post],
        payload: params )
    end

    def get_api_user_key(username, password)
      # returns a user session key that can be used as the api_user_key param
      @response ||= RestClient::Request.execute({
                                                  method: :post,
                                                  url: @base_api_url + ENDPOINTS[:login],
                                                  payload: { 'api_dev_key': @api_dev_key,
                                                             'api_user_name': username,
                                                             'api_user_password': password }})
    end

    # params is optional for now. to query specific language ?lang=ruby as an example
    def scrape_public_pastes(params = nil)
      response = RestClient::Request.execute(
        method: :get,
        url: @scraping_api_url + ENDPOINTS[:scraping])
    end

    # this will be the main way to execute any of these methods. this has the exception handling taken care of.
    def execute_query(selector, *args)
      begin
        send(selector, *args)
      rescue RestClient::ExceptionWithResponse => e
        puts e.message
      end
    end

  end

end

######################## TESTING ####################################################
#####################################################################################
#
# CREATE PASTE
#
# setup our api key
api_dev_key = ENV['pastebin_api_key']

# setup our object and grab a session key
pb =  PasteBin::PasteBinner.new(api_dev_key)
#api_user_key = pb.get_api_user_key(ENV['pastebin_username'], ENV['pastebin_password'])

# here is some paste content
paste_data = 'this is a test paste two two two.'
# prepare our paste params
#params = { "api_dev_key": api_dev_key, "api_option": "paste", "api_paste_code": paste_data }
params = { "api_dev_key": api_dev_key, "api_option": "paste", "api_paste_code": paste_data }

#puts pb.create_paste(params)
#public_pastes = pb.execute_query(pb.scrape_public_pastes)
puts pb.execute_query(:create_paste, params)
