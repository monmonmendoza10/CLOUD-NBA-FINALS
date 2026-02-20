/**
 * NBA Playoff Prediction Engine
 * Loads CSV data and provides playoff predictions using machine learning
 */

class NBAPlayoffPredictor {
    constructor() {
        this.trainingData = [];
        this.model = null;
        this.scaler = {
            means: {},
            stds: {}
        };
        this.features = ['Wins', 'Losses', 'ThreePointPct', 'DefensiveRating'];
        this.isReady = false;
    }

    /**
     * Load and parse CSV data
     */
    async loadCSVData(csvText) {
        console.log('📊 Loading CSV data...');
        
        const lines = csvText.trim().split('\n');
        const headers = lines[0].split(',').map(h => h.trim());
        
        this.trainingData = [];
        
        for (let i = 1; i < lines.length; i++) {
            const values = lines[i].split(',').map(v => v.trim());
            
            const record = {};
            headers.forEach((header, idx) => {
                const value = values[idx];
                // Convert numeric columns to numbers
                if (['Wins', 'Losses', 'ThreePointPct', 'DefensiveRating', 'MadePlayoffs'].includes(header)) {
                    record[header] = parseFloat(value);
                } else {
                    record[header] = value;
                }
            });
            
            if (record.Team && record.Wins !== undefined) {
                this.trainingData.push(record);
            }
        }
        
        console.log(`✅ Loaded ${this.trainingData.length} training samples`);
        return this.trainingData;
    }

    /**
     * Normalize feature values
     */
    normalizeFeatures() {
        console.log('🔧 Normalizing features...');
        
        // Calculate mean and std for each feature
        this.features.forEach(feature => {
            const values = this.trainingData.map(d => d[feature]);
            const mean = values.reduce((a, b) => a + b, 0) / values.length;
            const variance = values.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / values.length;
            const std = Math.sqrt(variance);
            
            this.scaler.means[feature] = mean;
            this.scaler.stds[feature] = std > 0 ? std : 1;
            
            console.log(`  ${feature}: mean=${mean.toFixed(2)}, std=${std.toFixed(2)}`);
        });
    }

    /**
     * Train a simple logistic regression model
     */
    trainModel() {
        console.log('🤖 Training model...');
        
        this.normalizeFeatures();
        
        // Prepare normalized data
        const X = this.trainingData.map(record => {
            return this.features.map(feature => {
                return (record[feature] - this.scaler.means[feature]) / this.scaler.stds[feature];
            });
        });
        
        const y = this.trainingData.map(r => r.MadePlayoffs);
        
        // Simple decision tree-like model using feature importance
        const decisionThresholds = this.calculateDecisionBoundaries(X, y);
        
        this.model = {
            type: 'ensemble',
            thresholds: decisionThresholds,
            trainAccuracy: this.evaluateModel(X, y)
        };
        
        console.log(`✅ Model trained! Accuracy: ${(this.model.trainAccuracy * 100).toFixed(2)}%`);
        this.isReady = true;
    }

    /**
     * Calculate decision boundaries using heuristics
     */
    calculateDecisionBoundaries(X, y) {
        const playoffTeams = [];
        const nonPlayoffTeams = [];
        
        // Separate data
        for (let i = 0; i < X.length; i++) {
            if (y[i] === 1) {
                playoffTeams.push(X[i]);
            } else {
                nonPlayoffTeams.push(X[i]);
            }
        }
        
        // Calculate average values for each class
        const playoffAvg = this.calculateMeans(playoffTeams);
        const nonPlayoffAvg = this.calculateMeans(nonPlayoffTeams);
        
        return {
            playoffAvg,
            nonPlayoffAvg
        };
    }

    /**
     * Calculate mean values
     */
    calculateMeans(data) {
        if (data.length === 0) return this.features.map(() => 0);
        
        const means = Array(this.features.length).fill(0);
        data.forEach(record => {
            record.forEach((val, idx) => {
                means[idx] += val;
            });
        });
        
        return means.map(m => m / data.length);
    }

    /**
     * Calculate Euclidean distance
     */
    euclideanDistance(a, b) {
        return Math.sqrt(a.reduce((sum, val, i) => sum + Math.pow(val - b[i], 2), 0));
    }

    /**
     * Evaluate model accuracy
     */
    evaluateModel(X, y) {
        let correct = 0;
        
        for (let i = 0; i < X.length; i++) {
            const predicted = this.predictNormalized(X[i]);
            if (predicted === y[i]) {
                correct++;
            }
        }
        
        return correct / X.length;
    }

    /**
     * Predict for normalized features
     */
    predictNormalized(normalizedFeatures) {
        const distToPlayoff = this.euclideanDistance(normalizedFeatures, this.model.thresholds.playoffAvg);
        const distToNonPlayoff = this.euclideanDistance(normalizedFeatures, this.model.thresholds.nonPlayoffAvg);
        
        return distToPlayoff < distToNonPlayoff ? 1 : 0;
    }

    /**
     * Get confidence scores
     */
    getProbability(normalizedFeatures) {
        const distToPlayoff = this.euclideanDistance(normalizedFeatures, this.model.thresholds.playoffAvg);
        const distToNonPlayoff = this.euclideanDistance(normalizedFeatures, this.model.thresholds.nonPlayoffAvg);
        
        const totalDist = distToPlayoff + distToNonPlayoff;
        const playoffProb = 1 - (distToPlayoff / totalDist);
        
        return playoffProb;
    }

    /**
     * Predict playoff probability for a team
     */
    predictPlayoffProbability(teamStats) {
        if (!this.isReady) {
            console.error('Model not trained yet!');
            return null;
        }
        
        // Normalize input features
        const normalizedFeatures = this.features.map(feature => {
            const value = teamStats[feature];
            return (value - this.scaler.means[feature]) / this.scaler.stds[feature];
        });
        
        const probability = this.getProbability(normalizedFeatures);
        const prediction = this.predictNormalized(normalizedFeatures);
        
        return {
            makePlayoffs: prediction === 1,
            confidence: probability,
            playoffProbability: (probability * 100).toFixed(1)
        };
    }

    /**
     * Get similar teams from training data
     */
    getSimilarTeams(teamStats, topN = 3) {
        const normalizedInput = this.features.map(feature => {
            const value = teamStats[feature];
            return (value - this.scaler.means[feature]) / this.scaler.stds[feature];
        });
        
        const distances = this.trainingData.map((record, idx) => {
            const normalizedRecord = this.features.map(feature => {
                return (record[feature] - this.scaler.means[feature]) / this.scaler.stds[feature];
            });
            const dist = this.euclideanDistance(normalizedInput, normalizedRecord);
            return { team: record.Team, distance: dist, makePlayoffs: record.MadePlayoffs };
        });
        
        return distances
            .sort((a, b) => a.distance - b.distance)
            .slice(0, topN);
    }
}

// Export for use in browser and Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = NBAPlayoffPredictor;
}
