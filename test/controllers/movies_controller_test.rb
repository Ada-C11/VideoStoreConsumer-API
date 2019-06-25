require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers["Content-Type"].must_include "json"

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
      @response.headers["Content-Type"].must_include "json"

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
    it "returns a JSON object" do
      post movies_url(title: "testing", external_id: 987765)
      assert_response :success
      @response.headers["Content-Type"].must_include "json"
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "returns expected fields" do
      post movies_url(
        title: "testing",
        overview: "testestestestest",
        release_date: "1-12-19",
        image_url: "https://placedog.net/500",
        inventory: 1,
        external_id: 987765,
      )
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "id"
      movie.must_include "title"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "overview"
    end

    it "returns an error if movie already exists in database" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      movie = JSON.parse @response.body

      post movies_url(
        external_id: 1,
      )
      assert_response :conflict
      data = JSON.parse @response.body
      data.must_include "errors"
    end
  end
end
