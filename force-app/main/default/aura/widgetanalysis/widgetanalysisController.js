({
    chartJSLoaded : function(component, event, helper) {
        var ctx = component.find("chart").getElement();
        var myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Dog Feeder", "Headset", "Toothbrush"],
                datasets: [{
                    label: '# of Units Sold',
                    data: [40, 5, 20],
                    backgroundColor: [
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(54, 162, 235, 0.2)'
                    ],
                    borderColor: [
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(54, 162, 235, 0.2)',
                        'rgba(54, 162, 235, 0.2)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    yAxes: [{
                        ticks: {
                            beginAtZero:true
                        }
                    }]
                }
            }
        });        
    }
})
