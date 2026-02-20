// NBA Playoff Predictor Instance
let predictor = null;

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
document.addEventListener('DOMContentLoaded', async function() {
    console.log('🏀 Initializing NBA Oracle...');
    await initializePredictor();
    populateTeamSelect();
    loadStandings();
    loadPredictions();
    setupFormListener();
});

// Initialize the predictor with CSV data
async function initializePredictor() {
    try {
        predictor = new NBAPlayoffPredictor();
        
        // Load CSV data
        const response = await fetch('./ml/fixed_regular_season_data.csv');
        const csvText = await response.text();
        
        // Load and train
        predictor.loadCSVData(csvText);
        predictor.trainModel();
        
        console.log('✅ Predictor initialized and trained!');
        document.getElementById('status-indicator').textContent = '✅ Ready';
        document.getElementById('status-indicator').style.color = '#4CAF50';
        
        // Update model status in form
        const statusEmoji = document.getElementById('model-status-emoji');
        if (statusEmoji) {
            statusEmoji.textContent = '✅';
        }
        const statusMsg = document.querySelector('[id="model-status-emoji"]').parentElement;
        if (statusMsg) {
            statusMsg.innerHTML = '✅ ML Model Ready | Using ' + predictor.trainingData.length + ' training samples';
            statusMsg.style.color = '#4CAF50';
        }
    } catch (error) {
        console.warn('⚠️ Could not load CSV data, using heuristic predictions:', error);
        document.getElementById('status-indicator').textContent = '⚠️ Heuristic Mode';
        document.getElementById('status-indicator').style.color = '#FF9800';
        
        // Update model status in form
        const statusEmoji = document.getElementById('model-status-emoji');
        if (statusEmoji) {
            statusEmoji.textContent = '📊';
        }
        const statusMsg = document.querySelector('[id="model-status-emoji"]').parentElement;
        if (statusMsg) {
            statusMsg.innerHTML = '📊 Using Heuristic Predictions (CSV not available)';
            statusMsg.style.color = '#FF9800';
        }
    }
}

// Populate team dropdown with all 30 NBA teams
function populateTeamSelect() {
    const select = document.getElementById('team-select');
    
    const allTeams = [
        // Eastern Conference
        'Atlanta Hawks',
        'Boston Celtics',
        'Brooklyn Nets',
        'Charlotte Hornets',
        'Chicago Bulls',
        'Cleveland Cavaliers',
        'Detroit Pistons',
        'Indiana Pacers',
        'Miami Heat',
        'Milwaukee Bucks',
        'New York Knicks',
        'Orlando Magic',
        'Philadelphia 76ers',
        'Toronto Raptors',
        'Washington Wizards',
        // Western Conference
        'Dallas Mavericks',
        'Denver Nuggets',
        'Golden State Warriors',
        'Houston Rockets',
        'LA Clippers',
        'Los Angeles Lakers',
        'Memphis Grizzlies',
        'Minnesota Timberwolves',
        'New Orleans Pelicans',
        'Oklahoma City Thunder',
        'Phoenix Suns',
        'Portland Trail Blazers',
        'Sacramento Kings',
        'San Antonio Spurs',
        'Utah Jazz',
    ];
    
    allTeams.forEach(team => {
        const option = document.createElement('option');
        option.value = team;
        option.textContent = team;
        select.appendChild(option);
    });
}

