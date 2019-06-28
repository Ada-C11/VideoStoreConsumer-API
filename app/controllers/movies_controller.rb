class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  BASE_IMG_URL = "https://image.tmdb.org/t/p/"
  DEFAULT_IMG_SIZE = "w185"

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory],
      ),
    )
  end

  def create
    movie = Movie.new(movie_params)
    better_image = movie.image_url.gsub("https://image.tmdb.org/t/p/w185", "")
    movie.image_url = better_image

    if movie.save
      render json: {id: movie.id}, status: :ok
    else
      render json: {errors: movie.errors.messages}, status: :bad_request
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: {errors: {title: ["No movie with title #{params["title"]}"]}}
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url, :external_id)
  end
end
