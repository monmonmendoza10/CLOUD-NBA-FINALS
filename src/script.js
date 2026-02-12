// NBA Teams Data
const nbaTeams = {
    east: [
        { name: 'Boston Celtics', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Miami Heat', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Philadelphia 76ers', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'New York Knicks', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Toronto Raptors', wins: 0, losses: 0, threePct: 0, defRating: 0 },
    ],
    west: [
        { name: 'Denver Nuggets', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Los Angeles Lakers', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Golden State Warriors', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Phoenix Suns', wins: 0, losses: 0, threePct: 0, defRating: 0 },
        { name: 'Dallas Mavericks', wins: 0, losses: 0, threePct: 0, defRating: 0 },
    ]
};

// Prediction History
let predictionHistory = [];

// Initialize the page
document.addEventListener('DOMContentLoaded', function() {
    populateTeamSelect();
    loadStandings();
    loadPredictions();
    setupFormListener();
});

// Populate team dropdown
function populateTeamSelect() {
    const select = document.getElementById('team-select');
    const allTeams = [...nbaTeams.east, ...nbaTeams.west];
    
    allTeams.forEach(team => {
        const option = document.createElement('option');
        option.value = team.name;
        option.textContent = team.name;
        select.appendChild(option);
    });
}

// Load standings (mock data for demo)
function loadStandings() {
    const eastStandings = document.getElementById('east-standings');
    const westStandings = document.getElementById('west-standings');
    
    const eastData = [
        { rank: 1, team: 'Boston Celtics', w: 58, l: 24, winPct: 0.707, playoffOdds: 99.8 },
        { rank: 2, team: 'Miami Heat', w: 46, l: 36, winPct: 0.561, playoffOdds: 98.5 },
        { rank: 3, team: 'Philadelphia 76ers', w: 52, l: 30, winPct: 0.634, playoffOdds: 99.2 },
        { rank: 4, team: 'New York Knicks', w: 50, l: 32, winPct: 0.610, playoffOdds: 97.8 },
        { rank: 5, team: 'Toronto Raptors', w: 44, l: 38, winPct: 0.537, playoffOdds: 85.3 },
    ];
    
    const westData = [
        { rank: 1, team: 'Denver Nuggets', w: 56, l: 26, winPct: 0.683, playoffOdds: 99.9 },
        { rank: 2, team: 'Los Angeles Lakers', w: 54, l: 28, winPct: 0.659, playoffOdds: 99.7 },
        { rank: 3, team: 'Golden State Warriors', w: 51, l: 31, winPct: 0.622, playoffOdds: 98.9 },
        { rank: 4, team: 'Phoenix Suns', w: 49, l: 33, winPct: 0.598, playoffOdds: 96.4 },
        { rank: 5, team: 'Dallas Mavericks', w: 48, l: 34, winPct: 0.585, playoffOdds: 93.2 },
    ];
    
    // Populate tables
    eastData.forEach(data => {
        const row = createStandingsRow(data);
        eastStandings.appendChild(row);
    });
    
    westData.forEach(data => {
        const row = createStandingsRow(data);
        westStandings.appendChild(row);
    });
}

function createStandingsRow(data) {
    const row = document.createElement('tr');
    row.innerHTML = `
        <td>${data.rank}</td>
        <td>${data.team}</td>
        <td>${data.w}</td>
        <td>${data.l}</td>
        <td>${(data.winPct * 100).toFixed(1)}%</td>
        <td>${data.playoffOdds}%</td>
    `;
    return row;
}

// Setup form submission
function setupFormListener() {
    const form = document.getElementById('prediction-form');
    form.addEventListener('submit', handlePrediction);
}

// Handle prediction
async function handlePrediction(e) {
    e.preventDefault();
    
    const team = document.getElementById('team-select').value;
    const wins = parseInt(document.getElementById('wins').value);
    const losses = parseInt(document.getElementById('losses').value);
    const threePct = parseFloat(document.getElementById('three-point').value);
    const defRating = parseFloat(document.getElementById('def-rating').value);
    
    // Mock ML prediction (replace with actual Azure ML call)
    const prediction = makePrediction(wins, losses, threePct, defRating);
    
    // Display result
    showPredictionResult(team, prediction);
    
    // Save to history
    savePrediction(team, wins, losses, threePct, defRating, prediction);
    
    // Reload predictions list
    loadPredictions();
}

// Mock prediction function (will be replaced with Azure ML)
function makePrediction(wins, losses, threePct, defRating) {
    // Simple heuristic model for demo
    let score = 0;
    
    // Wins/Losses ratio
    const winRatio = wins / (wins + losses);
    score += winRatio * 40;
    
    // Three-point percentage (higher is better, typical NBA 3p% is ~35-37%)
    const threePointScore = Math.min(threePct / 37 * 30, 30);
    score += threePointScore;
    
    // Defensive Rating (lower is better, good teams ~110 or less)
    const defRatingScore = Math.max(0, (120 - defRating) / 10 * 30);
    score += defRatingScore;
    
    const confidence = Math.min(100, Math.max(0, score));
    const willMakePlayoffs = score > 50;
    
    return {
        willMakePlayoffs,
        confidence,
        score
    };
}

// Display prediction result
function showPredictionResult(team, prediction) {
    const resultDiv = document.getElementById('prediction-result');
    const resultText = document.getElementById('result-text');
    const confidenceBar = document.getElementById('confidence-bar');
    const confidenceText = document.getElementById('confidence-text');
    
    resultText.textContent = prediction.willMakePlayoffs 
        ? `✅ ${team} is LIKELY to make the playoffs!`
        : `❌ ${team} is UNLIKELY to make the playoffs.`;
    
    confidenceBar.style.width = prediction.confidence + '%';
    confidenceBar.textContent = `${prediction.confidence.toFixed(1)}%`;
    confidenceText.textContent = `Confidence: ${prediction.confidence.toFixed(1)}%`;
    
    resultDiv.classList.remove('hidden');
}

// Save prediction to history
function savePrediction(team, wins, losses, threePct, defRating, prediction) {
    const timestamp = new Date().toLocaleString();
    
    const predictionEntry = {
        team,
        wins,
        losses,
        threePct,
        defRating,
        result: prediction.willMakePlayoffs ? 'Playoff' : 'No Playoff',
        confidence: prediction.confidence.toFixed(1),
        timestamp
    };
    
    predictionHistory.unshift(predictionEntry);
    
    // Keep only last 10 predictions
    if (predictionHistory.length > 10) {
        predictionHistory.pop();
    }
    
    // Save to localStorage
    localStorage.setItem('nbaOraclePredictions', JSON.stringify(predictionHistory));
}

// Load predictions from history
function loadPredictions() {
    const savedPredictions = localStorage.getItem('nbaOraclePredictions');
    if (savedPredictions) {
        predictionHistory = JSON.parse(savedPredictions);
    }
    
    const predictionsList = document.getElementById('predictions-list');
    predictionsList.innerHTML = '';
    
    if (predictionHistory.length === 0) {
        predictionsList.innerHTML = '<p>No predictions yet. Make your first prediction!</p>';
        return;
    }
    
    predictionHistory.forEach(pred => {
        const card = document.createElement('div');
        card.className = 'prediction-card';
        card.innerHTML = `
            <h5>${pred.team}</h5>
            <p><strong>Record:</strong> ${pred.wins}W - ${pred.losses}L</p>
            <p><strong>3P%:</strong> ${pred.threePct}%</p>
            <p><strong>Def Rating:</strong> ${pred.defRating.toFixed(1)}</p>
            <p><strong>Prediction:</strong> ${pred.result}</p>
            <p><strong>Confidence:</strong> ${pred.confidence}%</p>
            <p style="color: #777; font-size: 0.8rem;">${pred.timestamp}</p>
        `;
        predictionsList.appendChild(card);
    });
}

// Mock function to call Azure ML (to be implemented)
async function callAzureML(inputData) {
    // This will be replaced with actual Azure ML endpoint
    // For now, return mock prediction
    return {
        prediction: inputData.wins > inputData.losses ? true : false,
        confidence: Math.random() * 100
    };
}
