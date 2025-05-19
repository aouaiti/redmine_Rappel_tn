/**
 * Enhanced Budget Chart Implementation
 */
class BudgetChart {
  // Define static colors array available to the views
  static COLORS = [
    '#5cb85c', // Green
    '#428bca', // Blue
    '#f0ad4e', // Orange
    '#d9534f', // Red
    '#5bc0de', // Light Blue
    '#9370db', // Medium Purple
    '#20b2aa', // Light Sea Green
    '#ff7f50', // Coral
    '#3cb371', // Medium Sea Green
    '#ba55d3'  // Medium Orchid
  ];
  
  constructor(ctx, data) {
    this.ctx = ctx;
    this.data = data;
    this.colors = BudgetChart.COLORS;
    
    // Get translations from data if provided, otherwise use defaults
    this.translations = {
      spent: data.translations && data.translations.spent ? data.translations.spent : 'Spent',
      remaining: data.translations && data.translations.remaining ? data.translations.remaining : 'Remaining'
    };
    
    this.drawChart();
  }

  getRandomColor() {
    // Random color generator
    return '#' + Math.floor(Math.random()*16777215).toString(16);
  }

  getProjectColor(index) {
    // Get a color from the palette or generate a random one if we run out
    return index < this.colors.length ? this.colors[index] : this.getRandomColor();
  }

  drawChart() {
    // If we have access to Chart.js
    if (typeof Chart !== 'undefined') {
      this.drawChartJS();
    } else {
      // Fallback to simple canvas rendering if Chart.js is not available
      this.drawFallbackChart();
    }
  }

  drawChartJS() {
    let chartData = {};
    let chartOptions = {};
    
    if (this.data.projects) {
      // Multi-project pie chart
      const labels = [];
      const values = [];
      const backgroundColors = [];
      
      this.data.projects.forEach((project, index) => {
        labels.push(project.name);
        values.push(project.amount);
        backgroundColors.push(this.getProjectColor(index));
      });
      
      chartData = {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: backgroundColors,
          borderWidth: 1
        }]
      };
      
      chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        legend: {
          position: 'right',
          labels: {
            boxWidth: 20,
            fontSize: 12
          }
        },
        tooltips: {
          callbacks: {
            label: (tooltipItem, data) => {
              const dataset = data.datasets[tooltipItem.datasetIndex];
              const total = dataset.data.reduce((acc, val) => acc + val, 0);
              const currentValue = dataset.data[tooltipItem.index];
              const percentage = Math.round(currentValue / total * 100);
              
              return `${data.labels[tooltipItem.index]}: ${currentValue} (${percentage}%)`;
            }
          }
        }
      };
    } else {
      // Simple spent/remaining chart
      chartData = {
        labels: [this.translations.spent, this.translations.remaining],
        datasets: [{
          data: [this.data.spent, Math.max(0, this.data.remaining)],
          backgroundColor: [
            this.data.remaining < 0 ? '#d9534f' : '#5cb85c', 
            '#428bca'
          ],
          borderWidth: 1
        }]
      };
      
      chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        legend: {
          position: 'bottom',
          labels: {
            boxWidth: 20,
            fontSize: 12
          }
        },
        tooltips: {
          callbacks: {
            label: (tooltipItem, data) => {
              const dataset = data.datasets[tooltipItem.datasetIndex];
              const total = dataset.data.reduce((acc, val) => acc + val, 0);
              const currentValue = dataset.data[tooltipItem.index];
              const percentage = Math.round(currentValue / total * 100);
              
              return `${data.labels[tooltipItem.index]}: ${currentValue} (${percentage}%)`;
            }
          }
        }
      };
    }
    
    new Chart(this.ctx, {
      type: 'pie',
      data: chartData,
      options: chartOptions
    });
  }

  drawFallbackChart() {
    const ctx = this.ctx;
    const centerX = ctx.canvas.width / 2;
    const centerY = ctx.canvas.height / 2;
    const radius = Math.min(centerX, centerY) - 20;
    
    // Clear canvas
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
    
    if (this.data.projects) {
      // Multi-project pie chart
      let startAngle = 0;
      let legendY = centerY - radius - 10;
      const total = this.data.projects.reduce((acc, project) => acc + project.amount, 0);
      
      this.data.projects.forEach((project, index) => {
        const sliceAngle = (project.amount / total) * 2 * Math.PI;
        const endAngle = startAngle + sliceAngle;
        const color = this.getProjectColor(index);
        
        // Draw pie slice
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.moveTo(centerX, centerY);
        ctx.arc(centerX, centerY, radius, startAngle, endAngle);
        ctx.closePath();
        ctx.fill();
        
        // Draw legend
        if (index < 5) { // Limit the number of legend items to avoid clutter
          ctx.fillStyle = color;
          ctx.fillRect(centerX - 70, legendY + (index * 20), 10, 10);
          ctx.fillStyle = '#333';
          ctx.font = '12px Arial';
          ctx.fillText(`${project.name} (${Math.round(project.amount / total * 100)}%)`, 
                      centerX - 55, legendY + (index * 20) + 10);
        }
        
        startAngle = endAngle;
      });
      
      if (this.data.projects.length > 5) {
        ctx.fillStyle = '#333';
        ctx.font = '12px Arial';
        ctx.fillText(`+ ${this.data.projects.length - 5} more...`, centerX - 55, legendY + 120);
      }
    } else {
      // Simple spent/remaining chart
      const total = this.data.total || (this.data.spent + Math.max(0, this.data.remaining));
      const spentPercentage = total ? this.data.spent / total : 0;
      
      // Spent part (green or red if overspent)
      ctx.fillStyle = this.data.remaining < 0 ? '#d9534f' : '#5cb85c';
      ctx.beginPath();
      ctx.moveTo(centerX, centerY);
      ctx.arc(centerX, centerY, radius, 0, spentPercentage * 2 * Math.PI);
      ctx.closePath();
      ctx.fill();
      
      // Remaining part
      ctx.fillStyle = '#428bca';
      ctx.beginPath();
      ctx.moveTo(centerX, centerY);
      ctx.arc(centerX, centerY, radius, spentPercentage * 2 * Math.PI, 2 * Math.PI);
      ctx.closePath();
      ctx.fill();
      
      // Draw legend
      ctx.font = '12px Arial';
      
      // Spent legend
      ctx.fillStyle = this.data.remaining < 0 ? '#d9534f' : '#5cb85c';
      ctx.fillRect(centerX - 70, centerY + radius + 15, 10, 10);
      ctx.fillStyle = '#333';
      ctx.fillText(`${this.translations.spent} (${Math.round(spentPercentage * 100)}%)`, 
                  centerX - 55, centerY + radius + 25);
      
      // Remaining legend
      ctx.fillStyle = '#428bca';
      ctx.fillRect(centerX - 70, centerY + radius + 35, 10, 10);
      ctx.fillStyle = '#333';
      ctx.fillText(`${this.translations.remaining} (${Math.round((1 - spentPercentage) * 100)}%)`, 
                  centerX - 55, centerY + radius + 45);
    }
  }
}

// Make sure it's available globally
window.BudgetChart = BudgetChart; 