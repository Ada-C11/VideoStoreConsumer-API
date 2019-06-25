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
    # This should not create another duplicate record for the given movie, 
    # we should check if the movie's external id exists in our database
    # if it doesn't, we 'create' (add) the movie to our library
    # otherwise we deny the request OR we just increment inventory?
    errors = {}

    @movie = Movie.create(movie_params) 

    if @movie 
      json_response(@movie, :created)
    else
      errors['message'] = ["Invalid parameters given: #{movie_params}"]
      render status: :bad_request, json: { errors: errors}
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
