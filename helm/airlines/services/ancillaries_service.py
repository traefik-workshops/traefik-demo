#!/usr/bin/env python3
"""Ancillaries Service - In-memory stateful API with meals and seat upgrades"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_ancillaries_routes():
    """Add ancillaries-specific routes"""
    @app.route('/ancillaries/search', methods=['GET'])
    def search_ancillaries():
        """Search ancillaries by any field"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

    @app.route('/ancillaries/meals', methods=['GET'])
    def get_meal_options():
        """Get available meal options"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        meals = (base_service.store.raw_data or {}).get('meals', {})
        return jsonify(meals), 200

    @app.route('/ancillaries/meal', methods=['POST'])
    def record_meal_preference():
        """Record meal preference for a booking"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        data = request.get_json(silent=True) or {}
        booking_id = data.get('booking_id') or request.args.get('booking_id')
        preference = data.get('preference') or request.args.get('preference')
        if not booking_id or not preference:
            return jsonify({"error": "booking_id and preference required"}), 400
        result = {
            "booking_id": booking_id,
            "preference": preference,
            "status": "recorded",
        }
        return jsonify(result), 201

    @app.route('/ancillaries/seat-upgrade', methods=['POST'])
    def upgrade_seat():
        """Upgrade seat for a booking"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        data = request.get_json(silent=True) or {}
        booking_id = data.get('booking_id')
        new_seat = data.get('new_seat')
        if not booking_id or not new_seat:
            return jsonify({"error": "booking_id and new_seat required"}), 400
        result = {
            "booking_id": booking_id,
            "new_seat": new_seat,
            "status": "upgraded",
        }
        return jsonify(result), 201

if __name__ == '__main__':
    # Initialize the store
    init_store('/api/api.json', 'ancillary_id', 'Ancillaries')

    # Set up ancillaries-specific routes FIRST
    setup_ancillaries_routes()

    # Then set up standard CRUD routes
    create_rest_api('ancillaries')

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Ancillaries service on port 3000")
    logger.info(f"Endpoints: /ancillaries, /ancillaries/meals, /ancillaries/meal, /ancillaries/seat-upgrade")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
