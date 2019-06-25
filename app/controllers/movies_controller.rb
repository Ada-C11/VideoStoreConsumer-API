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

    movie = Movie.new(title: params[:title], external_id: params[:external_id], release_date: params[:release_date], overview: params[:overview])

    if movie.save
      render json: movie.as_json(only: %i[title overview release_date id image_url external_id]), status: :ok
    else
      render json: { ok: false, message: movie.errors.messages }, status: :bad_request
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

end
