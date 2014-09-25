<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>


<style>
#line_chart {
	/* margin-top: 200px;
	  margin-left: 100px; */
	
}
</style>

<script>
	$(function() {
		load_time();
	});

	var load_time = function() {
		var date1 = new Date('2014/09/18');
		var date2 = new Date('2014/09/19');
		//alert(date.getTime());
		
		$.ajax({
			url : 'http://localhost:9200/cardcdrs/_search?pretty=true',
			type : 'POST',
			data : JSON.stringify({
				"query" : {
					"match_all" : {}
				},
				"facets" : {
					"published" : {
						"date_histogram" : {
							"field" : "timestamp",
							"interval" : "0.1h"
						}
					}

				}
				/* ,
				"query" : {
					"term" : {
						"status" : "00"
					}
				} */
				,
				"query": {
		            "range" : {
		                "timestamp" : {
		                    "gte": date1.getTime(),
		                    "lte": date2.getTime()
		                }
		            }
		        }
			}),
			dataType : 'json',
			processData : false,
			success : function(json, statusText, xhr) {
				//alert(json);
				return draw(json.facets.published.entries);
			},
			error : function(xhr, message, error) {
				console.error("Error while loading data from ElasticSearch",
						message);
				throw (error);
			}
		});
	};
</script>

<script>
	function draw(json){
		//alert(json[0].count);
		var chart;

		nv.addGraph(function() {
			chart = nv.models.lineChart().options({
				margin : {
					left : 100,
					bottom : 100
				},
				x : function(d, i) {
					return i
				},
				showXAxis : true,
				showYAxis : true,
				transitionDuration : 250
			});

			// chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
			chart.xAxis.axisLabel("Thời gian (ngày)").tickFormat(d3.format(',.1f'));

			chart.yAxis.axisLabel('Số lượng').tickFormat(d3.format(',.2f'));

			//var format = d3.time.format("%Y-%m-%d %H:%m:%s"); 
			chart.xAxis.tickFormat(function (d) {
				var date = new Date(json[d].time);
				
				//return [date.getDate(), date.getMonth()+1].join('/');
				return [date.getDate(), date.getMonth()+1].join('/') +" " + [date.getHours(), date.getMinutes()].join(':');
			});
			
			d3.select('#line_chart svg').datum(generateLineCoordinates()).call(chart);

			
			//TODO: Figure out a good way to do this automatically
			nv.utils.windowResize(chart.update);
			//nv.utils.windowResize(function() { d3.select('#chart1 svg').call(chart) });

			chart.dispatch.on('stateChange', function(e) {
				nv.log('New State:', JSON.stringify(e));
			});

			return chart;
		});
		
		function generateLineCoordinates(){
			//alert(json[0].time);
			var line00 = [];
			for (var i = 0; i < json.length; i++) {
				line00.push({
					x : i,
					y : json[i].count
				}); 
				
			}
			
			return [ {
				
				values : line00,
				key : "Trạng thái 00",
				color : "#ff7f0e"
			}];
		}
		//
		function sinAndCos() {
			var sin = [], cos = [], rand = [], rand2 = [];

			for (var i = 0; i < 100; i++) {
				sin.push({
					x : i,
					y : i % 10 == 5 ? null : Math.sin(i / 10)
				}); 
			}

			return [ {
				//area : true,
				values : sin,
				key : "Sine Wave",
				color : "#ff7f0e"
			}];
		}
	}
	
	function drawLine(json) {
		//alert(json);

		// Wrapping in nv.addGraph allows for '0 timeout render', stores rendered charts in nv.graphs, and may do more in the future... it's NOT required
		var chart;

		nv.addGraph(function() {
			chart = nv.models.lineChart().options({
				margin : {
					left : 100,
					bottom : 100
				},
				x : function(d, i) {
					return i
				},
				showXAxis : true,
				showYAxis : true,
				transitionDuration : 250
			});

			// chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
			chart.xAxis.axisLabel("Time (s)").tickFormat(d3.format(',.1f'));

			chart.yAxis.axisLabel('Voltage (v)').tickFormat(d3.format(',.2f'));

			d3.select('#line_chart svg').datum(sinAndCos()).call(chart);

			//TODO: Figure out a good way to do this automatically
			nv.utils.windowResize(chart.update);
			//nv.utils.windowResize(function() { d3.select('#chart1 svg').call(chart) });

			chart.dispatch.on('stateChange', function(e) {
				nv.log('New State:', JSON.stringify(e));
			});

			return chart;
		});

		function sinAndCos() {
			var sin = [], cos = [], rand = [], rand2 = [];

			for (var i = 0; i < 100; i++) {
				sin.push({
					x : i,
					y : i % 10 == 5 ? null : Math.sin(i / 10)
				}); //the nulls are to show how defined works
				cos.push({
					x : i,
					y : .5 * Math.cos(i / 10)
				});
				rand.push({
					x : i,
					y : Math.random() / 10
				});
				rand2.push({
					x : i,
					y : Math.cos(i / 10) + Math.random() / 10
				})
			}

			return [ {
				area : true,
				values : sin,
				key : "Sine Wave",
				color : "#ff7f0e"
			}, {
				values : cos,
				key : "Cosine Wave",
				color : "#2ca02c"
			}, {
				values : rand,
				key : "Random Points",
				color : "#2222ff"
			}, {
				values : rand2,
				key : "Random Cosine",
				color : "#667711"
			} ];
		}
	}
</script>