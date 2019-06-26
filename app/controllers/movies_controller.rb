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
    if Movie.does_movie_exist(movie_params[:title])
      render json: {errors: "movie already exists in library"},
        status: :bad_request
      return false
    end
    # Rails has set up that everything that comes in from a request as query params... gets into the params object
    @movie = Movie.new(movie_params)
    puts "we're in the create function ****************************************"
    puts params#["apples"]
    # How do we make sure that this new instance of movie has actually the values coming from the request ... Hm...(strong params!)
    # Traditionally, we have put this functionality of reading from the request and also some cool rails security things using Strong Params


    if @movie.save
      render json: {movie: {id: @movie.id, title: @movie.title}}, status: :ok
    else
      render json: {errors: @movie.errors.messages},
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
  return params.require(:movie).permit(:title, :overview, :release_date, :inventory) # :available_inventory ?
end

end
