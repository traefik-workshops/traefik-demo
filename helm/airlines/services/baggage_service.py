#!/usr/bin/env python3
"""Baggage Service - In-memory stateful API with baggage tracking"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_baggage_routes():
    """Add baggage-specific routes"""
    @app.route('/baggage/search', methods=['GET'])
    def search_baggage():
        """Search baggage by any field"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        # Search in the baggage map
        raw = base_service.store.raw_data or {}
        baggage_map = raw.get('baggage', {})

        if filters:
            results = [bag for bag in baggage_map.values()
                      if all(bag.get(k) == v for k, v in filters.items())]
        else:
            results = list(baggage_map.values())

        return jsonify(results), 200

    @app.route('/baggage/add', methods=['POST'])
    def add_baggage():
        """Add checked baggage for a booking"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        data = request.get_json(silent=True) or {}
        booking_id = data.get('booking_id')
        bags = int(data.get('bags', 1)) if data.get('bags') is not None else 1
        if not booking_id:
            return jsonify({"error": "booking_id required"}), 400

        raw = base_service.store.raw_data or {}
        booking_map = raw.setdefault('baggage/booking', {})
        baggage_map = raw.setdefault('baggage', {})

        new_records = []
        existing_for_booking = booking_map.setdefault(booking_id, [])
        for _ in range(bags):
            bag_tag = f"BT{booking_id}-{len(baggage_map) + 1}"
            rec = {
                "bag_tag": bag_tag,
                "booking_id": booking_id,
                "weight": data.get('weight', 20),
                "status": "checked",
                "location": data.get('location', "JFK"),
            }
            existing_for_booking.append(rec)
            baggage_map[bag_tag] = rec
            new_records.append(rec)

        base_service.store.raw_data = raw
        return jsonify({"baggage": new_records}), 201

    @app.route('/baggage/track/<bag_tag>', methods=['GET'])
    def track_baggage(bag_tag):
        """Track a specific bag by bag tag"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        raw = base_service.store.raw_data or {}
        baggage_map = raw.get('baggage', {})
        rec = baggage_map.get(bag_tag)
        if rec:
            return jsonify(rec), 200
        return jsonify({"error": "Not found"}), 404

    @app.route('/baggage/track/<bag_tag>', methods=['PUT'])
    def update_baggage(bag_tag):
        """Update baggage status"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        data = request.get_json(silent=True) or {}
        raw = base_service.store.raw_data or {}
        baggage_map = raw.get('baggage', {})
        rec = baggage_map.get(bag_tag)
        if not rec:
            return jsonify({"error": "Not found"}), 404
        rec.update(data)
        baggage_map[bag_tag] = rec
        raw['baggage'] = baggage_map
        base_service.store.raw_data = raw
        return jsonify(rec), 200

    @app.route('/baggage/booking/<booking_id>', methods=['GET'])
    def get_baggage_for_booking(booking_id):
        """Get all baggage for a booking"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        raw = base_service.store.raw_data or {}
        booking_map = raw.get('baggage/booking', {})
        bags = booking_map.get(booking_id, [])
        return jsonify(bags), 200

if __name__ == '__main__':
    # Initialize the store
    init_store('/api/api.json', 'bag_tag', 'Baggage')

    # Set up baggage-specific routes FIRST
    setup_baggage_routes()

    # Then set up standard CRUD routes
    create_rest_api('baggage', versions=['v1', 'v2'])

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Baggage service on port 3000")
    logger.info(f"Endpoints: /baggage, /baggage/add, /baggage/track/<bag_tag>, /baggage/booking/<booking_id>")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
