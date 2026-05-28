#!/usr/bin/env python3
"""Bookings Service - In-memory stateful API with search"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_bookings_routes():
    """Add bookings-specific routes"""
    @app.route('/bookings/search', methods=['GET'])
    def search_bookings():
        """Search bookings by passenger_id, flight_id, status, etc."""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

if __name__ == '__main__':
    init_store('/api/api.json', 'booking_id', 'Bookings')
    setup_bookings_routes()
    create_rest_api('bookings', versions=['v1', 'v2'])

    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Bookings service on port 3000")
    logger.info(f"Endpoints: /bookings, /bookings/<id>, /bookings/search")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
