#!/usr/bin/env python3
"""Pricing Service - In-memory stateful API with flight pricing lookup"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_pricing_routes():
    """Add pricing-specific routes"""
    @app.route('/pricing/search', methods=['GET'])
    def search_pricing():
        """Search pricing by any field"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

    @app.route('/pricing/<flight_id>', methods=['GET'])
    def get_flight_pricing(flight_id):
        """Get pricing for a specific flight"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        # Look up pricing by flight_id
        pricing = base_service.store.get_by_id(flight_id)
        if pricing:
            return jsonify(pricing), 200

        return jsonify({"error": "Not found"}), 404

    @app.route('/pricing/calculate', methods=['POST'])
    def calculate_pricing():
        """Calculate total price for a flight"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        data = request.get_json(silent=True) or {}
        flight_id = data.get('flight_id')
        travel_class = data.get('class', 'economy')

        # Get pricing table and taxes
        pricing_table = base_service.store.data or {}
        taxes_fees = (base_service.store.raw_data or {}).get('taxes_fees', {})

        result = None
        # Try flight-specific pricing first
        if flight_id and flight_id in pricing_table:
            result = pricing_table.get(flight_id)

        # Fallback to default pricing
        if not result or not isinstance(result, dict) or 'base_fare' not in result:
            result = {'base_fare': 400, 'taxes': taxes_fees.get('domestic', 50), 'total': 450}

        # Ensure numeric fields
        base_fare = float(result.get('base_fare', 400))
        taxes = float(result.get('taxes', taxes_fees.get('domestic', 50)))
        total = float(result.get('total', base_fare + taxes))

        return jsonify({'base_fare': base_fare, 'taxes': taxes, 'total': total}), 201

if __name__ == '__main__':
    # Initialize the store
    # Note: Pricing data uses flight_id/route as dict keys (FL123, JFK-LAX, etc.)
    # The id_field is used for CREATE operations when adding new pricing records
    init_store('/api/api.json', 'flight_id', 'Pricing')

    # Set up pricing-specific routes FIRST
    setup_pricing_routes()

    # Then set up standard CRUD routes
    create_rest_api('pricing', versions=['v1', 'v2'])

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Pricing service on port 3000")
    logger.info(f"Endpoints: /pricing, /pricing/<flight_id>, /pricing/calculate")
    logger.info(f"Loaded {len(base_service.store.data)} initial pricing records")

    app.run(host='0.0.0.0', port=3000, debug=False)
