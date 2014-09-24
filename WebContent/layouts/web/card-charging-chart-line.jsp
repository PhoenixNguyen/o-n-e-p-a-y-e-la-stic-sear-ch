<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>


<style>
	#line_chart {
	  /* margin-top: 200px;
	  margin-left: 100px; */
	}
</style>

<script>
  /* $( function() { load_data(); });

  var load_data = function() {
    $.ajax({   url: 'http://localhost:9200/cardcdrs/_search?pretty=true'
             , type: 'POST'
             , data :
                JSON.stringify(
                {
                  "query" : { "match_all" : {} },

                  "facets" : {
                    "tags" : {
                      "terms" : {
                          "field" : "status",
                          "size"  : "1000"
                      }
                    }
                  }
                })
             , dataType : 'json'
             , processData: false
             , success: function(json, statusText, xhr) {
          	   //drawPie(json);
                 return drawPie(json.facets.tags.terms);
               }
             , error: function(xhr, message, error) {
                 console.error("Error while loading data from ElasticSearch", message);
                 throw(error);
               }          
    });
  }; */
</script>

<script>
	// Wrapping in nv.addGraph allows for '0 timeout render', stores rendered charts in nv.graphs, and may do more in the future... it's NOT required
	var chart;
	
	nv.addGraph(function() {
	  chart = nv.models.lineChart()
	  .options({
	    margin: {left: 100, bottom: 100},
	    x: function(d,i) { return i},
	    showXAxis: true,
	    showYAxis: true,
	    transitionDuration: 250
	  })
	  ;
	
	  // chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
	  chart.xAxis
	    .axisLabel("Time (s)")
	    .tickFormat(d3.format(',.1f'));
	
	  chart.yAxis
	    .axisLabel('Voltage (v)')
	    .tickFormat(d3.format(',.2f'))
	    ;
	
	  d3.select('#line_chart svg')
	    .datum(sinAndCos())
	    .call(chart);
	
	  //TODO: Figure out a good way to do this automatically
	  nv.utils.windowResize(chart.update);
	  //nv.utils.windowResize(function() { d3.select('#chart1 svg').call(chart) });
	
	  chart.dispatch.on('stateChange', function(e) { nv.log('New State:', JSON.stringify(e)); });
	
	  return chart;
	});
	
	function sinAndCos() {
	  var sin = [],
	    cos = [],
	    rand = [],
	    rand2 = []
	    ;
	
	  for (var i = 0; i < 100; i++) {
	    sin.push({x: i, y: i % 10 == 5 ? null : Math.sin(i/10) }); //the nulls are to show how defined works
	    cos.push({x: i, y: .5 * Math.cos(i/10)});
	    rand.push({x:i, y: Math.random() / 10});
	    rand2.push({x: i, y: Math.cos(i/10) + Math.random() / 10 })
	  }
	
	  return [
	    {
	      area: true,
	      values: sin,
	      key: "Sine Wave",
	      color: "#ff7f0e"
	    },
	    {
	      values: cos,
	      key: "Cosine Wave",
	      color: "#2ca02c"
	    },
	    {
	      values: rand,
	      key: "Random Points",
	      color: "#2222ff"
	    }
	    ,
	    {
	      values: rand2,
	      key: "Random Cosine",
	      color: "#667711"
	    }
	  ];
	}
	
	</script>