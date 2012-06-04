dir = File.join(File.dirname(__FILE__), '.')
$: << File.expand_path(dir)
$: << File.expand_path("#{dir}/../lib")

require 'epsilon-greedy'
require 'csv'

chooser = EpsilonGreedy::Chooser.new('test.store')

require 'sinatra'
enable :sessions

get '/test' do
  redirect to('/test/' + chooser.choose.to_s)
end

get '/test/dogs' do
  session[:flow] = 'dogs'
  session[:abandonment_percentage] = 15
  redirect to('/test/choose')
end

get '/test/cats' do
  session[:flow] = 'cats'
  session[:abandonment_percentage] = 25
  redirect to('/test/choose')
end

get '/test/fish' do
  session[:flow] = 'fish'
  session[:abandonment_percentage] = 50
  redirect to('/test/choose')
end

get '/test/zebra' do
  session[:flow] = 'zebra'
  session[:abandonment_percentage] = 75
  redirect to('/test/choose')
end

get '/test/gazelles' do
  #stop server, uncomment this and restart to add new form into the mix
  redirect to('/test/startover')

  session[:flow] = 'gazelles'
  session[:abandonment_percentage] = 2
  redirect to('/test/choose')
end

get '/test/choose' do
  if (rand(100) + 1) <= session[:abandonment_percentage]
    redirect to 'test/abandoned'
  else
    chooser.increment_wins session[:flow].to_sym
  end
  redirect to("/test/startover")
end

get '/test/abandoned' do
  "User #{session[:user]} did not complete"
  redirect to("/test/startover")
end

get '/test/startover' do
'<html>
<head>
<title>startover</title>
<meta HTTP-EQUIV="Refresh" CONTENT="0.1;URL=/test">
</head>
<body></body>
</html>'
end


get '/test/stats' do

  f = CSV.read(File.dirname(__FILE__) + '/../output.csv')

  output = f.each_with_index {|e, i| e.unshift(i).map!(&:to_i)}
  output.unshift ["Cycle", 'Dogs', "Cats", "Fish", "Zebra"]

  logger.info output

  html  = <<-EOF
  <html>
    <head>
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>
      <script type="text/javascript">
        google.load("visualization", "1", {packages:["corechart"]});
        google.setOnLoadCallback(drawChart);
        function drawChart() {
          var data = google.visualization.arrayToDataTable(
            #{output.inspect}
          );

          var options = {
            title: 'Reward Distribution'
          };

          var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
          chart.draw(data, options);
        }
      </script>
    </head>
    <body>
      <div id="chart_div" style="width: 900px; height: 500px;"></div>
    </body>
  </html>
  EOF


  html


end
