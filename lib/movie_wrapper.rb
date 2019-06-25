
class MovieWrapper
  BASE_URL = "https://api.themoviedb.org/3/"
  KEY = ENV["MOVIEDB_KEY"]

  BASE_IMG_URL = "https://image.tmdb.org/t/p/"
  DEFAULT_IMG_SIZE = "w185"
  DEFAULT_IMG_URL = "http://lorempixel.com/185/278/"

  def self.search(query)
    url = BASE_URL + "search/movie?api_key=" + KEY + "&query=" + query
    response = HTTParty.get(url)
    if response["total_results"] == 0
      return []
    elsif response["results"]
      movies = response["results"].map do |result|
        self.construct_movie(result)
      end
      return movies
    end
  end

  private

  def self.construct_movie(api_result)
    movie = Movie.new(
      title: api_result["title"],
      overview: api_result["overview"],
      release_date: api_result["release_date"],
      image_url: self.construct_image_url(api_result["poster_path"]), #(api_result["poster_path"] ? self.construct_image_url(api_result["poster_path"]) : nil),
      external_id: api_result["id"],
    )
    movie = movie.attributes
    movie[:in_library] = Movie.find_by(external_id: api_result["id"]).is_a?(Movie)
    return movie
  end

  def self.construct_image_url(img_name)
    !img_name ?
      DEFAULT_IMG_URL :
      BASE_IMG_URL + DEFAULT_IMG_SIZE + img_name
  end
end
