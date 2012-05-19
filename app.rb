require 'sinatra'
set server: 'thin', connections: []

get '/' do
  @user = params[:user]
  unless @user
    erb :login, :layout => :index
  else
    erb :chat,  :layout => :index
  end
end

get '/chat', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    out.callback { settings.connections.delete(out) }
  end
end

post '/' do
  settings.connections.each { |out| out << "data: #{params[:message]}\n\n" }
  204
end

__END__

@@ index
<!DOCTYPE html>
<html>
  <head> 
    <meta charset="utf-8" />
    <title>Sinatra Simplest Chat</title> 
    <link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css" />
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
  </head> 
  <body>
    <div class="container">
      <header>
        <h1>Sinatra.Chat</h1>
      </header>
      <%= yield %>
      <footer>
        &copy; 2012 <a href="http://mrak7.com">DESIGN4UNDERGROUND</a> | <a href="http://aomega.ru">AOmega</a>
      </footer>
    </div>
  </body>
</html>

@@ login
<section id="login">
  <form action="/" method="GET" class="form-horizontal">
    <label for="name">User Name:&nbsp;</label><input id="name" name="user" placeholder="your login" />
    <input type="submit" value="Enter" />
  </form>
</section>

@@ chat
<section id="chat">
  <div id="messages"></div>
  <hr/>
  <form>
    <input id="message" name="message" placeholder="your message..." />
    <input type="submit" value="Send" />
  </form>

  <script type="text/javascript">
    $(function(){
      var stream = new EventSource("/chat");
      stream.onmessage = function(e) {
        console.log( 'Fuck: '+e.data );
        $('#messages').append(e.data + "<br/>")
      };
      $("form").live("submit", function(e) {
        var message = $('#message');
        $.post('/', {message: "<%= @user %>: "+message.val()});
        message.val('');
        message.focus();
        e.preventDefault();
        return false;
      });
    });
  </script>
</section>