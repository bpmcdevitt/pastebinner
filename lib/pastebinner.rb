#!/usr/bin/env ruby
# author: brendan mcdevitt
# a ruby wrapper around all of the methods pastebin provides with its api
# official docs from pastebin on their api can be found at https://pastebin.com/api
require 'rest-client'

module Pastebin
  class Pastebinner
    attr_reader :api_user_key

    def initialize(api_dev_key, username, password)
      @api_dev_key = api_dev_key
      @username = username
      @password = password
      @base_api_url = 'https://pastebin.com/api'
      @scraping_api_url = 'https://scrape.pastebin.com'
      @api_user_key = self.get_api_user_key
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

    # example - params = { "api_dev_key": api_dev_key, "api_option": "paste", "api_paste_code": paste_data }
    def create_paste(params)
      execute_query(:api_post, params)
    end

    def get_api_user_key
      # returns a user session key that can be used as the api_user_key param
      @response ||= RestClient::Request.execute({
                                                  method: :post,
                                                  url: @base_api_url + ENDPOINTS[:login],
                                                  payload: { 'api_dev_key': @api_dev_key,
                                                             'api_user_name': @username,
                                                             'api_user_password': @password }})
    end

    def list_user_pastes
      params = { 'api_dev_key': @api_dev_key,
                 'api_user_key': @api_user_key,
                 'api_results_limit': '100',
                 'api_option': 'list'
               }
      execute_query(:api_post, params)
    end

    def list_trending_pastes
      params = { 'api_dev_key': @api_dev_key,
                 'api_option': 'trend'
               }
      execute_query(:api_post, params)
    end

    # api_paste_key = this is the unique key of the paste data you want to delete.
    def delete_user_paste(api_paste_key)
      params = { 'api_dev_key': @api_dev_key,
                 'api_user_key': @api_user_key,
                 'api_paste_key': api_paste_key,
                 'api_option': 'delete'
               }
      execute_query(:api_post, params)
    end

    def api_post(params)
      response = RestClient::Request.execute(
        method: :post,
        url: @base_api_url + ENDPOINTS[:post],
        payload: params)
    end

    # params is optional for now. to query specific language ?lang=ruby as an example
    def scrape_public_pastes(params = nil)
      response = RestClient::Request.execute(
        method: :get,
        url: @scraping_api_url + ENDPOINTS[:scraping])
    end

    # keep this method private so we are not letting anyone run any method in our program
    private
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

#### INITIAL STEPS

# setup our object and grab a session key
pb =  Pastebin::Pastebinner.new(ENV['pastebin_api_key'], ENV['pastebin_username'], ENV['pastebin_password'])
api_dev_key = ENV['pastebin_api_key']

#### CREATE PASTE
# prepare some sample paste data to send
paste_data = 'this is a test paste two two two.'
# prepare our paste params
params = { "api_dev_key": api_dev_key, "api_option": "paste", "api_paste_code": paste_data }
puts pb.create_paste(params)

#### SCRAPE PUBLIC PASTES
#public_pastes = pb.execute_query(:scrape_public_pastes)
#puts public_pastes

#### LIST USER PASTES
#puts pb.execute_query(:list_user_pastes)
