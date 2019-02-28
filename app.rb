require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

enable :sessions

db = SQLite3::Database.new('db/database.db')
db.results_as_hash = true

get('/') do
    slim(:index)
end

get('/register') do
    slim(:reg)
end

post('/create') do
    name = params["name"]
    email = params["email"]
    password = BCrypt::Password.create(params["pass"])
    db.execute('INSERT INTO users(Name, Email, Password) VALUES(?, ?, ?)', name, email, password) 
    redirect('/')
end

post('/login') do
    result = db.execute("SELECT Password FROM users WHERE Name =(?)", params["name"])
    if result[0] == nil
        redirect('/lolno')
    end
    not_password = result[0]["Password"]
    if BCrypt::Password.new(not_password) == params["pass"]
        session[:loggedin] = true
        session[:user] = params["name"]
        redirect('/')
    else
        redirect('/lolno')
    end
end

post('/logout') do
    session.destroy
    redirect('/')
end