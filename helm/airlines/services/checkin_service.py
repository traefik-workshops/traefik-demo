#!/usr/bin/env python3
"""Check-in Service - In-memory stateful API with boarding pass"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_checkin_routes():
    """Add check-in specific routes"""
    @app.route('/checkin/search', methods=['GET'])
    def search_checkin():
        """Search check-ins by any field"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

    @app.route('/checkin/<booking_id>/boarding-pass', methods=['GET'])
    def get_boarding_pass(booking_id):
        """Get boarding pass for a booking"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        record = base_service.store.get_by_id(booking_id)
        if record:
            return jsonify(record), 200
        return jsonify({"error": "Not found"}), 404

if __name__ == '__main__':
    # Initialize the store
    init_store('/api/api.json', 'booking_id', 'Checkin')

    # Set up checkin-specific routes FIRST
    setup_checkin_routes()

    # Then set up standard CRUD routes
    create_rest_api('checkin', versions=['v1', 'v2'])

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Check-in service on port 3000")
    logger.info(f"Endpoints: /checkin, /checkin/<booking_id>, /checkin/<booking_id>/boarding-pass")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
