class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

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
        methods: [:available_inventory]
        )
      )
  end

  def create
    movie = Movie.find_by(title: params[:title])
    if !movie
      movie = Movie.new(movie_params)
      movie.inventory = 1
    else
      movie.inventory += 1
    end
    if movie.save
      render(
        status: :ok,
        json: movie.as_json(
          only: [:id, :title, :overview, :release_date, :inventory, :external_id, :image_url],
          )
        )
    else
      render json: { errors: movie.errors.messages },
        status: :bad_request
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url, :external_id)
  end
end
