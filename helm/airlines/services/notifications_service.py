#!/usr/bin/env python3
"""Notifications Service - In-memory stateful API with notification templates"""
import sys
sys.path.append('/app')
from base_service import app, init_store, create_rest_api
from flask import jsonify, request
import base_service

def setup_notifications_routes():
    """Add notifications-specific routes"""
    @app.route('/notifications/search', methods=['GET'])
    def search_notifications():
        """Search notifications by any field"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500

        filters = request.args.to_dict()
        results = base_service.store.search(**filters) if filters else list(base_service.store.data.values())

        return jsonify(results), 200

    @app.route('/notifications/send', methods=['POST'])
    def send_notification():
        """Send a notification"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        data = request.get_json(silent=True) or {}
        notif_type = data.get('type')
        recipient = data.get('recipient')
        booking_id = data.get('booking_id')
        bag_tag = data.get('bag_tag')

        raw = base_service.store.raw_data or {}
        templates = raw.get('templates', {})
        template = templates.get(notif_type, {})
        subject = template.get('subject', 'Notification')
        body_template = template.get('body', '')
        body = body_template.replace('{booking_id}', booking_id or '').replace('{bag_tag}', bag_tag or '')

        result = {
            "type": notif_type,
            "recipient": recipient,
            "subject": subject,
            "body": body,
            "booking_id": booking_id,
            "bag_tag": bag_tag,
        }

        history = raw.setdefault('history', {})
        history.setdefault(recipient or 'unknown', []).append(result)
        base_service.store.raw_data = raw

        return jsonify(result), 201

    @app.route('/notifications/history/<recipient_id>', methods=['GET'])
    def get_notification_history(recipient_id):
        """Get notification history for a recipient"""
        if not base_service.store:
            return jsonify({"error": "Service not initialized"}), 500
        raw = base_service.store.raw_data or {}
        history = raw.get('history', {})
        items = history.get(recipient_id, [])
        return jsonify(items), 200

if __name__ == '__main__':
    # Initialize the store
    init_store('/api/api.json', 'notification_id', 'Notifications')

    # Set up notifications-specific routes FIRST
    setup_notifications_routes()

    # Then set up standard CRUD routes
    create_rest_api('notifications')

    # Start the server
    import logging
    logger = logging.getLogger(__name__)
    logger.info(f"Starting Notifications service on port 3000")
    logger.info(f"Endpoints: /notifications, /notifications/send, /notifications/history/<recipient_id>")
    logger.info(f"Loaded {len(base_service.store.data)} initial records")

    app.run(host='0.0.0.0', port=3000, debug=False)
