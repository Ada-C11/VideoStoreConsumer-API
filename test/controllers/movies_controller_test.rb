require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end

  describe "create" do
    let(:movie_params) {
      {
        title: "Thing",
        overview: "Test",
        release_date: "2019-01-01",
        image_url: "www.dogs.jpg",
        external_id: 3533,
      }
    }
    it "should create a new movie given valid data" do
      expect {
        post movies_path(movie_params)
      }.must_change "Movie.count", 1
      body = JSON.parse(response.body)
      expect(body).must_be_kind_of Hash
      expect(body).must_include "id"
      movie = Movie.find(body["id"].to_i)
      expect(movie.title).must_equal movie_params[:title]
      must_respond_with :success
    end
    # #  update validations if you want to use this test
    # it "returns an error for invalid movie data" do
    #   movie_params[:title] = nil
    #   expect {
    #     post movies_path(movie_params)
    #   }.wont_change "Movie.count"
    #   body = JSON.parse(response.body)
    #   expect(body).must_be_kind_of Hash
    #   expect(body).must_include "errors"
    #   expect(body["errors"]).must_include "title"
    #   expect(body["errors"]["title"]).must_equal ["can't be blank"]
    #   must_respond_with :bad_request
    # end
  end
end
