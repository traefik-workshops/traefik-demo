#!/usr/bin/env python3
"""Flights Service - In-memory stateful API with search"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_flights_routes():
    """Add flights-specific routes"""
    @app.route('/flights/search', methods=['GET'])
    def search_flights():
        """Search flights by origin, destination, date, status, etc."""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        # Get query parameters
        filters = request.args.to_dict()

        # Search using the store's search method
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

    @app.route('/flights/internal-status', methods=['GET'])
    def internal_status():
        """Internal ops endpoint — not exposed in the OpenAPI spec."""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        return jsonify({
            "status": "ok",
            "total_flights": len(base_service.store.data)
        }), 200

if __name__ == '__main__':
    # Initialize the store
    init_store('/api/api.json', 'flight_id', 'Flights')

    # Set up flights-specific routes FIRST
    setup_flights_routes()

    # Then set up standard CRUD routes
    create_rest_api('flights', versions=['v1', 'v2'])

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Flights service on port 3000")
    logger.info(f"Endpoints: /flights, /flights/<id>, /flights/search")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
