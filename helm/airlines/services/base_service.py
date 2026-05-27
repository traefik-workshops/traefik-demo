#!/usr/bin/env python3
"""
Stateful In-Memory API Service
Generic base for all airline microservices
Supports full CRUD operations with in-memory storage
"""

import json
import logging
from typing import Dict, List, Optional
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import uuid
import random
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)
CORS(app)

# In-memory storage
class InMemoryStore:
    def __init__(self, data_file: str, id_field: str = "id", resource_name: Optional[str] = None):
        self.id_field = id_field
        self.resource_name = resource_name
        self.data: Dict[str, any] = {}
        self.raw_data: Dict[str, any] = {}
        self.load_initial_data(data_file)
    
    def load_initial_data(self, data_file: str):
        """Load initial data from JSON file"""
        try:
            if os.path.exists(data_file):
                with open(data_file, 'r') as f:
                    raw_data = json.load(f)
                    self.raw_data = raw_data
                    # Extract the main data object (could be flights, bookings, etc.)
                    for key in raw_data:
                        if isinstance(raw_data[key], dict):
                            self.data = raw_data[key]
                            logger.info(f"Loaded {len(self.data)} records from {data_file}")
                            break
            else:
                logger.warning(f"Data file {data_file} not found, starting empty")
                self.raw_data = {}
        except Exception as e:
            logger.error(f"Error loading data: {e}")
            self.data = {}
            self.raw_data = {}
    
    def _generate_id(self) -> str:
        """Generate a new record ID consistent with seeded data."""
        # Booking IDs use the BK###### pattern in seed data
        if self.resource_name == "Bookings" and self.id_field == "booking_id":
            while True:
                new_id = f"BK{random.randint(100000, 999999)}"
                if new_id not in self.data:
                    return new_id
        # Default: UUID
        return str(uuid.uuid4())
    
    def get_all(self) -> Dict:
        """Get all records"""
        return self.data
    
    def get_by_id(self, record_id: str) -> Optional[Dict]:
        """Get single record by ID"""
        return self.data.get(record_id)
    
    def create(self, record: Dict) -> Dict:
        """Create new record"""
        if self.id_field not in record or not record.get(self.id_field):
            record[self.id_field] = self._generate_id()
        
        record_id = record[self.id_field]
        self.data[record_id] = record
        logger.info(f"Created record: {record_id}")
        return record
    
    def update(self, record_id: str, updates: Dict) -> Optional[Dict]:
        """Update existing record"""
        if record_id not in self.data:
            return None
        
        self.data[record_id].update(updates)
        logger.info(f"Updated record: {record_id}")
        return self.data[record_id]
    
    def delete(self, record_id: str) -> bool:
        """Delete record"""
        if record_id in self.data:
            del self.data[record_id]
            logger.info(f"Deleted record: {record_id}")
            return True
        return False
    
    def search(self, **filters) -> List[Dict]:
        """Search records by filters"""
        results = []
        for record in self.data.values():
            match = True
            for key, value in filters.items():
                if key in record and record[key] != value:
                    match = False
                    break
            if match:
                results.append(record)
        return results


# Initialize store (will be set by service-specific code)
store: Optional[InMemoryStore] = None

def init_store(data_file: str, id_field: str, resource_name: str):
    """Initialize the data store"""
    global store, RESOURCE_NAME
    store = InMemoryStore(data_file, id_field, resource_name)
    RESOURCE_NAME = resource_name
    logger.info(f"Initialized {resource_name} service with {len(store.data)} records")

# Generic routes
@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "records": len(store.data) if store else 0}), 200

