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
    movie = Movie.create(
      title: params[:title],
      overview: params[:overview],
      release_date: params[:release_date],
      inventory: 1,
      image_url: params[:image_url],
      external_id: params[:external_id],
    )
    render status: :ok, json: movie
  end


  def create
    movie = Movie.new(movie_params)

    if movie.save
      render json: { id: movie.id }, status: :ok
    else
      render json: { errors: movie.errors.messages }, status: :bad_request
    end
  end


  private

  def movie_params
    params.permit(:external_id, :image_url, :title, :overview, :release_date, :inventory)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
