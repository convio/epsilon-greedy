dir = File.join(File.dirname(__FILE__), '.')
$: << File.expand_path(dir)
$: << File.expand_path("#{dir}/../lib")

require 'epsilon-greedy'
require 'csv'

chooser = EpsilonGreedy::Chooser.new('test.yaml')

require 'sinatra'
enable :sessions


# Define your forms here with completion percentage
FORMS = {
    'dogs' => 85,
    'cats' => 75,
    'fish' => 50,
    'zebra' => 25,
}

# send request here. This will pick a random form using the chooser
get '/test' do
  redirect to('/test/pick/' + chooser.choose.to_s)
end


# got a form, select the abandonment percentage and
# redirect to the 'user'
get '/test/pick/:form_name' do  |form_name|
  logger.info form_name
  if FORMS[form_name]
    session[:flow] = form_name
    session[:abandonment_percentage] = 100-FORMS[form_name]
    redirect to('/test/user_populates_form')
  else
    redirect to('/404')
  end
end

# populate the form as a user and abandon based on the configured percentages
get '/test/user_populates_form' do
  if (rand(100) + 1) <= session[:abandonment_percentage]
    redirect to 'test/abandoned'
  else
    chooser.increment_wins session[:flow].to_sym
  end
  sleep 0.05
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
  if (FORMS.size + 1) > output.first.size # we've added a form into the mix
    output.each_index do |i|
      (FORMS.size + 1 - output[i].size).times {output[i].push 0}
    end
  end
  output.unshift ["Cycle"] + FORMS.keys

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
