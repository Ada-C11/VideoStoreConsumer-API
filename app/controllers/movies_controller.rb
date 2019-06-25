class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
<<<<<<< HEAD
      # check if "data" exists in database; if it doesn't, save it and check if database updated
=======
      if data != []
        data.each do |movie|
          if !Movie.find_by(title: movie.title)
            movie.save!
          end
        end
      end
>>>>>>> 12e3cc99d5b41b05bc179a8bc709b6237446c2e2
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

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