// Load standings from CSV data or use default
async function loadStandings() {
    const eastStandings = document.getElementById('east-standings');
    const westStandings = document.getElementById('west-standings');
    
    // Define all 30 NBA teams with conferences
    const allTeams = {
        east: [
            { name: 'Boston Celtics', w: 64, l: 18, playoff: 1 },
            { name: 'New York Knicks', w: 50, l: 32, playoff: 1 },
            { name: 'Milwaukee Bucks', w: 58, l: 24, playoff: 1 },
            { name: 'Philadelphia 76ers', w: 49, l: 23, playoff: 1 },
            { name: 'Brooklyn Nets', w: 48, l: 24, playoff: 1 },
            { name: 'Miami Heat', w: 53, l: 29, playoff: 1 },
            { name: 'Toronto Raptors', w: 59, l: 23, playoff: 1 },
            { name: 'Cleveland Cavaliers', w: 57, l: 25, playoff: 1 },
            { name: 'Washington Wizards', w: 35, l: 47, playoff: 0 },
            { name: 'Chicago Bulls', w: 41, l: 41, playoff: 0 },
            { name: 'Indiana Pacers', w: 56, l: 26, playoff: 1 },
            { name: 'Atlanta Hawks', w: 60, l: 22, playoff: 1 },
            { name: 'Charlotte Hornets', w: 43, l: 39, playoff: 1 },
            { name: 'Orlando Magic', w: 47, l: 35, playoff: 1 },
            { name: 'Detroit Pistons', w: 17, l: 65, playoff: 0 },
        ],
        west: [
            { name: 'Denver Nuggets', w: 57, l: 25, playoff: 1 },
            { name: 'Los Angeles Lakers', w: 52, l: 19, playoff: 1 },
            { name: 'LA Clippers', w: 47, l: 25, playoff: 1 },
            { name: 'Utah Jazz', w: 52, l: 20, playoff: 1 },
            { name: 'Phoenix Suns', w: 64, l: 18, playoff: 1 },
            { name: 'Houston Rockets', w: 65, l: 17, playoff: 1 },
            { name: 'Golden State Warriors', w: 67, l: 15, playoff: 1 },
            { name: 'Memphis Grizzlies', w: 56, l: 26, playoff: 1 },
            { name: 'Dallas Mavericks', w: 52, l: 30, playoff: 1 },
            { name: 'Portland Trail Blazers', w: 53, l: 29, playoff: 1 },
            { name: 'Oklahoma City Thunder', w: 57, l: 25, playoff: 1 },
            { name: 'New Orleans Pelicans', w: 36, l: 46, playoff: 0 },
            { name: 'San Antonio Spurs', w: 22, l: 60, playoff: 0 },
            { name: 'Sacramento Kings', w: 30, l: 52, playoff: 0 },
            { name: 'Minnesota Timberwolves', w: 47, l: 35, playoff: 1 },
        ]
    };
    
    // Sort by wins (descending)
    const sortTeams = (teams) => {
        return teams.sort((a, b) => {
            if (b.w - a.w !== 0) return b.w - a.w;
            return b.playoff - a.playoff;
        });
    };
    
    // Calculate win percentage and playoff odds
    const calcPlayoffOdds = (w, l, playoff) => {
        const winPct = w / (w + l);
        if (playoff === 1) {
            return Math.min(99.9, 50 + (winPct * 50));
        } else {
            return Math.max(0.1, (winPct * 50) - 10);
        }
    };
    
    // Sort teams
    const eastSorted = sortTeams([...allTeams.east]);
    const westSorted = sortTeams([...allTeams.west]);
    
    // Populate East
    eastSorted.forEach((team, idx) => {
        const winPct = team.w / (team.w + team.l);
        const odds = calcPlayoffOdds(team.w, team.l, team.playoff);
        const data = {
            rank: idx + 1,
            team: team.name,
            w: team.w,
            l: team.l,
            winPct: winPct,
            playoffOdds: odds,
            isPlayoff: team.playoff === 1
        };
        const row = createStandingsRow(data);
        eastStandings.appendChild(row);
    });
    
    // Populate West
    westSorted.forEach((team, idx) => {
        const winPct = team.w / (team.w + team.l);
        const odds = calcPlayoffOdds(team.w, team.l, team.playoff);
        const data = {
            rank: idx + 1,
            team: team.name,
            w: team.w,
            l: team.l,
            winPct: winPct,
            playoffOdds: odds,
            isPlayoff: team.playoff === 1
        };
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
    
    // Make prediction using trained model or heuristics
    let prediction;
    
    if (predictor && predictor.isReady) {
        // Use trained ML model
        const teamStats = {
            'Wins': wins,
            'Losses': losses,
            'ThreePointPct': threePct,
            'DefensiveRating': defRating
        };
        
        const result = predictor.predictPlayoffProbability(teamStats);
        prediction = {
            willMakePlayoffs: result.makePlayoffs,
            confidence: parseFloat(result.playoffProbability),
            isML: true
        };
        
        // Get similar teams for context
        const similarTeams = predictor.getSimilarTeams(teamStats, 3);
        console.log('📚 Similar teams:', similarTeams);
    } else {
        // Fall back to heuristic predictions
        prediction = makePrediction(wins, losses, threePct, defRating);
        prediction.isML = false;
    }
    
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
    
    const modelLabel = prediction.isML ? '🤖 ML Model' : '📊 Heuristic';
    
    resultText.innerHTML = prediction.willMakePlayoffs 
        ? `✅ <strong>${team}</strong> is <strong>LIKELY</strong> to make the playoffs!<br><small>${modelLabel}</small>`
        : `❌ <strong>${team}</strong> is <strong>UNLIKELY</strong> to make the playoffs.<br><small>${modelLabel}</small>`;
    
    confidenceBar.style.width = prediction.confidence + '%';
    confidenceBar.textContent = `${prediction.confidence.toFixed(1)}%`;
    confidenceText.textContent = `Prediction Confidence: ${prediction.confidence.toFixed(1)}%`;
    
    if (prediction.isML) {
        confidenceText.style.color = '#4CAF50';
    } else {
        confidenceText.style.color = '#FF9800';
    }
    
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
        modelType: prediction.isML ? 'ML Model' : 'Heuristic',
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
        const modelEmoji = pred.modelType === 'ML Model' ? '🤖' : '📊';
        card.innerHTML = `
            <h5>${pred.team}</h5>
            <p><strong>Record:</strong> ${pred.wins}W - ${pred.losses}L</p>
            <p><strong>3P%:</strong> ${pred.threePct}%</p>
            <p><strong>Def Rating:</strong> ${pred.defRating.toFixed(1)}</p>
            <p><strong>Prediction:</strong> ${pred.result}</p>
            <p><strong>Confidence:</strong> ${pred.confidence}%</p>
            <p style="font-size: 0.85rem; color: #555;">
                ${modelEmoji} ${pred.modelType || 'Heuristic'} · ${pred.timestamp}
            </p>
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
