require "pry"

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
        methods: [:available_inventory],
      ),
    )
  end

  def create
    add_movie = Movie.new(movie_params)

    if add_movie.save!
      render json: {id: add_movie.id}
    else
      render_error :bad_request
    end
  end

  private

  def movie_params
    params.permit(:external_id, :title, :overview, :release_date, :inventory, :image_url)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: {errors: {title: ["No movie with title #{params["title"]}"]}}
    end
  end
end
