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
        only: [:id, :title, :overview, :release_date, :inventory, :image_url, :external_id],
        methods: [:available_inventory],
      ),
    )
  end

  def create
<<<<<<< HEAD
    @movie = Movie.find_by(params[:title]) 

    if !@movie
      @movie = Movie.new(movie_params)
      @movie.inventory = 5
    else
      @movie.inventory += 1
      render status: :ok
    end

    if @movie.save
      render status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
=======
    @movie = Movie.new(movie_params)

    if @movie.save
      # render(status: :ok,
      #        json: @movie.as_json(
      #          only: [:title, :overview, :release_date, :inventory],
      #          methods: [:available_inventory],
      #        ))
>>>>>>> eb92804e59afe8ea57f1d54a5c71918660c06c78
    else
      render status: :bad_request, json: { errors: @movie.errors.messages}
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
    # allow params
    params.permit(:title, :overview, :release_date, :inventory, :image_url, :external_id)
  end
end
