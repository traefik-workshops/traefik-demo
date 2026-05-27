#!/usr/bin/env python3
"""Passengers Service - In-memory stateful API with search"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_passengers_routes():
    """Add passengers-specific routes"""
    @app.route('/passengers/search', methods=['GET'])
    def search_passengers():
        """Search passengers by name, email, nationality, etc."""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

if __name__ == '__main__':
    init_store('/api/api.json', 'passenger_id', 'Passengers')
    setup_passengers_routes()
    create_rest_api('passengers', versions=['v1', 'v2'])

    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Passengers service on port 3000")
    logger.info(f"Endpoints: /passengers, /passengers/<id>, /passengers/search")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
