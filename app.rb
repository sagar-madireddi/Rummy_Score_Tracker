require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions
set :bind, '0.0.0.0'
set :public_folder, File.join(__dir__, 'public')
# Route to accept number of players
post '/player_count' do
  session[:player_count] = params[:player_count]
  redirect '/setup'
end

# Route to handle actual player name submission (already exists)
post '/setup' do
  session[:players] = params[:players].reject(&:empty?)
  session[:scores] = []
  session[:player_count] = nil
  redirect '/'
end
# Player setup screen
get '/setup' do
  erb :setup
end

post '/setup' do
  session[:players] = params[:players].reject(&:empty?)
  session[:scores] = []
  redirect '/'
end

# Home page (score input)
get '/' do
  redirect '/setup' unless session[:players]&.any?
  erb :index
end

# Round submission
post '/round' do
  round_scores = params[:scores].transform_values(&:to_i)
  dealer = session[:players][session[:scores].size % session[:players].size]
  session[:scores] << { dealer: dealer, scores: round_scores }

  redirect '/'
end

# Results page
get '/results' do
  players = session[:players]
  totals = Hash.new(0)
  payments = Hash.new { |h, k| h[k] = Hash.new(0) }

  session[:scores].each do |round|
    scores = round[:scores]
    winner = scores.key(0)

    scores.each { |player, score| totals[player] += score }

    scores.each do |player, score|
      next if player == winner
      payments[player][winner] += score
    end
  end

  erb :results, locals: { totals: totals, payments: payments }
end

# Reset scores only
post '/reset' do
  session[:scores] = []
  redirect '/'
end

# Restart game entirely
post '/restart' do
  session.clear
  redirect '/setup'
end
