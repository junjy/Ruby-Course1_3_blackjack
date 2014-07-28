require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

#define helpers
helpers do 

  def draw_card(carddeck, playerhand)
    randid = rand(carddeck.length)
    tempcard = carddeck[randid]
    playerhand.push(tempcard)
    carddeck.delete_at(randid)
  end

  def initial_deal(carddeck, playerhand, dealerhand)  
    2.times do
      draw_card(carddeck, playerhand)
      draw_card(carddeck, dealerhand)
    end
  end

  def check_blackjack(playerhand)
    blackjack_hits = [['10', 'A'],['A', 'J'], ['A', 'Q'], ['A', 'K']] 
    cardsonly = []

    playerhand.each do |suit, rank|
      cardsonly.push(rank)
    end

    blackjack_hits.each do |set|
      return true if cardsonly.sort == set 
    end #note: cannot sort array of Fixnum & String, so convert cards to String.
    false
  end

  def dealer_hits(carddeck, dealerhand)
    dealertotal = check_score(dealerhand)
    if dealertotal >= 17
      "Dealer stays."
    else     
      draw_card(carddeck, dealerhand)
      dealer_hits(carddeck, dealerhand)            
    end
  end

  def display_cardimage(card) #from solution

    suit = case card[0]
      when 'C' then 'clubs'
      when 'D' then 'diamonds'
      when 'H' then 'hearts'
      when 'S' then 'spades'
    end

    if card[1].to_i == 0
      score = case card[1]
        when 'A' then 'ace'
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
      end
    else #2..10
      score = card[1].to_i
    end

    "<img src='/images/cards/#{suit}_#{score}.jpg' class='img-polaroid'>"
  end

  def check_score(playerhand)
    playertotal = 0
    numAces = playerhand.count { |suit, card| card == 'A'}

    playerhand.each do |suit, card|
      if card == 'A'
        playertotal += 1 #Ace
      elsif card == 'J' || card == 'Q' || card == 'K'
        playertotal += 10 #Jack, Queen, King
      else 
        playertotal += card.to_i #2..10 convert to integer
      end
    end

    #correct for aces
    if numAces >= 1 && (playertotal + 10) <= 21
      playertotal += 10    
    end
    playertotal
  end

end
#End of helpers

get '/' do
  redirect '/start_game' 
end

get '/start_game' do
  erb :start_game
end

post '/start_game' do
  if params[:username].empty? #from solution
    @error = "Please enter your name to proceed."
    halt erb(:start_game)
  elsif params[:username].to_i != 0
    @error = "Please enter a valid name."
    halt erb(:start_game)
  end

  session[:player_name] = params[:username]
  suits = ['C', 'D', 'H', 'S']
  ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
  session[:carddeck] = suits.product(ranks)
  session[:dealer_hand] = []
  session[:player_hand] = []
  session[:player_cash] = 500
  redirect '/set_bet'
end

get '/set_bet' do
  erb :set_bet
end

post '/set_bet' do
  if params[:user_bet].to_i > session[:player_cash]
    @error = "You have insufficient funds. Please enter a lower bet amount."
    halt erb(:set_bet)
  elsif params[:user_bet].empty?
    @error = "Please enter a bet amount to proceed."
    halt erb(:set_bet)
  end
  session[:player_bet] = params[:user_bet].to_i
  redirect '/game'
end

get '/game' do
  erb :game
end

post '/game' do
  @choice1 = params[:hit_or_stay].to_s

  if @choice1 == "Hit"
    redirect '/player_hit'
  else 
    redirect '/dealer_turn'
  end

  @choice2 = params[:cont_or_stop].to_s
  if @choice2 == "Continue"
    suits = ['C', 'D', 'H', 'S']
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
   session[:carddeck] = suits.product(ranks)
    session[:dealer_hand] = []
    session[:player_hand] = []
    session[:player_bet] = 0
    redirect '/set_bet'
  else 
    redirect '/end_game'
  end

end

get '/player_hit' do
  erb :player_hit
end

get '/dealer_turn' do
  erb :dealer_turn
end

post '/dealer_turn' do
  @choice2 = params[:cont_or_stop].to_s
  if @choice2 == "Continue"
    suits = ['C', 'D', 'H', 'S']
    ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    session[:carddeck] = suits.product(ranks)
    session[:dealer_hand] = []
    session[:player_hand] = []  
    session[:player_bet] = 0
    redirect '/set_bet'
  else 
    redirect '/end_game'
  end
end

get '/end_game' do
  erb :end_game
end