def create_rest_api(resource_path: str, versions=None):
    """Create RESTful API routes for a resource.

    OpenAPI spec serving:
      - Non-versioned APIs (versions=None, the default): spec is served at
        /{resource_path}/openapi.yaml from /public/openapi.yaml.
      - Versioned APIs (versions=["v1", "v2", ...]): one spec per version
        is served at /{resource_path}/{version}/openapi.yaml from
        /public/{version}/openapi.yaml. Each version's ConfigMap is mounted
        at the corresponding subdir by the flaskService helper.

    Serving the spec under the resource_path prefix (rather than the global
    /openapi.yaml) lets Hub's multicluster heartbeat fetch the spec via a
    path that doesn't collide with other APIs on the same uplink.
    """

    def _serve_spec(openapi_path):
        if os.path.exists(openapi_path):
            with open(openapi_path, 'r') as f:
                return f.read(), 200, {'Content-Type': 'application/x-yaml'}
        return "OpenAPI spec not found", 404

    if versions:
        # One Flask route per version reading its own ConfigMap-mounted file.
        # Capture `v` via default arg so the closure binds correctly.
        for v in versions:
            def _make_openapi(version=v):
                def openapi_version():
                    return _serve_spec(f'/public/{version}/openapi.yaml')
                return openapi_version
            app.add_url_rule(
                f'/{resource_path}/{v}/openapi.yaml',
                endpoint=f'openapi_{resource_path}_{v}',
                view_func=_make_openapi(v),
                methods=['GET'],
            )
    else:
        @app.route(f'/{resource_path}/openapi.yaml', methods=['GET'])
        def openapi():
            return _serve_spec(os.getenv('OPENAPI_FILE', '/public/openapi.yaml'))

    @app.route(f'/{resource_path}', methods=['GET'])
    def list_all():
        """List all records"""
        # Support query parameters for filtering
        filters = request.args.to_dict()

        if filters:
            results = store.search(**filters)
            return jsonify(results), 200

        # Return array of all records
        return jsonify(list(store.data.values())), 200
    
    @app.route(f'/{resource_path}/<record_id>', methods=['GET'])
    def get_one(record_id):
        """Get single record"""
        record = store.get_by_id(record_id)
        if record:
            # Return single record object directly
            return jsonify(record), 200
        return jsonify({"error": "Not found", "status": 404}), 404
    
    @app.route(f'/{resource_path}', methods=['POST'])
    def create():
        """Create new record"""
        data = request.get_json(silent=True) or {}
        if not data:
            return jsonify({"error": "No data provided"}), 400
        
        record = store.create(data)
        return jsonify(record), 201
    
    @app.route(f'/{resource_path}/<record_id>', methods=['PUT', 'PATCH'])
    def update(record_id):
        """Update existing record"""
        data = request.get_json(silent=True)
        if data is None:
            data = {}

        # If record doesn't exist, still return 404
        existing = store.get_by_id(record_id)
        if not existing:
            return jsonify({"error": "Not found"}), 404

        # If no updates provided, act as a no-op update and return the current record
        if not data:
            return jsonify({"status": "updated", "data": existing}), 200

        record = store.update(record_id, data)
        return jsonify({"status": "updated", "data": record}), 200
    
    @app.route(f'/{resource_path}/<record_id>', methods=['DELETE'])
    def delete(record_id):
        """Delete record"""
        if RESOURCE_NAME == "Bookings":
            # Bookings API expects 204 No Content on successful cancel
            existing = store.get_by_id(record_id)
            if existing:
                store.update(record_id, {"status": "cancelled"})
            return "", 204

        if store.delete(record_id):
            return jsonify({"status": "deleted"}), 200
        return jsonify({"error": "Not found"}), 404
    
    # Special search endpoint
    @app.route(f'/{resource_path}/search', methods=['GET'])
    def search():
        """Search with query parameters"""
        filters = request.args.to_dict()
        results = store.search(**filters)
        return jsonify(results), 200


def run_service(resource_name: str, resource_path: str, id_field: str, data_file: str = "/api/api.json", port: int = 3000):
    """Run the service"""
    init_store(data_file, id_field, resource_name)
    create_rest_api(resource_path)
    
    logger.info(f"Starting {resource_name} service on port {port}")
    logger.info(f"Endpoints: /{resource_path}, /{resource_path}/<id>, /{resource_path}/search")
    logger.info(f"Loaded {len(store.data)} initial records")
    
    app.run(host='0.0.0.0', port=port, debug=False)


if __name__ == '__main__':
    # Can be run directly for testing
    run_service(
        resource_name=os.getenv('SERVICE_NAME', 'generic'),
        resource_path=os.getenv('RESOURCE_PATH', 'items'),
        id_field=os.getenv('ID_FIELD', 'id'),
        data_file=os.getenv('DATA_FILE', '/api/api.json'),
        port=int(os.getenv('PORT', '3000'))
    )
