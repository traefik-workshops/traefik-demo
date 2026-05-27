#!/usr/bin/env python3
"""Gates Service - In-memory stateful API for gate assignments"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service


def setup_gates_routes():
    """Add gates-specific routes"""
    @app.route('/gates/search', methods=['GET'])
    def search_gates():
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())
        return jsonify(results), 200


if __name__ == '__main__':
    init_store('/api/api.json', 'gate_id', 'Gates')
    setup_gates_routes()
    create_rest_api('gates')

    import logging
    logger = logging.getLogger(__name__)
    logger.info("Starting Gates service on port 3000")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
